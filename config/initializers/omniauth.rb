Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env == 'development'
    provider :facebook,"139667929509694","5f83c77819cb10d30efc8b059dff557e"
  else
    provider :facebook,"497617283600374","3feecda36b439da7eaf2aa7c4cab2873"
  end
end

OmniAuth.config.on_failure = SessionsController.action(:oauth_failure)
