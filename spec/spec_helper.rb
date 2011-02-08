$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'memcached'
require 'yajl'
require 'friendly_attributes'
require 'database_cleaner'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  yaml = YAML.load(File.read(File.dirname(__FILE__) + "/config.yml"))
  Friendly.configure yaml['test']
  
  $db = Friendly.db
  
  %w[user_details user_second_details index_user_details_on_user_id].each do |table|
    $db.drop_table(table) if $db.table_exists?(table)
  end
  
  Friendly.datastore = Friendly::DataStore.new($db)
  $cache             = Memcached.new
  Friendly.cache     = Friendly::Memcached.new($cache)
  
  ActiveRecord::Base.logger = Friendly.db.logger = Logger.new(File.dirname(__FILE__) + "/../log/test.log")
  
  ActiveRecord::Base.configurations = yaml
  ActiveRecord::Base.establish_connection 'test'
  ActiveRecord::Schema.define do
    create_table :parents, :force => true do |t|
    end
    
    create_table :users, :force => true do |t|
      t.string :email
      t.references :parent
    end
  end
      
  class ::UserDetails < FriendlyAttributes::Base
  end
  
  class ::UserSecondDetails < FriendlyAttributes::Base
  end
  
  class ::User < ActiveRecord::Base
    belongs_to :parent
    
    include FriendlyAttributes
    
    friendly_details(UserDetails, { Integer => [:birth_year, :shoe_size], Friendly::Boolean => :subscribed }, { :active_record_key => :user_id }) do
      delegated_attribute :name, String
    end
    
    friendly_details(UserSecondDetails, Integer => :second_int)
    
    def friendly_details_build_options
      {
        :shoe_size => 42
      }
    end
  end
  
  class ::Parent < ActiveRecord::Base
    has_many :users
    
    accepts_nested_attributes_for :users
  end
  
  Friendly::Document.create_tables!
  
  DatabaseCleaner.strategy = :truncation
  DatabaseCleaner.clean_with(:truncation)
  
  config.extend DatabaseCleanerHelpers
  config.include FriendlyAttributes::Test::Matchers
end

