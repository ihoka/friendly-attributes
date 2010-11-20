module FriendlyAttributes
  module Test
    module Matchers
      class HaveFriendlyAttribute
        def initialize(example, type, *attributes)
          @example    = example
          @type       = type
          @attributes = attributes
        end
        
        def matches?(actual)
          @actual = Class === actual ? actual : actual.class
          
          result = @actual.ancestors.include?(FriendlyAttributes) && @attributes.all? { |attr|
            @actual.friendly_model.attributes.include?(attr) && @actual.friendly_model.attributes[attr].type == @type
          }
        end
        
        def failure_message
          "expected #{@actual.inspect} to have friendly attributes #{@attributes.inspect} of type #{@type}"
        end
        
        def negative_failure_message
          "expected #{@actual.inspect} not to have friendly attributes #{@attributes.inspect}"
        end
        
        def description
          "have [#{@actual}] friendly_attributes of type #{@type} => #{@attributes.inspect}"
        end
      end
      
      def have_friendly_attributes(*args)
        HaveFriendlyAttribute.new(self, *args)
      end
      alias_method :have_friendly_attribute, :have_friendly_attributes
    end
  end
end