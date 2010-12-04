module FriendlyAttributes
  class DetailsDelegator
    attr_reader :friendly_model, :ar_model
    
    delegate :attribute, :indexes, :to => :friendly_model
    
    def initialize(friendly_model, ar_model, options={}, &block)
      @ar_model       = ar_model
      @friendly_model = friendly_model
      
      _active_record_key = options.delete(:active_record_key) || :active_record_id
      
      friendly_model.instance_eval do
        include Friendly::Document
        
        attribute _active_record_key, Integer
        indexes _active_record_key
        
        cattr_accessor :active_record_key
      end
      friendly_model.active_record_key = _active_record_key
      
      ar_model.class_eval do
        cattr_accessor :friendly_model
        
        after_save :update_friendly_details
        after_destroy :destroy_friendly_details
                
        define_method(:details) do
          @details ||= friendly_model.find_or_build_by_active_record_id(id, friendly_details_build_options)
        end
      end
      
      ar_model.friendly_model = friendly_model
      
      self.instance_eval(&block) if block_given?
    end
    
    def delegated_attribute(name, klass)
      attribute name, klass
      delegated_method(:"#{name}")
      delegated_method(:"#{name}=")
    end
    
    def delegated_method(name)
      ar_model.class_eval do
        delegate :"#{name}", :to => :details
      end
    end
  end
end
