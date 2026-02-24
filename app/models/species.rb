class Species < ApplicationRecord
  belongs_to :genus, class_name: "Genus", foreign_key: "genera_id"
end
