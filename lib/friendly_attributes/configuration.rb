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
      delegator.delegated_attributes.each do |name, _|
        attributes[name] = delegator.friendly_model
      end
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