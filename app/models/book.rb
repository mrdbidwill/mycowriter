class Book < ApplicationRecord
  has_many :sections, -> { order(position: :asc) }, dependent: :destroy

  validates :title, presence: true

  accepts_nested_attributes_for :sections, allow_destroy: true
end
