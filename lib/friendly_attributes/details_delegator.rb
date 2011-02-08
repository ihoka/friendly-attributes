module FriendlyAttributes
  class DetailsDelegator
    attr_reader :friendly_model, :active_record_model, :attributes, :friendly_model_name
    
    delegate :attribute, :indexes, :to => :friendly_model
    
    class << self
      def friendly_model_name(klass)
        klass.name.underscore.to_sym
      end
      
      def friendly_model_ivar(name)
        :"@#{name}_ivar"
      end
      
      def friendly_model_reader(name)
        name = friendly_model_name(name) if name.is_a?(Class)
        :"load_#{name}"
      end
    end
    
    def initialize(friendly_model, ar_model, attributes, options={})
      @active_record_model = ar_model
      @friendly_model      = friendly_model
      @friendly_model_name = self.class.friendly_model_name(friendly_model)
      @attributes          = attributes
      
      setup_friendly_model(options.delete(:active_record_key) || :active_record_id)
      setup_active_record_model
    end
    
    def delegated_attribute(name, klass)
      attribute name, klass
      delegated_method(:"#{name}")
      delegated_method(:"#{name}=")
    end
    
    def delegated_method(name)
      friendly_model_name = self.friendly_model_name
      
      active_record_model.class_eval do
        delegate :"#{name}", :to => FriendlyAttributes::DetailsDelegator.friendly_model_reader(friendly_model_name)
      end
    end
    
    def setup_delegated_attributes
      attributes.each do |key, value|
        if Array === value
          value.each { |v| delegated_attribute v, key }
        else
          delegated_attribute value, key
        end
      end
    end
    
    private
      
      def setup_friendly_model(_active_record_key)
        friendly_model.instance_eval do
          include Friendly::Document

          attribute _active_record_key, Integer
          indexes _active_record_key

          cattr_accessor :active_record_key
        end
        friendly_model.active_record_key = _active_record_key
      end
    
      def setup_active_record_model
        friendly_model_name = self.friendly_model_name

        active_record_model.class_eval do
          cattr_accessor :friendly_attributes_configuration

          define_method(FriendlyAttributes::DetailsDelegator.friendly_model_reader(friendly_model_name)) do
            find_or_build_and_memoize_details(friendly_model_name)
          end
        end

        unless active_record_model.friendly_attributes_configuration
          active_record_model.friendly_attributes_configuration = Configuration.new(active_record_model)
          
          active_record_model.class_eval do
            after_save :update_friendly_details
            after_destroy :destroy_friendly_details
          end
        end
        
        active_record_model.friendly_attributes_configuration.add(self)
      end
  end
end
