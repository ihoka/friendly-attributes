module FriendlyAttributes
  module ClassMethods
    def friendly_details(*args, &block)
      klass = args.shift
      options = args.extract_options!
      
      delegate_options = proc {
        options.each do |key, value|
          if Array === value
            value.each { |v| delegated_attribute v, key }
          else
            delegated_attribute value, key
          end
        end
      }
      
      DetailsDelegator.new(klass, self, &block).tap do |dd|
        dd.instance_eval(&delegate_options)
      end
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
