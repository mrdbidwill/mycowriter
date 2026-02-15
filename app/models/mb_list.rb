class MbList < ApplicationRecord
  validates :taxon_name, presence: true

  # Search for genus or species names (for autocomplete)
  scope :search_by_name, ->(query) {
    where("taxon_name LIKE ?", "#{query}%")
      .where(rank_name: ['Genus', 'Species'])
      .limit(20)
      .order(:taxon_name)
  }
end
