require 'spec_helper'

describe FriendlyAttributes::InstanceMethods do
  DetailsDelegator = FriendlyAttributes::DetailsDelegator unless defined?(DetailsDelegator)
  
  let(:object)  { klass.new.tap { |o| o.stub(:friendly_attributes_configuration => configuration) } }
  let(:configuration) { mock(FriendlyAttributes::Configuration) }
  let(:klass)   {
    Class.new {
      include ActiveRecordFake
      include FriendlyAttributes::InstanceMethods
    }
  }
  let(:user_details) { double(UserDetails).as_null_object }
  let(:user_second_details) { double(UserSecondDetails).as_null_object }
  let(:friendly_model_instances) { [user_details, user_second_details] }
  
  describe "reading and writing Friendly attributes" do
    let(:object_details) { double(FriendlyAttributes::Base, :foo => foo, :foo= => foo) }
    let(:foo) { mock("object_details.foo") }

    before(:each) do
      object.stub(:friendly_instance_for_attribute => object_details)
    end
    
    describe "#read_friendly_attribute" do
      it "finds the FriendlyAttributes instance for the specified attribute" do
        object.
          should_receive(:friendly_instance_for_attribute).
          with(:foo).
          and_return(object_details)

        object.read_friendly_attribute(:foo)
      end

      it "reads the attribute from the FriendlyAttributes instance" do
        object_details.should_receive(:foo).and_return(foo)
        object.read_friendly_attribute(:foo).should == foo
      end
    end

    describe "#write_friendly_attribute" do
      it "finds the FriendlyAttributes instance for the specified attribute" do
        object.
          should_receive(:friendly_instance_for_attribute).
          with(:foo).
          and_return(object_details)

        object.write_friendly_attribute(:foo, "bar")
      end
      
      it "writes the attribute on the FriendlyAttributes instance" do
        object_details.should_receive(:foo=).with("bar").and_return(foo)
        object.write_friendly_attribute(:foo, "bar").should == foo
      end
      
    end
    
  end
  
  describe "#friendly_instance_for_attribute" do
    it "reads the value for the friendly model from the instance" do
      configuration.should_receive(:model_for_attribute).with(:foo).and_return(UserDetails)
      object.should_receive(DetailsDelegator.friendly_model_reader(UserDetails)).and_return(user_details)
      object.friendly_instance_for_attribute(:foo).should == user_details
    end
  end
  
  describe "#update_friendly_models" do
    it "updates each loaded friendly model instance if needed" do
      object.should_receive(:present_friendly_instances).and_return(friendly_model_instances)
      friendly_model_instances.each do |instance|
        instance.should_receive(:update_if_changed_with_model).with(object.id)
      end
      object.update_friendly_models
    end
  end

  describe "#destroy_friendly_details" do
    it "loads and destroys all associated friendly models" do
      object.should_receive(:all_friendly_instances).and_return(friendly_model_instances)
      friendly_model_instances.each do |instance|
        instance.should_receive(:destroy).and_return(true)
      end
      object.destroy_friendly_models.should be_true
    end
  end
  
  describe "#friendly_instance_present?" do
    subject { object.friendly_instance_present?(friendly_model) }
    let(:friendly_model) { UserDetails }
    
    context "when friendly_details ivar is present" do
      before(:each) do
        object.instance_variable_set(DetailsDelegator.friendly_model_ivar(friendly_model), mock)
      end
      
      it { should be_true }
    end
    
    context "when friendly_details ivar is not present" do
      it { should be_false }
    end
  end
  
  describe "#friendly_instance_presence" do
    subject { object.friendly_instance_presence(friendly_model) }
    let(:friendly_model) { UserDetails }
    
    context "when present" do
      before(:each) do
        object.instance_variable_set(DetailsDelegator.friendly_model_ivar(friendly_model), mock)
      end
      
      it "returns the instance using the model reader" do
        object.should_receive(DetailsDelegator.friendly_model_reader(friendly_model)).and_return(user_details)
        subject.should == user_details
      end
    end
    
    context "when not present" do
      it "returns nil" do
        subject.should be_nil
      end
    end
  end
  
  describe "#all_friendly_instances" do
    let(:friendly_models) { [UserDetails, UserSecondDetails] }
    
    it "loads and returns all the Friendly model instances associated with the record" do
      configuration.should_receive(:friendly_models).and_return(friendly_models)
      object.should_receive(DetailsDelegator.friendly_model_reader(UserDetails)).and_return(user_details)
      object.should_receive(DetailsDelegator.friendly_model_reader(UserSecondDetails)).and_return(user_second_details)
      object.all_friendly_instances.should == [user_details, user_second_details]
    end
  end
  
  describe "#present_friendly_instances" do
    let(:friendly_models) { [UserDetails, UserSecondDetails] }
    
    it "returns all the loaded Friendly model instances associated with the record" do
      configuration.should_receive(:friendly_models).and_return(friendly_models)
      object.should_receive(:friendly_instance_presence).with(UserDetails).and_return(user_details)
      object.should_receive(:friendly_instance_presence).with(UserSecondDetails).and_return(nil)
      object.present_friendly_instances.should == [user_details]
    end
  end
  
  describe "#friendly_details_build_options" do
    context "when friendly_details_build_options is not defined" do
      it "returns and empty Hash" do
        object.friendly_details_build_options.should == { }
        object.friendly_details_build_options(UserDetails).should == { }
      end
    end
    
    context "when friendly_details_build_options is defined" do
      let(:foo) { mock("default friendly details build option") }
      
      before(:each) do
        _foo = foo
        
        klass.class_eval do
          define_method(:friendly_details_build_options) do |klass|
            { :foo => _foo }
          end
        end
      end
      
      it "returns the options specified by friendly_details_build_options" do
        object.friendly_details_build_options(UserSecondDetails).should == { :foo => foo }
      end
    end
  end

  describe "#changed?" do
    subject { active_record.changed? }
    let(:active_record) { User.create(:name => "Stan", :email => "stan@example.com") }
    
    context "when the ActiveRecord model has changed," do
      before(:each) do
        active_record.email = "eric@example.com"
      end
      
      context "and the Friendly model has changed," do
        before(:each) do
          active_record.name = "Eric"
        end
        
        it { should be_true }
      end
      
      context "and the Friendly model has not changed" do
        it { should be_true }
      end
    end
    
    context "when the ActiveRecord model has not changed," do
      context "and the Friendly model has changed" do
        before(:each) do
          active_record.name = "Eric"
        end
        
        it { should be_true }
      end
      
      context "and the Friendly model has not changed" do
        it { should be_false }
      end
    end
  end
end
