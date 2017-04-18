require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ScreamingDinosaur
  class Application < Rails::Application
    config.generators do |g|
      g.assets          false
      g.helpers         false
      g.stylesheets     false
      g.template_engine :haml
      g.test_framework  :rspec
    end
    config.encoding = 'utf-8'
    config.time_zone = 'Eastern Time (US & Canada)'
    config.filter_parameters += [:password, :spire, :secret, :github]
    config.active_record.raise_in_transactional_callbacks = true
  end
end
