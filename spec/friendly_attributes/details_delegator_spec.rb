require 'spec_helper'

describe FriendlyAttributes::DetailsDelegator do
  DetailsDelegator = FriendlyAttributes::DetailsDelegator
  
  let(:details_delegator) { FriendlyAttributes::DetailsDelegator.new(friendly_model, ar_model, attributes, options, &initializer) }
  let(:initializer)       { proc {} }
  let(:attributes)        { {} }
  let(:options)           { {} }
  
  let(:friendly_model)    { mock_friendly_model }
  let(:ar_model)          { Class.new { include ActiveRecordFake } }
  
  let(:ar_instance)       { ar_model.new(:id => 42) }
  let(:friendly_instance) { mock(friendly_model) }
  
  describe "class methods" do
    describe ".friendly_model_name" do
      it { DetailsDelegator.friendly_model_name(UserDetails).should == :user_details }
    end
    
    describe ".friendly_model_ivar" do
      it { DetailsDelegator.friendly_model_ivar(:user_details).should == :@user_details_ivar }
    end
    
    describe ".friendly_model_reader" do
      it { DetailsDelegator.friendly_model_reader(:user_details).should == :load_user_details }
      it { DetailsDelegator.friendly_model_reader(UserDetails).should == :load_user_details }
    end
  end
  
  describe "initialization" do
    shared_examples_for "DetailsDelegator initialization" do
      context "DetailsDelegator attr_readers" do
        subject { details_delegator }
        
        before(:each) do
          details_delegator
        end
        
        its(:active_record_model) { should == ar_model }
        its(:friendly_model)      { should == friendly_model }
        its(:friendly_model_name) { should == DetailsDelegator.friendly_model_name(friendly_model) }
        its(:attributes)          { should == attributes }        
      end
      
      context "#setup_delegated_attributes" do
        let(:attributes) do
          {
            String  => :foo,
            Integer => [:bar, :baz]
          }
        end
        
        it "delegates the attributes passed in the options" do
          details_delegator.should_receive(:delegated_attribute).with(:foo, String)
          details_delegator.should_receive(:delegated_attribute).with(:bar, Integer)
          details_delegator.should_receive(:delegated_attribute).with(:baz, Integer)
          details_delegator.setup_delegated_attributes
        end
      end
      
      context "the Friendly model" do
        before(:each) do
          details_delegator
        end

        it "includes Friendly::Document" do
          friendly_model.ancestors.should include(Friendly::Document)
        end
        
        context "with defaults" do
          it "adds the active_record_id attribute" do
            friendly_model.attributes.should include(:active_record_id)
          end

          it "adds an index to active_record_id" do
            friendly_model.storage_proxy.index_for_fields([:active_record_id]).should be_an_instance_of(Friendly::Index)
          end
          
          it "sets the active_record_key" do
            friendly_model.active_record_key.should == :active_record_id
          end
        end
        
        context "with options" do
          let(:options) { { :active_record_key => :user_id } }
          
          it "adds the active_record_id attribute" do
            friendly_model.attributes.should include(:user_id)
          end

          it "adds an index to active_record_id" do
            friendly_model.storage_proxy.index_for_fields([:user_id]).should be_an_instance_of(Friendly::Index)
          end
          
          it "sets the active_record_key" do
            friendly_model.active_record_key.should == :user_id
          end
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

        describe "friendly model reader method" do
          before(:each) do
            details_delegator
          end

          it "is defined" do
            ar_instance.should respond_to(DetailsDelegator.friendly_model_reader(friendly_model))
          end

          it "finds or builds and memoizes the associated Friendly model" do
            ar_instance.should_receive(:find_or_build_and_memoize_details).with(friendly_model)
            ar_instance.send(DetailsDelegator.friendly_model_reader(friendly_model))
          end
        end
      
        describe "cattr_accessor friendly_attributes_configuration" do
          context "when no Configuration exists" do
            it "creates and assigns a new Configuration with the delegator added" do
              details_delegator
              
              ar_model.friendly_attributes_configuration.should be_an_instance_of(FriendlyAttributes::Configuration)
              ar_model.friendly_attributes_configuration.friendly_models.should == [friendly_model]
            end
          end
          
          context "when Configuration already exists" do
            let(:existing_details_delegator) { FriendlyAttributes::DetailsDelegator.new(other_friendly_model, ar_model, attributes, options, &initializer) }
            let(:other_friendly_model) { mock_friendly_model }
            
            before(:each) do
              existing_details_delegator
            end
            
            it "adds to the existing configuration" do
              existing_configuration = ar_model.friendly_attributes_configuration
              
              expect do
                details_delegator
              end.to change { ar_model.friendly_attributes_configuration.friendly_models }.
                     from([other_friendly_model]).
                     to([other_friendly_model, friendly_model])
              
              ar_model.friendly_attributes_configuration.should == existing_configuration
            end
          end
        end
      end
    end
    
    context "missing initialization block" do
      let(:details_delegator) { FriendlyAttributes::DetailsDelegator.new(friendly_model, ar_model, attributes, options) }
      it_should_behave_like "DetailsDelegator initialization"
    end
  end
  
  describe "#delegated_method" do
    before(:each) do
      details_delegator
      details_delegator.delegated_method(:some_method)
      ar_instance.stub(DetailsDelegator.friendly_model_reader(friendly_model) => friendly_instance)
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
      ar_instance.stub(DetailsDelegator.friendly_model_reader(friendly_model) => friendly_instance)
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
