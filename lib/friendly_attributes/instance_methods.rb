module FriendlyAttributes
  module InstanceMethods
    def read_friendly_attribute(attr)
      friendly_instance_for_attribute(attr).send(attr)
    end

    def write_friendly_attribute(attr, instance)
      friendly_instance_for_attribute(attr).send(:"#{attr}=", instance)
    end
    
    def friendly_instance_for_attribute(attr)
      friendly_attributes_configuration.model_for_attribute(attr)
    end

    def update_friendly_models
      present_friendy_details.each do |details|
        details.update_if_changed_with_model(id)
      end
    end
    
    # Destroys all FriendlyAttributes associated with the model.
    #
    # @return [true, false] result of attempting to destroy the associated FriendlyAttributes
    def destroy_friendly_models
      all_friendy_details.map(&:destroy).all?
    end
    
    def friendly_details_build_options(friendly_model = nil)
      {}
    end

    def find_or_build_and_memoize_details(friendly_model)
      friendly_model_ivar = DetailsDelegator.friendly_model_ivar(friendly_model)
      
      val = instance_variable_get(friendly_model_ivar)
      return val if val.present?
      
      instance_variable_set(friendly_model_ivar,
        friendly_model.
        find_or_build_by_active_record_id(id, friendly_details_build_options(friendly_model)))
    end
    
    # Returns true if the FriendlyAttributes specified instance is loaded.
    #
    # @param [Class, Symbol, String] friendly_model Class or name of the FriendlyAttributes model
    # @return [true, false] is the FriendlyAttributes instance loaded
    def friendly_details_present?(friendly_model)
      friendly_model_ivar = DetailsDelegator.friendly_model_ivar(friendly_model)
      val = instance_variable_get(friendly_model_ivar)
      val.present?
    end
    
    # Returns the associated FriendlyAttributes instance, if it has been loaded. If not loaded, returns nil.
    #
    # @param [Class, Symbol, String] friendly_model Class or name of the FriendlyAttributes model
    # @return [FriendlyAttributes::Base, nil] instance of the FriendlyAttributes or nil
    def friendly_details_presence(friendly_model)
      friendly_details_present?(friendly_model) ?
        send(DetailsDelegator.friendly_model_reader(friendly_model)) :
        nil
    end
    
    # List of all the FriendlyAttributes::Base instances associated with the model.
    # Forces loading if the details have not been loaded yet.
    #
    # @return [Array<FriendlyAttributes::Base>] FriendlyAttributes instances
    def all_friendy_details
      friendly_attributes_configuration.friendly_models.map do |friendly_model|
        send(DetailsDelegator.friendly_model_reader(friendly_model))
      end
    end
    
    # List of FriendlyAttributes::Base instances that have been loaded.
    # Does not force loading of details not loaded yet.
    #
    # @return [Array<FriendlyAttributes::Base>] FriendlyAttributes instances
    def present_friendy_details
      friendly_attributes_configuration.friendly_models.map do |friendly_model|
        friendly_details_presence(friendly_model)
      end
    end
    
    # Returns if the record has been changed and should be saved, taking into account any FriendlyAttributes.
    #
    # Overloads ActiveRecord::Base#changed?
    #
    # @return [true, false]
    def changed?
      super || present_friendy_details.any?(&:changed?)
    end
  end
end
