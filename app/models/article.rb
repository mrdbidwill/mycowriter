class Article < ApplicationRecord
  belongs_to :user, optional: true  # Made optional temporarily for existing records
  has_many :sections, -> { order(position: :asc) }, dependent: :destroy

  validates :title, presence: true, profanity: true
  validates :description, profanity: true, allow_blank: true
  validates :body, profanity: true, allow_blank: true

  accepts_nested_attributes_for :sections, allow_destroy: true
end
