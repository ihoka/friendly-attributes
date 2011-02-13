module FriendlyAttributes
  module Test
    module Matchers
      class HaveFriendlyAttribute
        def initialize(example, type, *attributes)
          @example    = example
          @type       = type
          @options    = attributes.extract_options!
          @through    = @options[:through]
          @attributes = attributes
        end
        
        def matches?(actual)
          @actual = Class === actual ? actual : actual.class
          
          result = @actual.ancestors.include?(FriendlyAttributes) && @attributes.all? { |attr|
            @through.attributes.include?(attr) && @through.attributes[attr].type == @type
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
      
      # RSpec matcher for checking Friendly attributes.
      # Passes if the model has the specified FriendlyAttributes associated with it.
      #
      # @example Using the matcher
      #     it { should have_friendly_attributes(String, :ssn, :work_email, :through => UserDetails)        }
      #     it { should have_friendly_attributes(Friendly::Boolean, :is_active, :through => CompanyDetails) }
      #
      # @return [HaveFriendlyAttribute] matcher
      def have_friendly_attributes(*args)
        HaveFriendlyAttribute.new(self, *args)
      end
      alias_method :have_friendly_attribute, :have_friendly_attributes
    end
  end
end