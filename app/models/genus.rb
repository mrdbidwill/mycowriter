class Genus < ApplicationRecord
  self.table_name = "genera"

  has_many :species, foreign_key: :genera_id, dependent: :destroy
end
