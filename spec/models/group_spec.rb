require "rails_helper"

RSpec.describe Group, type: :model do
  it "requires a name" do
    group = Group.new(name: "")

    expect(group).not_to be_valid
    expect(group.errors[:name]).to be_present
  end

  it "limits name length to 60 characters" do
    group = Group.new(name: "a" * 61)

    expect(group).not_to be_valid
    expect(group.errors[:name]).to be_present
  end
end
