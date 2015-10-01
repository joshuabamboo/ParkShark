class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:update, :edit, :delete]
  before_action :find_user, only: [:show, :update, :edit]
  before_action :correct_user?, only: [:edit]

  def index
    @users = User.order('created_at DESC').paginate(page: params[:page], per_page: 30)
  end

  def show
  end

  def update
    if @user.update(user_params)
      flash[:notice] = 'Your profile was updated successfully!'
    else
      flash[:error] = 'Sorry, something went wrong when updating your profile.'
    end
    redirect_to user_path(@user)
  end

  def edit
  end

  def user_spots
    @user = User.find(params[:user_id])
    @spots = @user.spots
    @title = 'My Spots'
    @subtitle = 'View your listings below.'
  end

  private

  def user_params
    params.require(:user).permit(:avatar, :name, :gender, :email, :phone, :location, :bio, :birthday)
  end

  def find_user
    @user = User.find(params[:id])
  end

  def correct_user?
    redirect_to user_path(current_user) unless current_user?
  end
end
