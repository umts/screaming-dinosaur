# frozen_string_literal: true

# ActiveAdmin controllers descend from AdminController rather than
# ApplicationController so they bypass Authorizable's verify_authorized.
InheritedResources.parent_controller = 'AdminController'

ActiveAdmin.setup do |config|
  config.site_title = 'UMTS On-Call'

  # Entra ID sessions instead of Devise: any logged-in app admin may enter.
  config.authentication_method = :authenticate_admin_user!
  config.current_user_method = :current_admin_user
  config.logout_link_path = :logout_path

  # Commenting would need its own table (and audit trail is PaperTrail's job).
  config.comments = false

  config.filter_attributes = %i[calendar_access_token]
end
