require 'spec_helper'

describe FriendlyAttributes::Details do
  use_database_cleanup
  
  let(:details) { mock(FriendlyAttributes::Details) }
  
  describe ".find_or_build_by_active_record_id" do
    let(:friendly_model) {
      Class.new(FriendlyAttributes::Details) do
        cattr_accessor :active_record_key
      end.tap { |c| c.active_record_key = :ar_id }
    }
    
    context "when the record does not exist" do
      it "builds a new record with the active_record_id" do
        friendly_model.should_receive(:first).with(:ar_id => 42).and_return(nil)
        friendly_model.should_receive(:new).with(:ar_id => 42).and_return(details)
        friendly_model.find_or_build_by_active_record_id(42).should == details
      end
    end
    
    context "when the record exists" do
      it "finds the record" do
        friendly_model.should_receive(:first).with(:ar_id => 42).and_return(details)
        friendly_model.find_or_build_by_active_record_id(42).should == details
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
