class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :set_game_for_modal
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Pundit: allow-list approach
  after_action :verify_authorized, except: :index, unless: :skip_pundit?
  after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?

  before_action :configure_permitted_parameters, if: :devise_controller?
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def configure_permitted_parameters
    # For additional fields in app/views/devise/registrations/new.html.erb
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[username address])

    # For additional in app/views/devise/registrations/edit.html.erb
    devise_parameter_sanitizer.permit(:account_update, keys: %i[username address])
  end
  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  def after_sign_in_path_for(resource)
    root_path
  end

  def default_url_options
    { host: ENV["DOMAIN"] || "localhost:3000" }
  end

  private

  def user_not_authorized
    flash[:alert] = "Vous n'êtes pas autorisé à effectuer cette action."
    redirect_to games_path
  end

  def broadcast_notifs_to(user)
    Turbo::StreamsChannel.broadcast_replace_to(
      "user_#{user.id}_notifs",
      target: "actions_attentes",
      html: render_to_string(
        partial: "shared/actions_attentes",
        locals: { user: user.reload }
      )
    )
  end

  def broadcast_flash_to(user, message)
    Turbo::StreamsChannel.broadcast_prepend_to(
      "user_#{user.id}_flash",
      target: "flash_notifications",
      partial: "shared/flash_notif",
      locals: { message: message }
    )
  end

  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)|(^chats$)/
  end

  def set_game_for_modal
    @game ||= Game.new
  end
end
