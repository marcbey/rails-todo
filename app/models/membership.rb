class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :group

  enum :role, { member: "member", owner: "owner" }, prefix: true

  validates :user_id, uniqueness: { scope: :group_id }

  after_commit :broadcast_members, on: [ :create, :destroy ]

  private
    def broadcast_members
      memberships = group.memberships.includes(:user).order(:created_at)

      broadcast_replace_to(
        [ group, :members ],
        target: "members_list",
        partial: "memberships/list",
        locals: { group: group, memberships: memberships }
      )

      broadcast_update_to(
        [ group, :members ],
        target: "member_count",
        partial: "memberships/count",
        locals: { count: memberships.size }
      )
    end
end
