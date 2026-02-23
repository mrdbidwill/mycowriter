class MbList < ApplicationRecord
  validates :taxon_name, presence: true

  # Search for genus or species names (for autocomplete)
  # rank_name values from MycoBank: 'gen.' for genus, 'sp.' for species
  # Only return legitimate names (exclude illegitimate/invalid names)
  scope :search_by_name, ->(query) {
    where("taxon_name LIKE ?", "#{sanitize_sql_like(query.capitalize)}%")
      .where("rank_name IN ('gen.', 'sp.', 'Genus', 'Species') OR rank_name LIKE '%gen%' OR rank_name LIKE '%sp%'")
      .where(name_status: 'Legitimate')
      .limit(20)
      .order(:taxon_name)
  }
end
