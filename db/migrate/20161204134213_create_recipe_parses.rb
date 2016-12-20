class CreateRecipeParses < ActiveRecord::Migration[5.0]

  def change
    create_table :recipe_parses, id: :uuid do |t|
      # Table Attributes
      t.string :name
      t.string :url
      t.string :imageURL
      t.text   :ingredients
      t.text   :directions

      # Foreign Keys
      t.references :recipe, type: :uuid, index: true, foreign_key: true

      t.timestamps
    end
  end
  
end
