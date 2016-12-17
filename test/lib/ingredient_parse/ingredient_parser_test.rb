  class IngredientParserTest < ActiveSupport::TestCase

  include IngredientParse
  include RecipeParse

  def recipeURLS
    ["http://www.bettycrocker.com/recipes/smothered-chicken-casserole/a68b963a-5f75-4ad4-be09-8e0004ee0d9e"]
  end

  def recipeHTMLFiles
    testHTMLFilesArray = Dir.glob("test/lib/recipe_parse/html_test_files/**/*")
  end

  test "parses ingredients" do
  
    recipeParser = RecipeParser.new
    
    recipeHTMLFiles.each do |filePath|
      recipeParser.loadHTMLFromURL(filePath)
      ingredientsList = recipeParser.findIngredients
      assert_not_nil ingredientsList
      assert ingredientsList.length > 1

      ingredientsList.each do |ingredientString|
        ingredientParser = IngredientParser.new(ingredientString)
        puts "Parsed Ingredient: #{ingredientParser.ingredientAmount} #{ingredientParser.ingredientAmountUnit} #{ingredientParser.ingredientName}"
        assert_not_nil ingredientParser.ingredientAmount
        assert_not_nil ingredientParser.ingredientAmountUnit
        assert_not_nil ingredientParser.ingredientName
      end

    end
  

  end

end