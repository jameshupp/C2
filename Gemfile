source "https://rubygems.org"
ruby "2.2.3" # this should match `.ruby-version` and docs/setup.md

gem "active_model_serializers"
gem "activeadmin", git: "https://github.com/activeadmin/activeadmin.git"
gem "activeadmin_hstore_editor"
gem "acts_as_list"
gem "acts-as-taggable-on", "~> 3.4"
gem "ahoy_matey"
gem "ar_outer_joins"
gem "autoprefixer-rails"
gem "awesome_print"
gem "aws-sdk"
gem "bootstrap-sass"
gem "browser-timezone-rails"
gem "blazer"
gem "climate_control"
gem "clockwork", require: false
gem "daemons" # for delayed_job
gem "delayed_job_active_record"
gem "dotenv-rails", require: "dotenv/rails-now"
gem "draper"
gem "kaminari"
gem "kaminari-bootstrap", "~> 3.0.1"
gem "elasticsearch-dsl"
gem "elasticsearch-model"
gem "elasticsearch-rails"
gem "elasticsearch-rails-ha", "~> 1.0.5"
gem "email_reply_parser"
gem "factory_girl_rails"
gem "faker"
gem "font-awesome-sass"
gem "foreman", require: false
gem "has_secure_token"
gem "haml"
gem "hashdiff"
gem "html_pipeline_rails"
gem "jquery-rails"
gem "jquery-turbolinks"
gem "mandrill-rails"
gem "newrelic_rpm"
gem "omniauth-myusa"
gem "paper_trail"
gem "paperclip", git: "https://github.com/thoughtbot/paperclip.git"
gem "peek"
gem "peek-delayed_job"
gem "peek-performance_bar"
gem "peek-pg"
gem "pg"
gem "puma"
gem "pundit", ">= 1.0.0"  # Interface for Pundit::NotAuthorizedError changed in this version
gem "rack-cors", require: "rack/cors"
gem "rails"
gem "redcarpet"
gem "roadie-rails"
gem "sass-rails", ">= 3.2"
gem "simple_form"
gem "simple_form_object"
gem "sprockets-rails", "< 3" # https://github.com/jfirebaugh/konacha/issues/216
gem "turbolinks"
gem "uglifier"
gem "validates_email_format_of"
gem "workflow"

group :test, :development do
  gem "bullet", require: false # use BULLET_ENABLED=true
  gem "database_cleaner"
  gem "konacha"
  gem "pry-byebug"
  gem "pry-rails"
  gem "rspec-rails"
  gem "rack_session_access"
end

group :development do
  gem "guard-rspec", require: false
  gem "guard-shell", require: false
  gem "railroady"
  gem "letter_opener"
  gem "letter_opener_web"
  gem "quiet_assets"
  gem "spring"
  gem "spring-commands-rspec"
end

group :test do
  gem "addressable"
  gem "capybara"
  gem "codeclimate-test-reporter"
  gem "elasticsearch-extensions"
  gem "poltergeist"
  gem "shoulda-matchers"
  gem "simplecov"
  gem "site_prism"
  gem "timecop"
  gem "webmock", require: false
  gem "zonebie"

  # For better test reporting in CircleCI
  # http://blog.circleci.com/announcing-detailed-test-failure-reporting/
  gem "rspec_junit_formatter"
end

group :production do
  gem "rails_12factor"
end
