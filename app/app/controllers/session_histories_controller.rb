class SessionHistoriesController < ApplicationController
  before_action :authenticate_admin!

  # GET /session_histories
  def index
    @session_histories = SessionHistory.all

    render json: @session_histories
  end
end
