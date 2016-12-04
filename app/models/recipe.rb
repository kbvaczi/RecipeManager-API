class Recipe < ApplicationRecord
  # Relations
  has_many :ingredients
  has_many :base_ingredients, through: :ingredients

  # Model Setup  
  validates_presence_of :name, :ingredients

end
