module FriendlyAttributes
  module InstanceMethods
    def read_friendly_attribute(column)
      details.send(column)
    end

    def write_friendly_attribute(column, instance)
      details.send(:"#{column}=", instance)
    end

    def details_present?
      @details.present?
    end

    def update_friendly_details
      return unless details_present?
      details.send(:"#{details.active_record_key}=", id) unless details.send(details.active_record_key) == id
      details.save if details.changed?
    end

    def destroy_friendly_details
      details.destroy
    end
    
    def friendly_details_build_options
      {}
    end
    
    def changed?
      super || (details_present? && details.changed?)
    end
    
    # reviewed
    
    # 
    def find_or_build_and_memoize_details(friendly_model_name)
      friendly_model_ivar = DetailsDelegator.friendly_model_ivar(friendly_model_name)
      
      val = instance_variable_get(friendly_model_ivar)
      return val if val.present?

      friendly_model_value = send(friendly_model_name)
      
      instance_variable_set(friendly_model_ivar,
        friendly_model_value.
        find_or_build_by_active_record_id(id, friendly_details_build_options(friendly_model_value)))
    end
    
    def friendly_details_present?(friendly_model_name)
      friendly_model_ivar = DetailsDelegator.friendly_model_ivar(friendly_model_name)
      val = instance_variable_get(friendly_model_ivar)
      val.present?
    end
    
    def friendly_details_presence(friendly_model_name)
      friendly_details_present?(friendly_model_name) ?
        send(DetailsDelegator.friendly_model_reader(friendly_model_name)) :
        nil
    end
    
    def all_friendy_details
      friendly_attributes_configuration.model_names.map do |friendly_model_name|
        send(DetailsDelegator.friendly_model_reader(friendly_model_name))
      end
    end
    
    def present_friendy_details
      friendly_attributes_configuration.model_names.map do |friendly_model_name|
        friendly_details_presence(friendly_model_name)
      end
    end
    
    def changed?
      super || present_friendy_details.any?(&:changed?)
    end
  end
end
