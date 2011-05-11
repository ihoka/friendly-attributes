require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "friendly-attributes"
  gem.homepage = "http://github.com/ihoka/friendly-attributes"
  gem.license = "MIT"
  gem.summary = %Q{Extend ActiveRecord models using Friendly ORM delegate models}
  gem.description = %Q{Pattern to add fields to ActiveRecord models, using an associated document, without needing schema migrations.}
  gem.email = "istvan.hoka@gmail.com"
  gem.authors = ["Istvan Hoka"]
  gem.files = Dir['lib/**/*.rb'] + %w[CHANGELOG.md README.rdoc LICENSE.txt]
  gem.test_files = []
  
  ## It seems like Jeweler is merging in the Gemfile. Skipping these for now.
  # gem.add_runtime_dependency 'activerecord', '~> 2.3.5'
  # gem.add_runtime_dependency 'yajl-ruby', '~> 0.7.7'
  # gem.add_runtime_dependency 'memcached', '~> 0.20.1'
  # 
  # gem.add_development_dependency 'mysql', '~> 2.8.1'
  # gem.add_development_dependency 'rspec', '~> 2.1.0'
  # gem.add_development_dependency 'bundler', '~> 1.0.0'
  # gem.add_development_dependency 'jeweler', '~> 1.5.1'
  # gem.add_development_dependency 'rcov', '>= 0'
  # gem.add_development_dependency 'database_cleaner', '~> 0.5.0'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
  spec.rcov = true
  spec.rcov_opts = %w{-I spec:lib --exclude gems\/,spec\/}
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "friendly-attributes #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
