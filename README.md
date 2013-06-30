# Friendly Attributes

[![Build Status](https://travis-ci.org/ihoka/friendly-attributes.png)](https://travis-ci.org/ihoka/friendly-attributes)


Extend your ActiveRecord models with attributes dynamically, without any schema migrations.

## Description

[FriendlyORM][friendly] is an implementation of a document based storage on top of MySQL.

FriendlyAttributes associates FriendlyORM documents with your ActiveRecord models, handles delegation of attribute accessors and automatically saves and destroys the associated document.

## Installation

Currently, only ActiveRecord 2.3.x is supported. ActiveRecord 3 is not supported yet.

Add it to your Gemfile:
    
    gem 'friendly-attributes'
    
or, to your `config/environment.rb` in Rails:
  
    config.gem 'friendly-attributes'

## Usage

To use Friendly Attributes, you must have an existing ActiveRecord model:
    
    # app/models/user.rb
    class User < ActiveRecord::Base
      # ...
    end

Create a class for storing your Friendly document, extending `FriendlyAttributes::Base`:
    
    # app/models/user_details.rb
    class UserDetails < FriendlyAttributes::Base
    end

`FriendlyAttributes::Base` mixes in `Friendly::Document`, so check out the [Friendly ORM documentation][friendly] for what options you can use here, like defining indexes and scopes.

Configure the attributes you need to extend your ActiveRecord model:
    
    # app/models/account.rb
    class User < ActiveRecord::Base
      include FriendlyAttributes
    
      friendly_details UserDetails, {
        String  => :github_username,
        Integer => [:shoe_size, :birth_year]
      }
    end

If using Rails, configure the database to be used by Friendly, by creating `config/friendly.yml` and specifying the configuration. If you don't mind mixing tables, the database can be the same as the one configured for Rails, but it does not have to be. Note that Friendly automatically creates a table for each index you define in your Friendly document.
    
    # config/friendly.yml
    development:
      adapter: mysql
      socket: /tmp/mysql.sock
      database: friendly_database_development
      username: root
      password:
    
Use the Rails console or a rake task to create the Friendly document tables:
    
    Friendly.create_tables!

Once complete, you can use your Friendly Attributes just like you would regular ActiveRecord attributes:
    
    user = User.first
    user.shoe_size = 42
    user.save!

## Documentation

Check out the source documentation for more information about usage.

## Development
 
In order to setup a development environment and run the specs, you need Bundler:

    gem install bundler

Then, install the dependencies:
    
    bundle install

Create a database to use for runnning specs:
    
    mysqladmin create friendly_attributes_test

Copy spec/config.yml.example and customize it with the database you have created:
    
    cp spec/config.yml.sample spec/config.yml

Run the specs:
    
    rake spec

## Credits

Friendly Attributes was developed by [Istvan Hoka][ihoka] and [Cristi Duma][cduma].

Copyright (c) 2011 Aissac Labs. See [LICENSE.txt][license] for further details.

[github]: http://github.com/ihoka/friendly-attributes
[friendly]: http://github.com/jamesgolick/friendly
[ihoka]: http://istvanhoka.com
[cduma]: http://twitter.com/cristiduma
[blinksale]: http://www.blinksale.com
[license]: LICENSE.txt
