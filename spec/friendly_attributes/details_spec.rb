require 'spec_helper'

describe FriendlyAttributes::Details do
  use_database_cleanup
  
  describe ".find_or_build_by_active_record_id" do
    context "when the record does not exist" do
      it "builds a new record with the active_record_id" do
        details = UserDetails.find_or_build_by_active_record_id(42)
        details.should be_new_record
        details.active_record_id.should == 42
      end
    end
    
    context "when the record exists" do
      let(:details) { UserDetails.create(:active_record_id => 42) }
      
      before(:each) do
        details.should_not be_new_record
      end
      
      it "finds the record" do
        UserDetails.find_or_build_by_active_record_id(42).should == details
      end
    end
  end
  
  describe "#attributes" do
    let(:details) { UserDetails.create(attributes) }
    let(:attributes) { { :name => "Foo", :birth_year => 1970, :shoe_size => 42, :subscribed => true, :active_record_id => 55 } }
    
    it "returns a hash of all the model's attributes" do
      actual = details.attributes
      actual.should include(attributes)
      actual[:created_at].should be_an_instance_of(Time)
      actual[:updated_at].should be_an_instance_of(Time)
      actual[:id].should be_an_instance_of(Friendly::UUID)
    end
  end
end
