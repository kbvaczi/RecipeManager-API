class RecipeParse < ApplicationRecord

  serialize :ingredients, Array
  serialize :directions, Array

  # Relations
  belongs_to :recipe, optional: true
  belongs_to :user, optional: true

  # Validations
  validates_presence_of :url

end
