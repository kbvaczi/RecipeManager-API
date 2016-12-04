  class IngredientParserTest < ActiveSupport::TestCase

  include IngredientParse

  def recipeURLS
    ["http://www.bettycrocker.com/recipes/smothered-chicken-casserole/a68b963a-5f75-4ad4-be09-8e0004ee0d9e"]
  end

  def recipeHTMLFiles
    testHTMLFilesArray = Dir.glob("test/lib/ingredient_parse/html_test_files/**/*")
  end

  test "finds ingredients" do
    parser = IngredientParser.new
    recipeHTMLFiles.each do |filePath|
      parser.loadHTMLFromFile(filePath)
      ingredientHashes = parser.findIngredientsOnPage
      ingredientHashes.each do |ingredientHash|
        Rails.logger.info(ingredientHash)
        baseIngredient = BaseIngredient.new(name: ingredientHash[:baseIngredient], category: ingredientHash[:category])
        if baseIngredient.valid?
          baseIngredient.save
        end
      end      
    end
  end

end