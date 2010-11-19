require 'spec_helper'

describe FriendlyAttributes::InstanceMethods do
  let(:object)  { klass.new.tap { |o| o.stub(:details => details) } }
  let(:klass)   {
    Class.new {
      include ActiveRecordFake
      include FriendlyAttributes::InstanceMethods
    }
  }
  let(:details) { mock("details") }
  
  describe "#read_friendly_attribute" do
    it "reads the attribute from details" do
      foo = mock
      
      details.should_receive(:foo).and_return(foo)
      object.read_friendly_attribute(:foo).should == foo
    end
  end
  
  describe "#write_friendly_attribute" do
    it "writes the attribute to details" do
      foo = mock
      
      details.should_receive(:foo=).with(:value)
      object.write_friendly_attribute(:foo, :value)
    end
  end
  
  describe "#details_present?" do
    subject { object.details_present? }
    
    context "when @details is present" do
      before(:each) do
        object.instance_variable_set(:"@details", mock)
      end
      
      it { should be_true }
    end
    
    context "when @details is not present" do
      it { should be_false }
    end
  end
  
  describe "#update_friendly_details" do
    context "details are present" do
      before(:each) do
        object.id = 42
        object.should_receive(:details_present?).and_return(true)
        details.stub(:changed? => false, :active_record_id => object.id)
      end
      
      context "details.active_record_id does not equal object.id" do
        before(:each) do
          details.should_receive(:active_record_id).and_return(nil)
        end
        
        it "sets the active_record_id" do
          details.should_receive(:active_record_id=).with(object.id)
          object.update_friendly_details
        end
      end
      
      context "details.active_record_id equals object.id" do
        before(:each) do
          details.should_receive(:active_record_id).and_return(object.id)
        end
        
        it "sets the active_record_id" do
          details.should_not_receive(:active_record_id=)
          object.update_friendly_details
        end
      end
      
      context "the details have changed" do
        before(:each) do
          details.should_receive(:changed?).and_return(true)
        end
        
        it "saves the details" do
          details.should_receive(:save)
          object.update_friendly_details
        end
      end
      
      context "the details have NOT changed" do
        before(:each) do
          details.should_receive(:changed?).and_return(false)
        end
        
        it "saves the details" do
          details.should_not_receive(:save)
          object.update_friendly_details
        end
      end
    end
    
    context "details are NOT present" do
      before(:each) do
        object.should_receive(:details_present?).and_return(false)
      end
    end
  end

  describe "#destroy_friendly_details" do
    it "destroys the details" do
      details.should_receive(:destroy)
      object.destroy_friendly_details
    end
  end
end
