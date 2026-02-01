require "rails_helper"

RSpec.describe Membership, type: :model do
  fixtures :users, :groups, :memberships

  it "enforces unique user per group" do
    membership = Membership.new(
      user: users(:one),
      group: groups(:one),
      role: "member"
    )

    expect(membership).not_to be_valid
    expect(membership.errors[:user_id]).to be_present
  end

  it "accepts valid roles" do
    membership = Membership.new(
      user: users(:one),
      group: groups(:two),
      role: "owner"
    )

    expect(membership).to be_valid
  end
end
