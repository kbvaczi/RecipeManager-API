class Recipe < ApplicationRecord

  # Relations
  has_many :ingredients
  has_many :base_ingredients, through: :ingredients
  has_one  :recipe_parse, class_name: "Recipe::Parse", dependent: :destroy

  # Model Setup  
  validates_presence_of :name, :ingredients

end
