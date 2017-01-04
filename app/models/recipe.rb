class Recipe < ApplicationRecord

  # Relations
  has_many :ingredients
  has_many :base_ingredients, through: :ingredients
  has_one  :recipe_parse, dependent: :destroy
  accepts_nested_attributes_for :ingredients

  # Fields
  attr_accessor :recipe_parse_id
  serialize :directions, Array

  # Validations
  validates_presence_of :name, :ingredients

  # Callbacks
  before_create :assign_recipe_parse

  # Model Methods
  def assign_recipe_parse
    if self.recipe_parse_id.present?
      recipeParseChild = RecipeParse.find(self.recipe_parse_id)
      self.recipe_parse = recipeParseChild if recipeParseChild.present?
    end
  end

end
