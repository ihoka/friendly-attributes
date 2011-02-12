module FriendlyAttributes
  class Base
    class << self
      def find_or_build_by_active_record_id(active_record_id, options={})
        active_record_id && first(active_record_key => active_record_id) || new(options.merge(active_record_key => active_record_id))
      end
    end
    
    def write_active_record_id(active_record_id)
      send(:"#{details.active_record_key}=", active_record_id)
    end
    
    def read_active_record_id
      send(active_record_key)
    end
    
    def update_if_changed_with_model(active_record_id)
      write_active_record_id(active_record_id) unless read_active_record_id == active_record_id
      save if changed?
    end
    
    def attributes
      {}.tap do |attributes|
        self.class.attributes.keys.each do |attr|
          attributes[attr] = self.send(attr)
        end
      end
    end
  end
end
