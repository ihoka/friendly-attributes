module FriendlyAttributes
  class DetailsDelegator
    attr_reader :friendly_model, :ar_model
    
    delegate :attribute, :indexes, :to => :friendly_model
    
    class << self
      def friendly_model_name(klass)
        klass.name.underscore.to_sym
      end
    end
    
    def initialize(friendly_model, ar_model, options={}, &block)
      @ar_model            = ar_model
      @friendly_model      = friendly_model
      @friendly_model_name = friendly_model_name = self.class.friendly_model_name(friendly_model)
      
      _active_record_key = options.delete(:active_record_key) || :active_record_id
      
      friendly_model.instance_eval do
        include Friendly::Document
        
        attribute _active_record_key, Integer
        indexes _active_record_key
        
        cattr_accessor :active_record_key
      end
      friendly_model.active_record_key = _active_record_key
      
      friendly_model_ivar = :"@#{friendly_model_name}"
      
      ar_model.class_eval do
        # cattr_accessor :friendly_model
        cattr_accessor friendly_model_name
        
        after_save :update_friendly_details
        after_destroy :destroy_friendly_details
                
        define_method(:"#{friendly_model_name}_details") do
          val = instance_variable_get(friendly_model_ivar)
          return val if val.present?
          
          instance_variable_set(friendly_model_ivar, send(friendly_model_name).find_or_build_by_active_record_id(id, friendly_details_build_options))
        end
      end
      
      # ar_model.friendly_model = friendly_model
      ar_model.send(:"#{friendly_model_name}=", friendly_model)
      
      self.instance_eval(&block) if block_given?
    end
    
    def delegated_attribute(name, klass)
      attribute name, klass
      delegated_method(:"#{name}")
      delegated_method(:"#{name}=")
    end
    
    def delegated_method(name)
      friendly_model_name = @friendly_model_name
      ar_model.class_eval do
        delegate :"#{name}", :to => :"#{friendly_model_name}_details"
      end
    end
  end
end
