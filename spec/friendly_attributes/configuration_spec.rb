require 'spec_helper'

describe FriendlyAttributes::Configuration do
  subject { configuration }
  
  let(:configuration) { FriendlyAttributes::Configuration.new(active_record_model) }
  let(:active_record_model) { User }
  
  describe "#initialize" do
    its(:model) { should == active_record_model }
    its(:details_delegators) { should == [] }
  end
  
  describe "#add" do
    let(:delegator) { mock(FriendlyAttributes::DetailsDelegator) }
    
    it "adds a delegator to the details_delegators collection" do
      configuration.add(delegator)
      configuration.details_delegators.should include(delegator)
    end
  end
  
  describe "#model_names" do
    let(:friendly_model_names) { [:user_details, :user_second_details] }
    let(:details_delegators) { friendly_model_names.map { |fmn| mock(FriendlyAttributes::DetailsDelegator, :friendly_model_name => fmn) } }
    
    before(:each) do
      details_delegators.each do |delegator|
        configuration.add(delegator)
      end
    end
    
    its(:model_names) { should == friendly_model_names }
  end
  
  describe "Configuration with delegators added" do
    let(:friendly_models) { [UserDetails, UserSecondDetails] }
    let(:details_delegators) { friendly_models.map { |fm| mock(FriendlyAttributes::DetailsDelegator, :friendly_model => fm) } }
    
    before(:each) do
      details_delegators.each do |delegator|
        configuration.add(delegator)
      end
    end
    
    describe "#friendly_models" do
      its(:friendly_models) { should == friendly_models }
    end
    
    describe "#map_models" do
      let(:model_map) {
        {}.tap do |h|
          friendly_models.each do |m|
            h[m] = mock()
          end
        end
      }

      it "maps over the friendly models" do
        configuration.map_models do |model|
          model_map[model]
        end.should == model_map.values
      end
    end
    
    describe "#each_model" do
      let(:model_map) {
        {}.tap do |h|
          friendly_models.each do |m|
            h[m] = mock()
          end
        end
      }

      it "iterates over the friendly models" do
        result = []
        configuration.each_model do |model|
          result << model_map[model]
        end
        result.should == model_map.values
      end
    end
  end
end
