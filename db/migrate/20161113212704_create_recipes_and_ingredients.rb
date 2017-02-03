class CreateRecipesAndIngredients < ActiveRecord::Migration[5.0]

  def change
    create_table :recipes, id: :uuid do |t|
      t.string :name
      t.string :sourceURL
      t.string :imageURL
      t.text   :directions

      t.timestamps
    end

    create_table :base_ingredients, id: :uuid do |t|
      t.string :name
      t.string :category

      t.timestamps
    end

    create_table :ingredients, id: :uuid do |t|
      # Foreign Keys
      t.references :recipe, type: :uuid, index: true, foreign_key: true
      t.references :base_ingredient, type: :uuid, index: true, foreign_key: true

      t.decimal :amount
      t.string  :amountUnit
      t.string  :description

      t.timestamps
    end
  end

end
