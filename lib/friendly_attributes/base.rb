module FriendlyAttributes
  class Base
    class << self
      # Finds an existing Friendly model, associated with an ActiveRecord model,
      # or builds a new Friendly model, using the specified options.
      # 
      # @param [Integer] ActiveRecord model ID for which to find the associated Friendly model
      # @param [Hash] options
      # @return [FriendlyAttributes::Base] found or new record
      def find_or_build_by_active_record_id(active_record_id, options={})
        active_record_id && first(active_record_key => active_record_id) || new(options.merge(active_record_key => active_record_id))
      end
    end
    
    # Set the ID of the associated ActiveRecord model.
    #
    # Uses the :active_record_key property of the model.
    #
    # @param [String, Integer] active_record_id value to set the attribute
    # @return [String, Integer] value
    def write_active_record_id(active_record_id)
      send(:"#{active_record_key}=", active_record_id)
    end
    
    # Get the ID of the associated ActiveRecord model.
    #
    # Uses the :active_record_key property of the model.
    #
    # @return [Integer] ActiveRecord ID
    def read_active_record_id
      send(active_record_key)
    end
    
    # Save the FriendlyAttribute model if it has been changed.
    # Before saving, it sets the specified active_record_id, to handle the case when it is a new record or has been reassigned.
    #
    # @param [Integer] active_record_id ID of the associated ActiveRecord model
    # @return [true, false] result of saving the record
    def update_if_changed_with_model(active_record_id)
      write_active_record_id(active_record_id) unless read_active_record_id == active_record_id
      save if changed?
    end
    
    # Alias for Friendly::Document#to_hash
    def attributes
      to_hash
    end
  end
end
