require 'spec_helper'

describe FriendlyAttributes do
  use_database_cleanup
  
  describe "creating" do
    context "with Friendly attributes" do
      let(:user) { User.create(:name => "Stan", :email => "stan@example.com", :birth_year => 1984, :shoe_size => 42, :subscribed => true) }
      
      it "creates an associated Details model with the AR model" do
        expect do
          user
        end.to change { UserDetails.count({}) }
        
        user_detail = user.details
        user_detail.name.should == "Stan"
        user_detail.birth_year.should == 1984
        user_detail.shoe_size.should == 42
        user_detail.subscribed.should be_true
      end
    end
    
    context "without Friendly attributes" do
      let(:user) { User.create(:email => "stan@example.com") }
      
      it "does not create an associated Details model" do
        expect do
          user
        end.to_not change { UserDetails.count({}) }
      end
    end
  end
  
  describe "updating" do
    context "with Friendly attributes" do
      let(:user) { User.create(:name => "Stan", :email => "stan@example.com") }
      
      it "updates the attributes" do
        user.update_attributes(:name => "Eric")
        UserDetails.first({}).name.should == "Eric"
      end
    end
    
    context "without Friendly attributes" do
      let(:user) { User.create(:email => "stan@example.com") }
      
      it "does not create an associated Details model, if no delegated attributes are updated" do
        expect do
          user.update_attributes(:email => "eric@example.com")
        end.to_not change { UserDetails.count({}) }
      end
      
      it "creates an associated Details model, if delegated attributes are updated" do
        expect do
          user.update_attributes(:name => "Eric")
        end.to change { UserDetails.count({}) }
        user.name.should == "Eric"
      end
    end
  end
  
  describe "destroying" do
    let(:user) { User.create(:name => "Stan", :email => "stan@example.com") }
    
    it "destroys the associated Details model" do
      user # create it first
      
      expect do
        user.destroy
      end.to change { UserDetails.count({}) }.by(-1)
    end
  end
end
