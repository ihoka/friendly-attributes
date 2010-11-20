module FriendlyAttributes
  class DetailsDelegator
    attr_reader :friendly_model, :ar_model
    
    delegate :attribute, :indexes, :to => :friendly_model
    
    def initialize(friendly_model, ar_model, &block)
      @ar_model       = ar_model
      @friendly_model = friendly_model
      
      friendly_model.instance_eval do
        include Friendly::Document
      
        attribute :active_record_id, Integer
        indexes :active_record_id
      end
      
      ar_model.class_eval do
        cattr_accessor :friendly_model
        
        after_save :update_friendly_details
        after_destroy :destroy_friendly_details
                
        define_method(:details) do
          @details ||= friendly_model.find_or_build_by_active_record_id(id)
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
