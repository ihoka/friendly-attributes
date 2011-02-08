require 'friendly'
require 'active_record'

module FriendlyAttributes
  autoload :ClassMethods,     'friendly_attributes/class_methods'
  autoload :InstanceMethods,  'friendly_attributes/instance_methods'
  autoload :Base,             'friendly_attributes/base'
  autoload :DetailsDelegator, 'friendly_attributes/details_delegator'
  autoload :Configuration,    'friendly_attributes/configuration'
  
  module Test
    autoload :Matchers, 'friendly_attributes/test/matchers'
  end
  
  def self.included(base)
    base.extend ClassMethods
    base.send(:include, InstanceMethods)
  end
end
