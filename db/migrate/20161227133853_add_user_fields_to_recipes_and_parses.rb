class AddUserFieldsToRecipesAndParses < ActiveRecord::Migration[5.0]
  def change
    add_reference :recipes, :user, type: :uuid, index: true
    add_foreign_key :recipes, :users

    add_reference :recipe_parses, :user, type: :uuid, index: true
    add_foreign_key :recipe_parses, :users
  end
end
