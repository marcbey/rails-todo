require "rails_helper"

RSpec.describe Message, type: :model do
  fixtures :users, :groups

  it "requires body or files" do
    message = Message.new(group: groups(:one), user: users(:one))

    expect(message).not_to be_valid
    expect(message.errors[:base]).to include("Message must include text or a file.")
  end

  it "is valid with a body" do
    message = Message.new(
      group: groups(:one),
      user: users(:one),
      body: "Hello"
    )

    expect(message).to be_valid
  end
end
