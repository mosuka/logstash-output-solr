# Logstash Plugin

This is a plugin for [Logstash](https://github.com/elastic/logstash). It support [SolrCloud](https://cwiki.apache.org/confluence/display/solr/SolrCloud) not only Standalone Solr.

It is fully free and fully open source. The license is Apache 2.0, meaning you are pretty much free to use it however you want in whatever way.

## Config parameters

### url

The Solr server url (for example http://localhost:8983/solr/collection1).

```
url http://localhost:8983/solr/collection1
```

### zk_host

The ZooKeeper connection string that SolrCloud refers to (for example localhost:2181/solr).

```
zk_host localhost:2181/solr
```

### collection

The SolrCloud collection name (default collection1).

```
collection collection1
```

### defined_fields

The defined fields in the Solr schema.xml. If omitted, it will get fields via Solr Schema API.

```
defined_fields ["id", "title"]
```

### ignore_undefined_fields

Ignore undefined fields in the Solr schema.xml.

```
ignore_undefined_fields false
```

### unique_key_field

A field name of unique key in the Solr schema.xml. If omitted, it will get unique key via Solr Schema API.

```
unique_key_field id
```

### timestamp_field

A field name of event timestamp in the Solr schema.xml (default event_timestamp).

```
timestamp_field event_timestamp
```

### flush_size

A number of events to queue up before writing to Solr (default 100).

```
flush_size 100
```

## Plugin setup examples

### Sent to standalone Solr using data-driven schemaless mode.
```
output {
  solr {
    url => "http://localhost:8983/solr/collection1"
  }
}

```

### Sent to SolrCloud using data-driven schemaless mode.
```
output {
  solr {
    zk_host => "localhost:2181/solr"
    collection => "collection1"
  }
}
```


## Need Help?

Need help? Try #logstash on freenode IRC or the https://discuss.elastic.co/c/logstash discussion forum.

## Developing

### 1. Plugin Developement and Testing

#### Code
- To get started, you'll need JRuby with the Bundler gem installed.

- Create a new plugin or clone and existing from the GitHub [logstash-plugins](https://github.com/logstash-plugins) organization. We also provide [example plugins](https://github.com/logstash-plugins?query=example).

- Install dependencies
```sh
bundle install
```

#### Test

- Update your dependencies

```sh
bundle install
```

- Run tests

```sh
bundle exec rspec
```

### 2. Running your unpublished Plugin in Logstash

#### 2.1 Run in a local Logstash clone

- Edit Logstash `Gemfile` and add the local plugin path, for example:
```ruby
gem "logstash-output-solr", :path => "/your/local/logstash-output-solr"
```
- Install plugin
```sh
bin/plugin install --no-verify
```
- Run Logstash with your plugin
```sh
bin/logstash -e 'filter {awesome {}}'
```
At this point any modifications to the plugin code will be applied to this local Logstash setup. After modifying the plugin, simply rerun Logstash.

#### 2.2 Run in an installed Logstash

You can use the same **2.1** method to run your plugin in an installed Logstash by editing its `Gemfile` and pointing the `:path` to your local plugin development directory or you can build the gem and install it using:

- Build your plugin gem
```sh
gem build logstash-output-solr.gemspec
```
- Install the plugin from the Logstash home
```sh
bin/plugin install /your/local/plugin/logstash-output-solr.gem
```
- Start Logstash and proceed to test the plugin

## Contributing

All contributions are welcome: ideas, patches, documentation, bug reports, complaints, and even something you drew up on a napkin.

Programming is not a required skill. Whatever you've seen about open source and maintainers or community members  saying "send patches or die" - you will not see that here.

It is more important to the community that you are able to contribute.

For more information about contributing, see the [CONTRIBUTING](https://github.com/elastic/logstash/blob/master/CONTRIBUTING.md) file.