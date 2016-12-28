class IngredientParserTest < ActiveSupport::TestCase

  include IngredientParseHelper
  include RecipeParseHelper

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
        Rails.logger.info "Parsed Ingredient: #{ingredientParser.ingredientAmount} #{ingredientParser.ingredientAmountUnit} #{ingredientParser.ingredientName}"
        assert_not_nil ingredientParser.ingredientAmount
        assert_not_nil ingredientParser.ingredientAmountUnit
        assert_not_nil ingredientParser.ingredientName
      end
    end
  end

  test "simple ingredient: \"3 cups stuff\"" do
    i = IngredientParser.new("3 cups stuff")
    Rails.logger.info "Parsed Ingredient -  Amount:#{i.ingredientAmount} Unit:#{i.ingredientAmountUnit} Name:#{i.ingredientName}"
    assert i.ingredientName == "stuff"
    assert i.ingredientAmount == 3.to_r
    assert i.ingredientAmountUnit == "cup"
  end

  test "simple ingredient + of: \"5 tablespoons of stuff\"" do
    i = IngredientParser.new("5 tablespoons of stuff")
    Rails.logger.info "Parsed Ingredient -  Amount:#{i.ingredientAmount} Unit:#{i.ingredientAmountUnit} Name:#{i.ingredientName}"
    assert i.ingredientName == "stuff"
    assert i.ingredientAmount == 5.to_r
    assert i.ingredientAmountUnit == "tablespoon"
  end

  test "fraction ingredient: \"1/2 cup all-purpose flour\"" do
    i = IngredientParser.new("1/2 cup all-purpose flour")
    Rails.logger.info "Parsed Ingredient -  Amount:#{i.ingredientAmount} Unit:#{i.ingredientAmountUnit} Name:#{i.ingredientName}"
    assert i.ingredientName == "all-purpose flour"
    assert i.ingredientAmount == 0.5.to_r
    assert i.ingredientAmountUnit == "cup"
  end

  test "fraction ingredient with whole number: \"5 1/2 pounds of stuff\"" do
    i = IngredientParser.new("5 1/2 pounds of stuff")
    Rails.logger.info "Parsed Ingredient -  Amount:#{i.ingredientAmount} Unit:#{i.ingredientAmountUnit} Name:#{i.ingredientName}"
    assert i.ingredientName == "stuff"
    assert i.ingredientAmount == 5.5.to_r
    assert i.ingredientAmountUnit == "pound"
  end

  test "vulgar fraction ingredient: \"5 ½ tsp of stuff\"" do
    i = IngredientParser.new("5 ½ tsp of stuff")
    Rails.logger.info "Parsed Ingredient -  Amount:#{i.ingredientAmount} Unit:#{i.ingredientAmountUnit} Name:#{i.ingredientName}"
    assert i.ingredientName == "stuff"
    assert i.ingredientAmount == 5.5.to_r
    assert i.ingredientAmountUnit == "teaspoon"
  end

  test "multiplier ingredient: \"5 2-pound bags of rice\"" do
    i = IngredientParser.new("5 2-pound bags of rice")
    Rails.logger.info "Parsed Ingredient -  Amount:#{i.ingredientAmount} Unit:#{i.ingredientAmountUnit} Name:#{i.ingredientName}"
    assert i.ingredientName == "bags of rice"
    assert i.ingredientAmount == 10.to_r
    assert i.ingredientAmountUnit == "pound"
  end

  test "multiplier ingredient2: \"5x 2 pound bags of rice\"" do
    i = IngredientParser.new("5 2-pound bags of rice")
    Rails.logger.info "Parsed Ingredient -  Amount:#{i.ingredientAmount} Unit:#{i.ingredientAmountUnit} Name:#{i.ingredientName}"
    assert i.ingredientName == "bags of rice"
    assert i.ingredientAmount == 10.to_r
    assert i.ingredientAmountUnit == "pound"
  end

  test "multiplier fraction ingredient: \"4 2-1/2 ounce bags of rice\"" do
    i = IngredientParser.new("4x 2-1/2 ounce bags of rice")
    Rails.logger.info "Parsed Ingredient -  Amount:#{i.ingredientAmount} Unit:#{i.ingredientAmountUnit} Name:#{i.ingredientName}"
    assert i.ingredientName == "bags of rice"
    assert i.ingredientAmount == 10.to_r
    assert i.ingredientAmountUnit == "ounce"
  end

  test "multiplier fraction ingredient2: \"5 count 2-1/2 ounce bags of rice\"" do
    i = IngredientParser.new("4x 2-1/2 ounce bags of rice")
    Rails.logger.info "Parsed Ingredient -  Amount:#{i.ingredientAmount} Unit:#{i.ingredientAmountUnit} Name:#{i.ingredientName}"
    assert i.ingredientName == "bags of rice"
    assert i.ingredientAmount == 10.to_r
    assert i.ingredientAmountUnit == "ounce"
  end

  test "ignore parenthesis: \"2-1/2 ounce bags of rice (lightly stirred in 7-pound increments)\"" do
    i = IngredientParser.new("2-1/2 ounce bags of rice (lightly stirred in 7-pound increments)")
    Rails.logger.info "Parsed Ingredient -  Amount:#{i.ingredientAmount} Unit:#{i.ingredientAmountUnit} Name:#{i.ingredientName}"
    assert i.ingredientName == "bags of rice"
    assert i.ingredientAmount == 2.5.to_r
    assert i.ingredientAmountUnit == "ounce"
  end

  test "ignore anything after comma: \"2-1/2 ounce bags of bacon, lightly stirred in 7-pound increments\"" do
    i = IngredientParser.new("2-1/2 ounce bags of bacon, lightly stirred in 7-pound increments")
    Rails.logger.info "Parsed Ingredient -  Amount:#{i.ingredientAmount} Unit:#{i.ingredientAmountUnit} Name:#{i.ingredientName}"
    assert i.ingredientName == "bags of bacon"
    assert i.ingredientAmount == 2.5.to_r
    assert i.ingredientAmountUnit == "ounce"
  end

end
