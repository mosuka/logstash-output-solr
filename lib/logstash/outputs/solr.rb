# encoding: utf-8
require "logstash/outputs/base"
require "logstash/namespace"

require 'securerandom'
require 'rsolr'
require 'zk'
require 'rsolr/cloud'

# An Solr output that send data to Apache Solr.
class LogStash::Outputs::Solr < LogStash::Outputs::Base
  config_name "solr"

  # The Solr server url (for example http://localhost:8983/solr/collection1).
  config :url, :validate => :string, :default => nil

  # The ZooKeeper connection string that SolrCloud refers to (for example localhost:2181/solr).
  config :zk_host, :validate => :string, :default => nil
  # The SolrCloud collection name.
  config :collection, :validate => :string, :default => 'collection1'

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

    events.each do |event|
      document = event.to_hash()

      # TODO: add timestamp

      unless document.has_key?('id') then
        document ['id'] = SecureRandom.uuid
      end

      documents.push(document)
    end

    if @mode == MODE_STANDALONE then
      @solr.add documents, :params => {:commit => true}
      log.info "Added %d document(s) to Solr" % documents.count
    elsif @mode == MODE_SOLRCLOUD then
      @solr.add documents, collection: @collection, :params => {:commit => true}
      log.info "Added %d document(s) to Solr" % documents.count
    end
    rescue Exception => e
      @logger.warn("An error occurred while indexing: #{e.message}")
  end # def flush

  public
  def close
    unless @zk.nil? then
      @zk.close
    end
  end # def close
end # class LogStash::Outputs::Solr
