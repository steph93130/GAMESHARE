class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: :home
  def home
    @last_games = policy_scope(Game)
                  .where(available: true)
                  .order(created_at: :desc)
                  .limit(3)
  end
end
