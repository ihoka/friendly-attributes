# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name = %q{friendly-attributes}
  s.version = "0.8.0.pre"

  s.authors     = ["Istvan Hoka"]
  s.date        = %q{2013-12-12}
  s.description = %q{Pattern to add fields to ActiveRecord models, using an associated document, without needing schema migrations.}
  s.email       = %q{istvan.hoka@gmail.com}
  s.homepage    = %q{http://github.com/ihoka/friendly-attributes}
  s.licenses    = ["MIT"]
  s.summary     = %q{Extend ActiveRecord models using Friendly ORM delegate models}
  s.version     = File.read(File.dirname(__FILE__) + '/VERSION')

  s.add_development_dependency 'mysql2', '~> 0.3.15'
  s.add_development_dependency 'rspec', '~> 2.5.0'
  s.add_development_dependency 'database_cleaner', '~> 1.2.0'
  s.add_dependency 'ihoka-friendly', '~> 0.8.0.pre'
  s.add_dependency 'activerecord', '~> 2.3.18'
  s.add_dependency 'activerecord-mysql2-adapter', '~> 0.0.3'
  s.add_dependency 'yajl-ruby', '~> 1.2.0'
  s.add_dependency 'memcached', '~> 1.7.2'
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.require_paths = ["lib"]
end

