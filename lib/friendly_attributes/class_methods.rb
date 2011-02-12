module FriendlyAttributes
  module ClassMethods
    # Configure a Friendly Base model associated with an ActiveRecord model.
    # 
    # @overload friendly_details(klass, attributes)
    #   @param [Class] klass FriendlyAttributes::Base instance used to extend the ActiveRecord model
    #   @param [Hash] attributes hash of types and attributes names with which to extend the ActiveRecord, through FriendlyAttributes::Base
    # 
    # @overload friendly_details(klass, attributes, options)
    #   @param [Hash] options configuration options for extending the FriendlyAttributes extension (see {DetailsDelegator#initialize})
    # 
    # @return [DetailsDelegator]
    def friendly_details(*args, &block)
      klass = args.shift
      options = args.extract_options!
      attributes = args.extract_options!
      if attributes.empty?
        attributes = options
        options = {}
      end
      
      DetailsDelegator.new(klass, self, attributes, options, &block).tap do |dd|
        dd.setup_delegated_attributes
        dd.instance_eval(&block) if block_given?
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
