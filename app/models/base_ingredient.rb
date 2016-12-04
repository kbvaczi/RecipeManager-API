class BaseIngredient < ApplicationRecord
  has_many :ingredients
  has_many :recipes, through: :ingredients

  validates_presence_of :name
  validates_uniqueness_of :name
end
