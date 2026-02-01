class MessagesController < ApplicationController
  before_action :set_group
  before_action :require_group_member!

  def create
    @message = @group.messages.new(message_params.merge(user: current_user))

    if @message.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "message_form",
            partial: "messages/form",
            locals: { group: @group, message: @group.messages.build }
          )
        end
        format.html { redirect_to @group }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "message_form",
            partial: "messages/form",
            locals: { group: @group, message: @message }
          ), status: :unprocessable_entity
        end
        format.html do
          @sidebar_groups = current_user.groups.order(:name)
          @memberships = @group.memberships.includes(:user).order(:created_at)
          @messages = @group.messages.includes(:user, files_attachments: :blob).order(:created_at)
          @membership = Membership.new
          render "groups/show", status: :unprocessable_entity
        end
      end
    end
  end

  private
    def set_group
      @group = Group.find(params[:group_id])
    end

    def require_group_member!
      return if @group.users.exists?(id: current_user.id)

      redirect_to groups_path, alert: "You do not have access to that group."
    end

    def message_params
      params.require(:message).permit(:body, files: [])
    end
end
