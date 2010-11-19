module ActiveRecordFake
  def self.included(base)
    base.instance_eval do
      attr_accessor :id
    end
    
    (class << base; self; end).class_eval do
      def after_save(*args); end
      def after_destroy(*args); end
    end
  end
  
  def initialize(attributes={})
    attributes.each do |k, v|
      send(:"#{k}=", v)
    end
  end
end
