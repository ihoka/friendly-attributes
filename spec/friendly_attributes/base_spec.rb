require 'spec_helper'

describe FriendlyAttributes::Base do
  use_database_cleanup
  
  let(:friendly_model) {
    Class.new(FriendlyAttributes::Base) do
      cattr_accessor :active_record_key
    end.tap { |c| c.active_record_key = active_record_key }
  }
  let(:active_record_key) { :ar_id }
  let(:details) { mock(FriendlyAttributes::Base) }
  
  describe ".find_or_build_by_active_record_id" do
    
    context "when the record does not exist" do
      before(:each) do
        friendly_model.should_receive(:first).with(:ar_id => 42).and_return(nil)
      end
      
      it "builds a new record with the active_record_id" do
        friendly_model.should_receive(:new).with(:ar_id => 42).and_return(details)
        friendly_model.find_or_build_by_active_record_id(42).should == details
      end
      
      it "with options present, it builds a new record with the options and active_record_id" do
        friendly_model.should_receive(:new).with(:ar_id => 42, :foo => "foo").and_return(details)
        friendly_model.find_or_build_by_active_record_id(42, :foo => "foo").should == details
      end
    end
    
    context "when the record exists" do
      it "finds the record" do
        friendly_model.should_receive(:first).with(:ar_id => 42).and_return(details)
        friendly_model.find_or_build_by_active_record_id(42).should == details
      end
    end
  end
  
  describe "#write_active_record_id" do
    let(:friendly_instance) { friendly_model.new }
    
    it "sets the active_record_id using the configured attribute writer" do
      friendly_instance.should_receive(:"#{active_record_key}=").with(42).and_return(42)
      friendly_instance.write_active_record_id(42).should == 42
    end
  end
  
  describe "#read_active_record_id" do
    let(:friendly_instance) { friendly_model.new }
    
    it "sets the active_record_id using the configured attribute writer" do
      friendly_instance.should_receive(active_record_key).and_return(42)
      friendly_instance.read_active_record_id.should == 42
    end
  end
  
  describe "#update_if_changed_with_model" do
    let(:friendly_instance) { friendly_model.new }
    
    before(:each) do
      friendly_instance.stub(:save => false, :changed? => false, :read_active_record_id => 42)
    end
    
    context "when the active_record_id is not set" do
      before(:each) do
        friendly_instance.should_receive(:read_active_record_id).and_return(nil)
      end
      
      it "sets the active_record_id" do
        friendly_instance.should_receive(:write_active_record_id).with(42)
        friendly_instance.update_if_changed_with_model(42)
      end
    end
    
    context "when the active_record_id is set" do
      before(:each) do
        friendly_instance.should_receive(:read_active_record_id).and_return(42)
      end
      
      it "does not reset the active_record_id" do
        friendly_instance.should_not_receive(:write_active_record_id)
        friendly_instance.update_if_changed_with_model(42)
      end
    end
    
    context "when changed" do
      before(:each) do
        friendly_instance.should_receive(:changed?).and_return(true)
      end
      
      it "saves the record" do
        friendly_instance.should_receive(:save).and_return(true)
        friendly_instance.update_if_changed_with_model(42).should be_true
      end
    end
    
    context "when not changed" do
      before(:each) do
        friendly_instance.should_receive(:changed?).and_return(false)
      end
      
      it "saves the record" do
        friendly_instance.should_not_receive(:save)
        friendly_instance.update_if_changed_with_model(42).should be_false
      end
    end
  end
  
  describe "#attributes" do
    let(:details) { UserDetails.create(attributes) }
    let(:attributes) { { :name => "Foo", :birth_year => 1970, :shoe_size => 42, :subscribed => true, UserDetails.active_record_key => 55 } }
    
    it "returns a hash of all the model's attributes" do
      actual = details.attributes
      actual.should include(attributes)
      actual[:created_at].should be_an_instance_of(Time)
      actual[:updated_at].should be_an_instance_of(Time)
      actual[:id].should be_an_instance_of(Friendly::UUID)
    end
  end
end
