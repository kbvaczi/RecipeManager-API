class CreateRecipesAndIngredients < ActiveRecord::Migration[5.0]
  def change
    create_table :recipes, id: :uuid do |t|
      t.string :name
      t.string :sourceURL
      t.text   :instructions

      t.timestamps
    end

    create_table :base_ingredients, id: :uuid do |t|
      t.string :name
      t.string :category

      t.timestamps
    end

    create_table :ingredients, id: :uuid do |t|
      t.integer :recipe_id
      t.integer :ingredient_id

      t.decimal :amount
      t.string  :amountUnit

      t.string  :descriptionModifier
    end

  end
end
