class Ingredient < ApplicationRecord
  # Relationships
  belongs_to :recipe
  belongs_to :ingredient

  # Model Setup
  validates_presence_of :amount, :amountUnit, :recipe_id, :ingredient
end
