class RecipesController < ApplicationController
  
  before_action :set_recipe, only: [:show, :edit, :update, :destroy]

  # GET /recipes
  def index
  
    @recipes = Recipe.all

    #url = "http://www.skinnytaste.com/dinas-tossed-mushrooms/" #params[:url]
    url = "https://www.weightwatchers.com/us/recipe/classic-lasagna-1/5626a644f79cf9120df3b8e7"
     render json: scrapeRecipeFromURL(url)
    
  end

  # GET /recipes/1
  def show
  end

  # GET /recipes/1/edit
  def edit
  end

  # POST /recipes
  def create
   
    @recipe = Recipe.new(recipe_params)
    
    if @recipe.save
      render :show, status: :created, location: @recipe
    else
      render json: @recipe.errors, status: :unprocessable_entity
    end
    
  end

  # PATCH/PUT /recipes/1
  def update

    if @recipe.update(recipe_params)    
      render :show, status: :ok, location: @recipe
    else
      render json: @recipe.errors, status: :unprocessable_entity
    end

  end

  # DELETE /recipes/1
  def destroy
    
    @recipe.destroy      
    head :no_content

  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_recipe
    @recipe = Recipe.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def recipe_params
    params.fetch(:recipe, {})
  end

end
