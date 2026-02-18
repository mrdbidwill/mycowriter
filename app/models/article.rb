class Article < ApplicationRecord
  belongs_to :user, optional: true  # Made optional temporarily for existing records
  has_many :sections, -> { order(position: :asc) }, dependent: :destroy

  validates :title, presence: true
  validates :body, length: { maximum: 16777215, message: "is too long (maximum is 16 million characters)" }, allow_blank: true

  accepts_nested_attributes_for :sections, allow_destroy: true
end
