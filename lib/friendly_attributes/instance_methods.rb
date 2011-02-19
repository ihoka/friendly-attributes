module FriendlyAttributes
  module InstanceMethods
    # Read the value of a Friendly attribute
    #
    # @param [Symbol, String] attr name of the attribute to read
    # @return [Object] value of the read attribute
    def read_friendly_attribute(attr)
      friendly_instance_for_attribute(attr).send(attr)
    end
    
    # Write the value of a Friendly attribute
    #
    # @param [Symbol, String] attr name of the attribute to set
    # @param [Object] value value to set the attribute to
    def write_friendly_attribute(attr, value)
      friendly_instance_for_attribute(attr).send(:"#{attr}=", value)
    end
    
    # Returns the Friendly instance corresponding to the specified attribute
    #
    # @param [Symbol, String] attr name of the attribute
    # @return [Class] FriendyAttributes::Base instance
    def friendly_instance_for_attribute(attr)
      klass = friendly_attributes_configuration.model_for_attribute(attr)
      send DetailsDelegator.friendly_model_reader(klass)
    end
    
    # Update all associated Friendly instances, if they have been changed.
    # If assigning attributes resulted in new instances being built, they will be created.
    def update_friendly_models
      present_friendly_instances.each do |details|
        details.update_if_changed_with_model(id)
      end
    end
    
    # Destroys all FriendlyAttributes associated with the model. Forces loading and sends :destroy to all associated Friendly models.
    #
    # @return [true, false] result of attempting to destroy the associated FriendlyAttributes
    def destroy_friendly_models
      all_friendly_instances.map(&:destroy).all?
    end
    
    # Hook provided in order to customize the defaults for building Friendly model instances associated with a certain model.
    # Redefine the method on the FriendlyAttributes::Base subclass to customize.
    #
    # Defaults to an empty Hash.
    #
    # @example We want to specify build options for the UserDetails instances, but not for UserSecondDetails
    #   class User < ActiveRecord::Base
    #     include FriendlyAttributes
    #   
    #     friendly_details(UserDetails, Integer => :shoe_size)
    #     friendly_details(UserSecondDetails, Integer => :second_int)
    #   
    #     def friendly_details_build_options(friendly_model)
    #       if UserDetails == friendly_model
    #         { :shoe_size => 42 }
    #       else
    #         {}
    #       end
    #     end
    #   end
    # 
    # @param [Class] friendly_model FriendlyAttributes::Base subclass for which the build options should be returned
    # @return [Hash] default attributes to be used when building the associated friendly_model
    def friendly_details_build_options(friendly_model = nil)
      {}
    end
    
    # Finds or builds the Friendly instance associated through friendly_model. Result is memoized in an instance variable.
    # @see FriendlyAttributes::Base.find_or_build_by_active_record_id
    # @see FriendlyAttributes::DetailsDelegator.friendly_model_ivar
    #
    # @param [Class] friendly_model FriendlyAttributes::Base subclass
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
    def friendly_instance_present?(friendly_model)
      friendly_model_ivar = DetailsDelegator.friendly_model_ivar(friendly_model)
      val = instance_variable_get(friendly_model_ivar)
      val.present?
    end
    
    # Returns the associated FriendlyAttributes instance, if it has been loaded. If not loaded, returns nil.
    #
    # @param [Class, Symbol, String] friendly_model Class or name of the FriendlyAttributes model
    # @return [FriendlyAttributes::Base, nil] instance of the FriendlyAttributes or nil
    def friendly_instance_presence(friendly_model)
      friendly_instance_present?(friendly_model) ?
        send(DetailsDelegator.friendly_model_reader(friendly_model)) :
        nil
    end
    
    # List of all the FriendlyAttributes::Base instances associated with the model.
    # Forces loading if the details have not been loaded yet.
    #
    # @return [Array<FriendlyAttributes::Base>] FriendlyAttributes instances
    def all_friendly_instances
      friendly_attributes_configuration.friendly_models.map do |friendly_model|
        send(DetailsDelegator.friendly_model_reader(friendly_model))
      end
    end
    
    # List of FriendlyAttributes::Base instances that have been loaded.
    # Does not force loading of details not loaded yet.
    #
    # @return [Array<FriendlyAttributes::Base>] FriendlyAttributes instances
    def present_friendly_instances
      friendly_attributes_configuration.friendly_models.map do |friendly_model|
        friendly_instance_presence(friendly_model)
      end.compact
    end
    
    # Returns if the record has been changed and should be saved, taking into account any FriendlyAttributes.
    #
    # Overloads ActiveRecord::Base#changed?
    #
    # @return [true, false]
    def changed?
      super || present_friendly_instances.any?(&:changed?)
    end
  end
end
