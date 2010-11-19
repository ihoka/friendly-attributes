module DatabaseCleanerHelpers
  def use_database_cleanup
    before(:each) do
      DatabaseCleaner.start
    end
    
    after(:each) do
      DatabaseCleaner.clean
    end
  end
end
