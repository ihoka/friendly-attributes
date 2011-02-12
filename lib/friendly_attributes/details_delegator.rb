module FriendlyAttributes
  class DetailsDelegator
    # @attr_reader [Class] friendly_model FriendlyAttributes::Base class towa which the attributes are delegated
    # @attr_reader [Class] active_record_model The ActiveRecord::Base class from which the attributes are delegated
    # @attr_reader [Hash<Symbol, Class>] delegated_attributes Attributes delegated by this DetailsDelegator
    attr_reader :friendly_model, :active_record_model, :delegated_attributes, :attributes
    
    delegate :attribute, :indexes, :to => :friendly_model
    
    class << self
      # Method name for the FriendlyAttributes::Base class passed to it.
      #
      # @param [Class] klass class we want to get the name for
      # @return [Symbol] underscored name of the class.
      def friendly_model_name(klass)
        klass.name.underscore.to_sym
      end
      
      # Instance variable name for the FriendlyAttributes::Base or `friendly_model_name` passed to it.
      #
      # @param [Symbol, String, Class] name_or_klass Class or name for which to generate the ivar name
      # @return [Symbol] ivar name
      def friendly_model_ivar(name_or_klass)
        name_or_klass = friendly_model_name(name_or_klass) if name_or_klass.is_a?(Class)
        :"@#{name_or_klass}_ivar"
      end
      
      # Reader method name for a certain FriendlyAttributes::Base instance associated with the model.
      #
      # @param [Symbol, String, Class] name_or_klass Class or name for which to generate the reader method name
      # @return [Symbol] reader method name
      def friendly_model_reader(name_or_klass)
        name_or_klass = friendly_model_name(name_or_klass) if name_or_klass.is_a?(Class)
        :"load_#{name_or_klass}"
      end
    end
    
    # Initialize new DetailsDelegator instance.
    #
    # @param [Class] friendly_model FriendlyAttributes model, that inherits from FriendlyModel::Base
    # @param [Class] ar_model ActiveRecord model, host for the FriendlyAttributes model
    # @param [Hash] attributes
    # @param [Hash] options
    # @option options [Symbol] :active_record_key (:active_record_id) name of the 'foreign key' in which the FriendlyModel::Base instance keeps a reference to the ActiveRecord model
    def initialize(friendly_model, ar_model, attributes, options={})
      @active_record_model  = ar_model
      @friendly_model       = friendly_model
      @attributes           = attributes
      @delegated_attributes = {}
      
      setup_friendly_model(options.delete(:active_record_key) || :active_record_id)
      setup_active_record_model
    end
    
    def delegated_attribute(name, klass)
      delegated_attributes[name] = klass
      
      attribute name, klass
      delegated_method(:"#{name}")
      delegated_method(:"#{name}=")
    end
    
    def delegated_method(name)
      friendly_model = self.friendly_model
      
      active_record_model.class_eval do
        delegate :"#{name}", :to => FriendlyAttributes::DetailsDelegator.friendly_model_reader(friendly_model)
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
        friendly_model = self.friendly_model

        active_record_model.class_eval do
          # Stores the FriendlyAttributes configuration for the ActiveRecord model.
          cattr_accessor :friendly_attributes_configuration

          define_method(FriendlyAttributes::DetailsDelegator.friendly_model_reader(friendly_model)) do
            find_or_build_and_memoize_details(friendly_model)
          end
        end

        unless active_record_model.friendly_attributes_configuration
          active_record_model.friendly_attributes_configuration = Configuration.new(active_record_model)
          
          active_record_model.class_eval do
            after_save :update_friendly_models
            after_destroy :destroy_friendly_models
          end
        end
        
        active_record_model.friendly_attributes_configuration.add(self)
      end
  end
end
