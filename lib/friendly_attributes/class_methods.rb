module FriendlyAttributes
  module ClassMethods
    def friendly_details(klass, &block)
      DetailsDelegator.new(klass, self, &block)
    end
    
    def friendly_mount_uploader(name, klass)
      mount_uploader name, klass
      
      instance_eval do
        alias_method :read_uploader, :read_friendly_attribute
        alias_method :write_uploader, :write_friendly_attribute
      end
    end
  end
end
