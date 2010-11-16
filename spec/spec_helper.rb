$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'friendly_attributes'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.before(:all) do
    config = YAML.load(File.read(File.dirname(__FILE__) + "/config.yml"))['test']
    Friendly.configure config
    
    $db                          = Friendly.db
    Sequel::MySQL.default_engine = "InnoDB"
    datastore                    = Friendly::DataStore.new($db)
    Friendly.datastore           = datastore
    $cache                       = Memcached.new
    Friendly.cache               = Friendly::Memcached.new($cache)
  end
  
end
