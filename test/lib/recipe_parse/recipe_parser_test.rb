class RecipeParserTest < ActiveSupport::TestCase

  include RecipeParseHelper

  def recipeURLS
    ["http://www.skinnytaste.com/dinas-tossed-mushrooms/",
    "https://www.weightwatchers.com/us/recipe/classic-lasagna-1/5626a644f79cf9120df3b8e7",
    "http://www.foodnetwork.com/recipes/food-network-kitchens/herbed-cornbread.html",
    "http://www.fitnessmagazine.com/recipe/chicken/mediterranean-chicken-and-pasta/"]
  end

  def recipeHTMLFiles
    testHTMLFilesArray = Dir.glob("test/lib/recipe_parse/html_test_files/**/*")
  end

  test "finds image thumbnail" do
    parser = RecipeParser.new
    recipeHTMLFiles.each do |filePath|
      parser.loadHTMLFromURL(filePath)
      imageURL = parser.findThumbnailImageURL
      assert_not_nil imageURL
    end
  end 

  test "finds recipe name" do
    parser = RecipeParser.new
    recipeHTMLFiles.each do |filePath|
      parser.loadHTMLFromFile(filePath)
      assert parser.findName != nil
    end
  end 

  test "finds recipe ingredients" do
    parser = RecipeParser.new
    recipeHTMLFiles.each do |filePath|
      parser.loadHTMLFromURL(filePath)
      ingredientsList = parser.findIngredients
      assert_not_nil ingredientsList
      assert ingredientsList.length > 1
    end
  end 

  test "finds recipe directions" do
    parser = RecipeParser.new
    recipeHTMLFiles.each do |filePath|
      parser.loadHTMLFromURL(filePath)
      directionsList = parser.findDirections
      assert_not_nil directionsList
    end
  end 


end