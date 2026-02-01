require "rails_helper"

RSpec.describe User, type: :model do
  fixtures :users

  it "normalizes email address" do
    user = User.create!(
      email_address: " TeSt@Example.com ",
      password: "password"
    )

    expect(user.email_address).to eq("test@example.com")
  end

  it "requires an email address" do
    user = User.new(password: "password")

    expect(user).not_to be_valid
    expect(user.errors[:email_address]).to be_present
  end
end
