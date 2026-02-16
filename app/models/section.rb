class Section < ApplicationRecord
  belongs_to :article
  has_many :paragraphs, -> { order(position: :asc) }, dependent: :destroy

  # Acts as list for reordering sections within an article
  acts_as_list scope: :article

  validates :title, presence: true

  accepts_nested_attributes_for :paragraphs, allow_destroy: true
end
