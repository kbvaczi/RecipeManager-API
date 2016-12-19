class CreateRecipeParses < ActiveRecord::Migration[5.0]
  def change
    create_table :recipe_parses, id: :uuid do |t|

      # table attributes
      t.string :name
      t.string :url
      t.string :imageURL
      t.text   :ingredients
      t.text   :directions

      # foreign keys
      t.integer :recipe_id

      t.timestamps
    end
  end
end
