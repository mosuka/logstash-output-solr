Gem::Specification.new do |s|
  s.name = 'logstash-output-solr'
  s.version = "0.3.0"
  s.licenses = ["Apache License (2.0)"]
  s.summary = "Logstash output plugin for sending data to Solr."
  s.description = "Logstash output plugin for sending data to Solr. It support SolrCloud not only Standalone Solr."
  s.authors = ["Minoru Osuka"]
  s.email = "minoru.osuka@gmail.com"
  s.homepage = "https://github.com/mosuka/logstash-output-solr"
  s.require_paths = ["lib"]

  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE']
   # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "output" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core", ">= 2.0.0", "< 3.0.0"
  s.add_runtime_dependency "logstash-codec-plain"
  s.add_runtime_dependency 'rsolr', '~> 1.0.13'
  s.add_runtime_dependency 'zk', '~> 1.9.6'
  s.add_runtime_dependency 'rsolr-cloud', '~> 1.1.0'
  s.add_runtime_dependency 'stud', '~> 0.0.22'

  s.add_development_dependency "logstash-devutils", '~> 0.0.18'
  s.add_development_dependency 'rake', '~> 10.5.0'
  s.add_development_dependency 'zk-server', '~> 1.1.8' 
end
