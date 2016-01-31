# encoding: utf-8
require "logstash/outputs/base"
require "logstash/namespace"

require 'securerandom'
require "stud/buffer"
require 'rsolr'
require 'zk'
require 'rsolr/cloud'

# An Solr output that send data to Apache Solr.
class LogStash::Outputs::Solr < LogStash::Outputs::Base
  config_name "solr"

  include Stud::Buffer

  # The Solr server url (for example http://localhost:8983/solr/collection1).
  config :url, :validate => :string, :default => nil

  # The ZooKeeper connection string that SolrCloud refers to (for example localhost:2181/solr).
  config :zk_host, :validate => :string, :default => nil
  # The SolrCloud collection name.
  config :collection, :validate => :string, :default => 'collection1'

  # The defined fields in the Solr schema.xml. If omitted, it will get fields via Solr Schema API.
  config :defined_fields, :validate => :array, :default => nil
  # Ignore undefined fields in the Solr schema.xml.
  config :ignore_undefined_fields, :validate => :boolean, :default => false

  # A field name of unique key in the Solr schema.xml. If omitted, it will get unique key via Solr Schema API.
  config :unique_key_field, :validate => :string, :default => nil
  # A field name of event timestamp in the Solr schema.xml (default event_timestamp).
  config :timestamp_field, :validate => :string, :default => 'event_timestamp'

  # The batch size used in update.
  config :flush_size, :validate => :number, :default => 100

  # The batch size used in update.
  config :idle_flush_time, :validate => :number, :default => 10

  MODE_STANDALONE = 'Standalone'
  MODE_SOLRCLOUD = 'SolrCloud'

  public
  def register
    @mode = nil
    if ! @url.nil? then
      @mode = MODE_STANDALONE
    elsif ! @zk_host.nil?
      @mode = MODE_SOLRCLOUD
    end

    @solr = nil
    @zk = nil

    if @mode == MODE_STANDALONE then
      @solr = RSolr.connect :url => @url
    elsif @mode == MODE_SOLRCLOUD then
      @zk = ZK.new(@zk_host)
      cloud_connection = RSolr::Cloud::Connection.new(@zk)
      @solr = RSolr::Client.new(cloud_connection, read_timeout: 60, open_timeout: 60)
    end

    buffer_initialize(
      :max_items => @flush_size,
      :max_interval => @idle_flush_time,
      :logger => @logger
    )
  end # def register

  public
  def receive(event)
    buffer_receive(event)
  end # def event

  public
  def flush(events, close=false)
    documents = []

    @fields = @defined_fields.nil? || @defined_fields.empty? ? get_fields : @defined_fields

    @unique_key = @unique_key_field.nil? ? get_unique_key : @unique_key_field

    events.each do |event|
      document = event.to_hash()

      unless document.has_key?(@unique_key) then
        document.merge!({@unique_key => SecureRandom.uuid})
      end

      unless document.has_key?(@timestamp_field) then
        document.merge!({@timestamp_field => document['@timestamp']})
      end

      if @ignore_undefined_fields then
        document.each_key do |key|
          unless @fields.include?(key) then
            document.delete(key)
          end
        end
      end

      @logger.info 'Record: %s' % document.inspect

      documents.push(document)
    end

    if @mode == MODE_STANDALONE then
      @solr.add documents, :params => {:commit => true}
      @logger.info 'Added %d document(s) to Solr' % documents.count
    elsif @mode == MODE_SOLRCLOUD then
      @solr.add documents, collection: @collection, :params => {:commit => true}
      @logger.info 'Added %d document(s) to Solr' % documents.count
    end

    rescue Exception => e
      @logger.warn('An error occurred while indexing: #{e.message}')
  end # def flush

  public
  def close
    unless @zk.nil? then
      @zk.close
    end
  end # def close

  private
  def get_unique_key
    response = nil

    if @mode == MODE_STANDALONE then
      response = @solr.get 'schema/uniquekey'
    elsif @mode == MODE_SOLRCLOUD then
      response = @solr.get 'schema/uniquekey', collection: @collection
    end

    unique_key = response['uniqueKey']
    @logger.info 'Unique key: #{unique_key}'

    return unique_key

    rescue Exception => e
      @logger.warn 'Unique key: #{e.message}'
  end # def get_unique_key

  private
  def get_fields
    response = nil

    if @mode == MODE_STANDALONE then
      response = @solr.get 'schema/fields'
    elsif @mode == MODE_SOLRCLOUD then
      response = @solr.get 'schema/fields', collection: @collection
    end

    fields = []
    response['fields'].each do |field|
      fields.push(field['name'])
    end
    @logger.info 'Fields: #{fields}'

    return fields

    rescue Exception => e
      @logger.warn 'Fields: #{e.message}'
  end # def get_fields
end # class LogStash::Outputs::Solr
