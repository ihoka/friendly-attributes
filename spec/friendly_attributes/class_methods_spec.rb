require 'spec_helper'

describe FriendlyAttributes::ClassMethods do
  let(:friendly_model)    { Class.new }
  let(:ar_model)          {
    Class.new {
      include ActiveRecordFake
      extend FriendlyAttributes::ClassMethods
    }
  }
  let(:initializer)       { proc {} }
  let(:details_delegator) { mock(FriendlyAttributes::DetailsDelegator) }
  
  class FakeUploader; end
  
  describe ".friendly_details" do
    let(:attributes) do
      {
        String  => :foo,
        Integer => [:bar, :baz]
      }
    end
    
    before(:each) do
      details_delegator.stub(:delegated_attribute)
    end
    
    context "with an initializer block" do
      it "instantiates a new DetailsDelegator" do
        FriendlyAttributes::DetailsDelegator.should_receive(:new).with(friendly_model, ar_model, {}, &initializer).and_return(details_delegator)
        ar_model.friendly_details(friendly_model, &initializer).should == details_delegator
      end
    end
    
    context "with an initializer block and attributes" do
      before(:each) do
        FriendlyAttributes::DetailsDelegator.stub(:new => details_delegator)
      end
      
      def do_details
        ar_model.friendly_details(friendly_model, attributes, &initializer).should == details_delegator
      end
      
      it "instantiates a new DetailsDelegator" do
        FriendlyAttributes::DetailsDelegator.should_receive(:new).with(friendly_model, ar_model, {}, &initializer).and_return(details_delegator)
        do_details
      end
      
      it "delegates the attributes passed in the options" do
        details_delegator.should_receive(:delegated_attribute).with(:foo, String)
        details_delegator.should_receive(:delegated_attribute).with(:bar, Integer)
        details_delegator.should_receive(:delegated_attribute).with(:baz, Integer)
        do_details
      end
    end
    
    context "with attributes and options" do
      let(:options) { { :active_record_key => :user_id } }
      
      before(:each) do
        FriendlyAttributes::DetailsDelegator.stub(:new => details_delegator)
      end
      
      def do_details
        ar_model.friendly_details(friendly_model, attributes, options).should == details_delegator
      end
      
      it "instantiates a new DetailsDelegator" do
        FriendlyAttributes::DetailsDelegator.should_receive(:new).with(friendly_model, ar_model, options, &initializer).and_return(details_delegator)
        do_details
      end
    end
    
    context "without a block" do
      it "instantiates a new DetailsDelegator" do
        FriendlyAttributes::DetailsDelegator.should_receive(:new).with(friendly_model, ar_model, {}).and_return(details_delegator)
        ar_model.friendly_details(friendly_model, attributes).should == details_delegator
      end
    end
  end
  
  describe ".friendly_mount_uploader" do
    let(:foo_value) { mock("Friendly attribute value") }
    
    before(:each) do
      ar_model.stub(:mount_uploader => nil)
      
      foo = foo_value
      
      ar_model.class_eval do
        define_method(:read_friendly_attribute) do |attribute|
          attribute.should == :foo
          foo
        end
        
        define_method(:write_friendly_attribute) do |attribute, value|
          value.tap do
            attribute.should == :foo
            value.should == foo
          end
        end
      end
    end
    
    it "mounts the uploader" do
      ar_model.should_receive(:mount_uploader).with(:foo, FakeUploader)
      ar_model.friendly_mount_uploader :foo, FakeUploader
    end
    
    it "aliases #read_friendly_attribute to #read_uploader" do
      ar_model.friendly_mount_uploader :foo, FakeUploader
      ar_object = ar_model.new
      
      ar_object.read_uploader(:foo).should == foo_value
    end
    
    it "aliases #read_friendly_attribute to #read_uploader" do
      ar_model.friendly_mount_uploader :foo, FakeUploader
      ar_object = ar_model.new
      
      ar_object.write_uploader(:foo, foo_value).should == foo_value
    end
  end
end
