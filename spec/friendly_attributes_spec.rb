require 'spec_helper'

describe FriendlyAttributes do
  use_database_cleanup
  
  describe "definition" do
    it { User.should have_friendly_attributes(String, :name, :through => UserDetails) }
    it { User.new.should have_friendly_attributes(Integer, :shoe_size, :birth_year, :through => UserDetails) }
    it { User.new.should have_friendly_attributes(Friendly::Boolean, :subscribed, :through => UserDetails) }
    it { User.should_not have_friendly_attributes(String, :foo, :through => UserDetails) }
  end
    
  describe "creating" do
    context "with Friendly attributes" do
      let(:user) { User.create!(:name => "Stan", :email => "stan@example.com", :birth_year => 1984, :subscribed => true) }
      
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
    
    context "with nested attributes" do
      let(:user) { User.create(:name => "Stan Marsh", :email => "smarsh@example.com") }
      let(:parent) { Parent.create(:users => [user]) }
      
      before(:each) do
        parent
        parent.update_attributes(:users_attributes => users_attributes)
        user.reload
      end
      
      context "when only changing Friendly attributes" do
        let(:users_attributes) { { "0" => { "id" => user.id, "name" => "Eric Cartman" } } }
        
        it "updates Friendly attributes through nested association" do
          user.name.should == "Eric Cartman"
        end
      end
      
      context "when changing both Friendly attributes and ActiveRecord attributes" do
        let(:users_attributes) { { "0" => { "id" => user.id, "name" => "Eric Cartman", "email" => "eric@example.com" } } }
        
        it "updates Friendly attributes through nested association" do
          user.email.should == "eric@example.com"
          user.name.should == "Eric Cartman"
        end
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
