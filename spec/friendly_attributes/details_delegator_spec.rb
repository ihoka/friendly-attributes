require 'spec_helper'

describe FriendlyAttributes::DetailsDelegator do
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
  
  let(:details_delegator) { FriendlyAttributes::DetailsDelegator.new(friendly_model, ar_model, &initializer) }
  let(:initializer)       { proc {} }
  let(:friendly_model)    { Class.new }
  let(:ar_model)          { Class.new { include ActiveRecordFake } }
  
  describe "initialization" do
    context "the Friendly model" do
      before(:each) do
        details_delegator
      end
      
      it "includes Friendly::Document" do
        friendly_model.ancestors.should include(Friendly::Document)
      end

      it "adds the active_record_id attribute" do
        friendly_model.attributes.should include(:active_record_id)
      end

      it "adds an index to active_record_id" do
        friendly_model.storage_proxy.index_for_fields([:active_record_id]).should be_an_instance_of(Friendly::Index)
      end
    end
    
    context "the ActiveRecord model" do
      it "installs the update_friendly_details callback after_save" do
        ar_model.should_receive(:after_save).with(:update_friendly_details)
        details_delegator
      end
      
      it "installs the destroy_friendly_details callback after_destroy" do
        ar_model.should_receive(:after_destroy).with(:destroy_friendly_details)
        details_delegator
      end
      
      context ".details" do
        let(:ar_instance) { ar_model.new(:id => 42) }
        let(:details)     { mock(friendly_model) }
        
        before(:each) do
          details_delegator
        end
        
        it "is defined" do
          ar_instance.should respond_to(:details)
        end
        
        it "finds and memoizes the associated Friendly model" do
          friendly_model.should_receive(:find_or_build_by_active_record_id).with(42).once.and_return(details)
          ar_instance.details.should == details
          ar_instance.details.should == details
        end
      end
    end
  
    context "the initialization block" do
      def yielded_inside(instance)
        @yielded_instance = instance
      end
      
      let(:initializer) do
        example = self
        
        proc {
          example.yielded_inside(self)
        }
      end
      
      it "is instance evaled" do
        details_delegator
        @yielded_instance.should == details_delegator
      end
    end
  end
  
  describe "#delegated_attribute" do
    
  end
end
