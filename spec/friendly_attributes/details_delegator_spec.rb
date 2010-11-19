require 'spec_helper'

describe FriendlyAttributes::DetailsDelegator do
  let(:details_delegator) { FriendlyAttributes::DetailsDelegator.new(friendly_model, ar_model, &initializer) }
  let(:initializer)       { proc {} }
  
  let(:friendly_model)    { Class.new }
  let(:ar_model)          { Class.new { include ActiveRecordFake } }
  
  let(:ar_instance)       { ar_model.new(:id => 42) }
  let(:friendly_instance) { mock(friendly_model) }
  
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
        before(:each) do
          details_delegator
        end
        
        it "is defined" do
          ar_instance.should respond_to(:details)
        end
        
        it "finds and memoizes the associated Friendly model" do
          friendly_model.should_receive(:find_or_build_by_active_record_id).with(ar_instance.id).once.and_return(friendly_instance)
          ar_instance.details.should == friendly_instance
          ar_instance.details.should == friendly_instance
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
  
  describe "#delegated_method" do
    before(:each) do
      details_delegator
      details_delegator.delegated_method(:some_method)
      ar_instance.stub(:details => friendly_instance)
    end
    
    it "delegates the method to Friendly model" do
      bar = mock
      friendly_instance.should_receive(:some_method).with(:foo).and_return(bar)
      ar_instance.some_method(:foo).should == bar
    end
  end
  
  describe "#delegated_attribute" do
    before(:each) do
      details_delegator
      details_delegator.delegated_attribute(:some_attribute, String)
      ar_instance.stub(:details => friendly_instance)
    end
    
    it "adds an attribute to the Friendly model" do
      friendly_model.attributes.should include(:some_attribute)
      friendly_model.attributes[:some_attribute].type.should == String
    end
    
    it "delegates the reader to Friendly model" do
      bar = mock
      friendly_instance.should_receive(:some_attribute).and_return(bar)
      ar_instance.some_attribute.should == bar
    end
    
    it "delegates the writer to Friendly model" do
      bar = mock
      friendly_instance.should_receive(:some_attribute=).with(:value)
      ar_instance.some_attribute = :value
    end
  end
end