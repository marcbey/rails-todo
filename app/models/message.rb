class Message < ApplicationRecord
  belongs_to :group
  belongs_to :user

  has_many_attached :files

  validate :body_or_files_present

  after_create_commit -> { broadcast_append_to group, target: "messages" }

  private
    def body_or_files_present
      return if body.present? || files.attached?

      errors.add(:base, "Message must include text or a file.")
    end
end
