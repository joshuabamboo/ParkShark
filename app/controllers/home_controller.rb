class HomeController < ApplicationController
  def index
  end

  def about
  end

  def contact
  end

  def resource_name
   :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def my_location

  end

  def set_location
    if current_user
      current_user.set_location(params[:latitude], params[:longitude])
    else
      session[:latitude] = params[:latitude]
      session[:longitude] = params[:longitude]
    end

  end
end
