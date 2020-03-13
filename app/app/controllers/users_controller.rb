class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy, :lock, :unlock]
  before_action :authenticate_admin!

  # GET /users
  def index
    @users = User.all

    render json: @users
  end

  # GET /users/1
  def show
    render json: @user
  end

  # DELETE /users/1
  def destroy
    @user.destroy
  end

  # POST /users/1/lock
  def lock
    if @user.update(failed_attempts:100, locked_at: Time.now.utc)
      NotificationMailer.send_account_locks(@user).deliver
      render json: @user
    else
      render json: @user.errors, status: :internal_server_error
    end
  end

  # POST /users/1/unlock
  def unlock
    if @user.update(failed_attempts:0, locked_at: nil)
      NotificationMailer.send_account_unlocks(@user).deliver
      render json: @user
    else
      render json: @user.errors, status: :internal_server_error
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # # Only allow a trusted parameter "white list" through.
    # def user_params
    #   params.require(:user).permit(:name)
    # end
end
