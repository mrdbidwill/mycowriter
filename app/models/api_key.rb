class ApiKey < ApplicationRecord
  belongs_to :user

  before_validation :generate_token, on: :create

  validates :name, presence: true
  validates :token, presence: true, uniqueness: true

  scope :active, -> { where(active: true).where("expires_at IS NULL OR expires_at > ?", Time.current) }

  # Check if the API key is valid
  def valid_key?
    active? && (expires_at.nil? || expires_at > Time.current)
  end

  # Update last used timestamp
  def touch_last_used!
    update_column(:last_used_at, Time.current)
  end

  # Revoke the API key
  def revoke!
    update(active: false)
  end

  private

  def generate_token
    loop do
      self.token = SecureRandom.hex(32)
      break unless ApiKey.exists?(token: token)
    end
  end
end
