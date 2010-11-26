module FriendlyAttributes
  module ClassMethods
    def friendly_details(*args, &block)
      klass = args.shift
      options = args.extract_options!
      attributes = args.extract_options!
      if attributes.empty?
        attributes = options
        options = {}
      end
      
      delegate_options = proc {
        attributes.each do |key, value|
          if Array === value
            value.each { |v| delegated_attribute v, key }
          else
            delegated_attribute value, key
          end
        end
      }
      
      DetailsDelegator.new(klass, self, options, &block).tap do |dd|
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
