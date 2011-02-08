module FriendlyFake
  def self.included(base)
    base.instance_eval do
      def name
        "FriendlyFake"
      end
    end
  end
end

RSpec.configure do |config|
  def mock_friendly_model
    Class.new { include FriendlyFake }
  end
end