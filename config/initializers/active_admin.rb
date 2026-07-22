# frozen_string_literal: true

# ActiveAdmin controllers descend from AdminController, which wraps the engine
# in the app's authorization framework (Authorizable) the same way
# MaintenanceTasks does.
InheritedResources.parent_controller = 'AdminController'

ActiveAdmin.setup do |config|
  config.site_title = 'UMTS On-Call'

  # AdminController gates every action via `before_action :authorize!`, so
  # ActiveAdmin's own authentication is disabled.
  config.authentication_method = false
  config.current_user_method = :current_admin_user
  config.logout_link_path = :logout_path

  # Commenting would need its own table (and audit trail is PaperTrail's job).
  config.comments = false

  config.filter_attributes = %i[calendar_access_token]
end
