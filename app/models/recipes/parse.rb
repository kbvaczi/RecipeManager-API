class Recipes::Parse < ApplicationRecord

  # Table Setup
  self.table_name = 'recipe_parses'

  serialize :ingredients, Array
  serialize :directions, Array

  # Relations
  belongs_to :recipe, optional: true

  # Validations
  validates_presence_of :url

end
