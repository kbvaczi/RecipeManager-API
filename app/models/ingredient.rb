class Ingredient < ApplicationRecord
  # Relationships
  belongs_to :recipe, optional: true # optional must be true to allow nested attributes for recipe model
  belongs_to :base_ingredient, optional: true

  validates_presence_of :amount, :amountUnit
end
