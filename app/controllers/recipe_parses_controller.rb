class RecipeParsesController < ApplicationController

  include RecipeParseHelper
  include IngredientParseHelper

  before_action :set_recipe_parse, only: [:show]
  #before_action :authenticate_user!

  def show
    if @recipe_parse.present?
      render json: @recipe_parse.to_json, status: :ok
    else
      render json: nil, status: :not_found
    end
  end

  def create
    # TODO: Run this in a background task?
    @recipe_parse = RecipeParse.new(recipe_parse_params)
    @recipe_parse.user = current_user
    recipeParser = RecipeParser.new
    recipeParser.loadHTMLFromURL(@recipe_parse.url)
    @recipe_parse.name = recipeParser.findName
    @recipe_parse.imageURL = recipeParser.findThumbnailImageURL
    recipeParser.findIngredients.each do |ingredientText|
      ingredientParser = IngredientParser.new(ingredientText)
      @recipe_parse.ingredients.append(ingredientParser.ingredientComponents)
    end

    @recipe_parse.directions = recipeParser.findDirections
    if @recipe_parse.save
      render json: @recipe_parse.to_json, status: :created
    else
      render json: @recipe_parse.errors, status: :unprocessable_entity
    end
  end

  private

  def set_recipe_parse
    @recipe_parse = current_user.recipe_parses.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def recipe_parse_params
    params.fetch(:recipe_parse, {}).permit(:url)
  end

end
