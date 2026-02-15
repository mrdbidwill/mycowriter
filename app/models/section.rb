class Section < ApplicationRecord
  belongs_to :book
  has_many :paragraphs, -> { order(position: :asc) }, dependent: :destroy

  validates :title, presence: true
  validates :position, presence: true

  accepts_nested_attributes_for :paragraphs, allow_destroy: true

  before_validation :set_position, on: :create

  private

  def set_position
    return if position.present?
    self.position = book.sections.maximum(:position).to_i + 1
  end
end
