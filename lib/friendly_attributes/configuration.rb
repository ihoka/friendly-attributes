module FriendlyAttributes
  class Configuration
    attr_reader :details_delegators, :model
    
    def initialize(active_record_model)
      @model = active_record_model
      @details_delegators = []
    end
    
    def add(delegator)
      details_delegators << delegator
    end
    
    def friendly_models
      details_delegators.map { |dd| dd.friendly_model }
    end
    
    def model_names
      details_delegators.map { |dd| dd.friendly_model_name }
    end
    
    def map_models(&block)
      friendly_models.map(&block)
    end
    
    def each_model(&block)
      friendly_models.each(&block)
    end
  end
end