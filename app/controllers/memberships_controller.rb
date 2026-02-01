class MembershipsController < ApplicationController
  before_action :set_group
  before_action :require_owner!

  def create
    @membership = @group.memberships.new
    @membership.user = User.find_by(email_address: normalized_email)

    if @membership.user.nil?
      @member_error = "No user found with that email."
      respond_with_membership_form(status: :unprocessable_entity)
      return
    end

    if @membership.save
      respond_with_membership_form
    else
      @member_error = @membership.errors.full_messages.to_sentence
      respond_with_membership_form(status: :unprocessable_entity)
    end
  end

  def destroy
    membership = @group.memberships.find(params[:id])
    membership.destroy unless membership.role_owner? && membership.user_id == current_user.id

    respond_with_membership_form
  end

  private
    def set_group
      @group = Group.find(params[:group_id])
    end

    def require_owner!
      membership = @group.memberships.find_by(user_id: current_user.id)
      return if membership&.role_owner?

      redirect_to @group, alert: "Only group owners can manage members."
    end

    def normalized_email
      params[:email_address].to_s.strip.downcase
    end

    def respond_with_membership_form(status: :ok)
      memberships = @group.memberships.includes(:user).order(:created_at)

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(
              "members_list",
              partial: "memberships/list",
              locals: { group: @group, memberships: memberships }
            ),
            turbo_stream.replace(
              "member_form",
              partial: "memberships/form",
              locals: { group: @group, membership: Membership.new, member_error: @member_error }
            )
          ], status: status
        end
        format.html do
          redirect_to @group, alert: @member_error
        end
      end
    end
end
