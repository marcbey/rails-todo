class UsersController < ApplicationController
  allow_unauthenticated_access only: [ :new, :create ]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      start_new_session_for(@user)
      redirect_to root_path, notice: "Welcome to Railtalk."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def autocomplete
    query = params[:q].to_s.strip.downcase
    return render json: [] if query.length < 2

    emails = User.where("email_address LIKE ?", "#{query}%")
                 .order(:email_address)
                 .limit(5)
                 .pluck(:email_address)

    render json: emails
  end

  private
    def user_params
      params.require(:user).permit(:email_address, :password, :password_confirmation)
    end
end
