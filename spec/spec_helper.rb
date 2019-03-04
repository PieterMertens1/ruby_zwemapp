# This file is copied to spec/ when you run 'rails generate rspec:install'

# http://railscasts.com/episodes/257-request-specs-and-capybara
# http://everydayrails.com/2012/04/24/testing-series-rspec-requests.html

ENV["RAILS_ENV"] ||= 'test'
require 'simplecov'   
SimpleCov.start 'rails'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require "capybara/rspec"
require 'database_cleaner'
# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}


RSpec.configure do |config|
  config.include Rails.application.routes.url_helpers
  config.include Capybara::DSL
  config.color_enabled = true

  if ActiveRecord::Base.connection.adapter_name == "SQLite"
  # volgende blok voor sqlite tests
    config.before(:suite) do
      DatabaseCleaner.strategy = :transaction #transaction
      DatabaseCleaner.clean_with(:truncation) # truncation
    end

    config.before(:each) do
      DatabaseCleaner.start
    end

    config.after(:each) do
      DatabaseCleaner.clean
    end
  #config.use_transactional_fixtures = false
  else
  # voor postgresql testen (truncation voor models en controllers, transaction voor requests):
    config.before(:suite) do
      DatabaseCleaner.strategy = :truncation
      DatabaseCleaner.clean_with(:truncation)
    end
    config.before type: :request do
      DatabaseCleaner.strategy = :transaction
    end
   
    config.after type: :request  do
      DatabaseCleaner.strategy = :truncation
    end

    config.before(:each) do
      DatabaseCleaner.start
    end

    config.after(:each) do
      DatabaseCleaner.clean
    end
  end
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  #config.order = "random"
end
RSpec.configure do |config|
  config.include Devise::TestHelpers, :type => :controller
end

SimpleCov.configure do
  add_group "Pdfs", "app/pdfs"
end