class Recipes::ParsesController < ApplicationController

  include RecipeParse
  include IngredientParse

  before_action :set_recipe_parse, only: [:show]

  def show    
    
    if @recipe_parse.present?        
      render json: @recipe_parse.to_json, status: :ok
    else        
      render json: nil, status: :not_found
    end
    
  end

  def create    

    # TODO: Run this in a background task?

    @recipe_parse = Recipes::Parse.new(recipe_parse_params)

    recipeParser = RecipeParser.new
    recipeParser.loadHTMLFromURL(@recipe_parse.url)

    @recipe_parse.name = recipeParser.findName
    @recipe_parse.imageURL = recipeParser.findThumbnailImageURL
    @recipe_parse.ingredients = recipeParser.findIngredients
    @recipe_parse.directions = recipeParser.findDirections

    if @recipe_parse.save
      render json: @recipe_parse.to_json, status: :created
    else
      render json: @recipe_parse.errors, status: :unprocessable_entity
    end
    
  end
  
  private

  def set_recipe_parse
    @recipe_parse = Recipes::Parse.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def recipe_parse_params    
    params.fetch(:parse, {}).permit(:url)
  end

end