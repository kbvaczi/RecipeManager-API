class RecipesController < ApplicationController

  before_action :set_recipe, only: [:show, :update, :destroy]
  # before_action :authenticate_user!

  # GET /recipes
  def index
    @recipes = Recipe.all.includes(:ingredients)
    # TODO: Pagination?
    render json: @recipes.to_json(include: :ingredients), status: :ok
  end

  # GET /recipes/1
  def show
    render json: @recipe, status: :ok
  end

  # POST /recipes
  def create
    @recipe = Recipe.new(recipe_params)

    if @recipe.save
      render json: @recipe, status: :created
    else
      render json: @recipe.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /recipes/1
  def update
    if @recipe.update(recipe_params)
      render json: @recipe, status: :ok
    else
      render json: @recipe.errors, status: :unprocessable_entity
    end
  end

  # DELETE /recipes/1
  def destroy
    if @recipe.destroy
      render json: nil, status: :ok
    else
      render json: nil, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_recipe
    @recipe = Recipe.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def recipe_params
    params.fetch(:recipe, {}).permit(:name, :sourceURL, :imageURL, :recipe_parse_id, directions: [], ingredients_attributes: [:amount, :amountUnit, :description])
  end

end
