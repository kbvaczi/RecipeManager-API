class Ingredient < ApplicationRecord
  # Relationships
  belongs_to :recipe, optional: true # optional must be true to allow nested attributes for recipe model
  belongs_to :base_ingredient, optional: true

  attr_accessor :name

  validates_presence_of :amount, :amountUnit

  after_create :linkToBaseIngredient

  def linkToBaseIngredient
    # TODO: implement linking to base ingredient after ingredient creation
    # TODO: Run this in a background task?
  end
  
end
