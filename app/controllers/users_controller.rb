class UsersController < ApplicationController
  before_action :set_user, only: %i[ show feed discover follows followers pending ]
  before_action :must_be_owner_to_view, only: %i[ feed discover pending ]

  def index
    @users = @q.result
  end

  def show
  end

  def feed
    @photos = @user.feed
  end

  def discover
    @photos = @user.discover
  end

  def follows
    @follows = @user.leaders
  end

  def followers
    @followers = @user.followers
  end

  def pending
    @pending = @user.pending_received_follow_requests
  end

  private

    def set_user
      if params[:username]
        @user = User.find_by!(username: params.fetch(:username))
      else
        @user = current_user
      end
    end

    def must_be_owner_to_view
      if current_user != @user
        redirect_back fallback_location: root_url, alert: "You're not authorized for that."
      end
    end
end
