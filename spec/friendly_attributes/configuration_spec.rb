require 'spec_helper'

describe FriendlyAttributes::Configuration do
  subject { configuration }
  
  let(:configuration) { FriendlyAttributes::Configuration.new(active_record_model) }
  let(:active_record_model) { User }
  
  describe "#initialize" do
    its(:model)              { should == active_record_model }
    its(:details_delegators) { should == [] }
    its(:attributes)         { should == {} }
  end
  
  describe "#add" do
    let(:delegator) { mock(FriendlyAttributes::DetailsDelegator, :delegated_attributes => delegated_attributes, :friendly_model => UserDetails) }
    let(:delegated_attributes) { { :foo => Integer, :bar => String } }
    
    it "adds a delegator to the details_delegators collection" do
      configuration.add(delegator)
      configuration.details_delegators.should == [delegator]
    end
  end
  
  describe "#add_attribute" do
    it "adds the attribute to the attributes collection" do
      configuration.add_attribute(:foo, UserDetails)
      configuration.attributes.should == { :foo => UserDetails }
    end
  end
  
  describe "Configuration with delegators added" do
    let(:friendly_models)      { [UserDetails, UserSecondDetails] }
    let(:delegated_attributes) {
      {
        UserDetails => { :foo => Integer, :bar => String },
        UserSecondDetails => { :baz => Date }
      }
    }
    let(:details_delegators) {
      friendly_models.map do |fm|
        mock(FriendlyAttributes::DetailsDelegator,
          :friendly_model => fm,
          :delegated_attributes => delegated_attributes[fm])
      end
    }
    
    before(:each) do
      details_delegators.each do |delegator|
        configuration.add(delegator)
      end
    end
    
    describe "#model_for_attribute" do
      it "returns the FriendlyAttributes model associated with the attribute" do
        configuration.add_attribute(:foo, UserDetails)
        configuration.model_for_attribute(:foo).should == UserDetails
      end
    end
    
    describe "#friendly_models" do
      its(:friendly_models) { should == friendly_models }
    end
    
    describe "#map_models" do
      let(:map_model_map) {
        {}.tap do |h|
          friendly_models.each_with_index do |m, i|
            h[m] = i
          end
        end
      }

      it "maps over the friendly models" do
        configuration.map_models do |model|
          map_model_map[model]
        end.sort.should == map_model_map.values.sort
      end
    end
    
    describe "#each_model" do
      let(:each_model_map) {
        {}.tap do |h|
          friendly_models.each_with_index do |m, i|
            h[m] = i
          end
        end
      }

      it "iterates over the friendly models" do
        result = []
        configuration.each_model do |model|
          result << each_model_map[model]
        end
        result.sort.should == each_model_map.values.sort
      end
    end
  end
end
