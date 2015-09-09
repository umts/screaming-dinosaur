require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module GarrulousGarbanzo
  class Application < Rails::Application
    config.generators do |g|
      g.assets          false
      g.helpers         false
      g.stylesheets     false
      g.template_engine :haml
      g.test_framework  :rspec
    end
  end
end
