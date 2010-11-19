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
end
