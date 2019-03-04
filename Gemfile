source 'https://rubygems.org'
ruby "1.9.3"

gem 'rails', '3.2.13'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'
gem 'sass', '3.3.14'
gem 'sass-rails'
gem 'bootstrap-sass', '~> 2.3.0.0'
gem 'devise'
 gem 'bootstrap-colorpicker-rails', '0.1'
 gem 'prawn', '1.3.0' #, '1.0.0.rc2'
 gem 'prawn-table'
 gem 'spreadsheet'
 gem 'cancan'
 #gem 'rubyzip', '0.9.9'  # tot opgelost (vanaf 1/09/13): https://github.com/rubyzip/rubyzip/issues/90
 gem "rubyzip", "1.1.0"
 gem 'simple_form'
 gem 'lazy_high_charts','1.5.0.beta1'
 gem 'acts_as_list'
 gem 'similar_text'
 gem 'coffee-script-source', '1.8.0' # http://stackoverflow.com/questions/28312460/object-doesnt-support-this-property-or-method-rails-windows-64bit
group :development do
  gem 'annotate', '2.5.0'
  gem 'sqlite3'
  gem 'better_errors', '1.1.0'
  gem 'binding_of_caller'
  gem 'meta_request', '> 0.2.1'
  gem "bullet"
end
group :production do
  gem 'pg', '0.17.0'  #moet dringend naar ubuntu migreren
  gem 'thin'
end
# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails', '~> 3.2.1'
  gem 'jquery-ui-rails'
  gem 'jquery-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'
end

group :development, :test do
  gem 'rspec-rails', '2.14.2'
  gem 'factory_girl_rails'
end

group :test do
  gem 'faker', '1.3.0'
  gem 'capybara', '2.0.2'
  gem 'launchy'
  gem 'database_cleaner'#, '1.0.1' # https://github.com/gregbell/active_admin/issues/2388
  gem "shoulda-matchers"
  gem 'simplecov'  
  gem 'timecop'
  gem 'xpath', '1.0.0'
  #gem "selenium-webdriver", '2.32.1' # 2.33.0 ondersteunt aanvinken in testinvulpagina niet
  # 2.38 werkt, maar sluit zeer moeizaam de accordeon in tst view
  gem 'selenium-webdriver', '2.38.0'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
