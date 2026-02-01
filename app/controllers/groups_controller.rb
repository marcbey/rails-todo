class GroupsController < ApplicationController
  before_action :set_group, only: [ :show ]
  before_action :require_group_member!, only: [ :show ]

  def index
    @groups = current_user.groups.order(:name)
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)

    if @group.save
      @group.memberships.create!(user: current_user, role: "owner")
      redirect_to @group, notice: "Group created."
    else
      @groups = current_user.groups.order(:name)
      render :index, status: :unprocessable_entity
    end
  end

  def show
    @sidebar_groups = current_user.groups.order(:name)
    @memberships = @group.memberships.includes(:user).order(:created_at)
    @messages = @group.messages.includes(:user, files_attachments: :blob).order(:created_at)
    @message = @group.messages.build
    @membership = Membership.new
  end

  private
    def set_group
      @group = Group.find(params[:id])
    end

    def require_group_member!
      return if @group.users.exists?(id: current_user.id)

      redirect_to groups_path, alert: "You do not have access to that group."
    end

    def group_params
      params.require(:group).permit(:name)
    end
end
