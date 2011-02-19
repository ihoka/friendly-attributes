module FriendlyAttributes
  class Configuration
    attr_reader :details_delegators, :model, :attributes
    
    def initialize(active_record_model)
      @model = active_record_model
      @details_delegators = []
      @attributes = {}
    end
    
    def add(delegator)
      details_delegators << delegator
    end
    
    def add_attribute(name, friendly_model)
      attributes[name] = friendly_model
    end
    
    def model_for_attribute(attr)
      attributes[attr]
    end
    
    def friendly_models
      details_delegators.map { |dd| dd.friendly_model }
    end
    
    def map_models(&block)
      friendly_models.map(&block)
    end
    
    def each_model(&block)
      friendly_models.each(&block)
    end
  end
end