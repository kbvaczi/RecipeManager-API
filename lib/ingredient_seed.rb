# Used to seed base ingredients from the Betty Crocker library
module IngredientSeed

  require 'nokogiri'
  require 'open-uri'

  class IngredientSeeder
    
    attr_accessor :urlsParsed, :urlsToBeParsed, :doc

    def initialize
      @currentUrl = nil
      @doc = nil
      @urlsParsed = []
      @urlsToBeParsed = []

      @ingredientsParsedLogFilePath = 'db/seed/base_ingredients_seed_data.xml'
      loadIngredientsParsedLogFile
    end

    ## Parsing HTML ## 

    def loadHTMLFromURL(url)
      unless @urlsParsed.include?(url)
        begin 
          @doc = Nokogiri::HTML(open(url))
          @currentUrl = url          
        rescue
          Rails.logger.info "IngredientParser.loadURL: unable to load URL #{url}"
          return false
        end
        Rails.logger.info "IngredientParser.loadURL: loaded URL #{url}"
        return true
      else
        Rails.logger.info "IngredientParser.loadURL: already parsed URL #{url}"
        return false
      end
    end

    def loadHTMLFromFile(filePath)
      begin 
        @doc = File.open(filePath) { |f| Nokogiri::HTML(f) } 
      rescue
        Rails.logger.info "RecipeParser.loadURL: unable to load HTML file #{filePath}"
        return false
      end
      Rails.logger.info "RecipeParser.loadURL: successfully loaded HTML file #{filePath}"
      return true
    end

    def findOtherBettyCrockerRecipesLinkedOnPage
      otherRecipes = []
      @doc.css('a[href]').each do |urlNode|
        relativeURL = urlNode['href']
        if isBettyCrockerRecipeURL(relativeURL)
          absoluteURL = "http://www.bettycrocker.com" + relativeURL
          otherRecipes.append(absoluteURL)
        end
      end
      @urlsToBeParsed.concat(otherRecipes)
      return otherRecipes
    end

    def findIngredientsOnPage
      ingredientsList = []
      @doc.search('dl.recipePartIngredient').each do |ingredientDefinitionList|
        baseIngredientNameRaw = ingredientDefinitionList['data-base-ingredient']
        baseIngredientNameCleaned = cleanString(baseIngredientNameRaw)
        categoryRaw = ingredientDefinitionList['data-category']
        categoryCleaned = cleanString(categoryRaw)
        if baseIngredientNameCleaned != nil  and categoryCleaned != nil 
          ingredientsList.append({name: baseIngredientNameCleaned, category: categoryCleaned})
        end
      end
      return ingredientsList
    end

    def logIngredientsOnPage

      if @currentUrl.present?        
        if isBettyCrockerRecipeURL(@currentUrl)
          findIngredientsOnPage.each do |ingredient|
            ingredientNode = @ingredientsParsedLog.create_element('BaseIngredient')
            nameNode = @ingredientsParsedLog.create_element('Name', ingredient[:name])
            ingredientNode.add_child(nameNode)
            categoryNode = @ingredientsParsedLog.create_element('Category', ingredient[:category])
            ingredientNode.add_child(categoryNode)
            if @ingredientsParsedLog.at("BaseIngredient Name:contains(\"#{ingredient[:name]}\")")
              puts "Ingredient #{ingredient[:name]} already captured"
            else
              @ingredientsParsedLog.at('BaseIngredients').add_child(ingredientNode)
              puts "Ingredient #{ingredient[:name]} added"
            end
          end
        end      

        @urlsParsed.append(@currentUrl) if isBettyCrockerRecipeURL(@currentUrl)
        @urlsToBeParsed.delete(@currentUrl)

        urlNode = @ingredientsParsedLog.create_element('URL', @currentUrl)
        @ingredientsParsedLog.at('URLs').add_child(urlNode)
        saveIngredientsParsedLogFile
      end
      
    end

    private

    ## Parsing HTML ##

    def isBettyCrockerRecipeURL(url)
      #/recipes/smothered-chicken-casserole/a68b963a-5f75-4ad4-be09-8e0004ee0d9e            
      isAbsoluteURL = url.match(/^http:\/\/www.bettycrocker.com\/recipes\/\S+\/\S{8}-\S{4}-\S{4}-\S{4}-\S{12}/i).present?
      isRelativeURL = url.match(/^\/recipes\/\S+\/\S{8}-\S{4}-\S{4}-\S{4}-\S{12}/i).present? 
      return (isRelativeURL or isAbsoluteURL)
    end

    def cleanString(string)
      return string.gsub(/\(.+\)/,"").gsub(/\/.+/,"").squish
    end

    ## Ingredients Log ##

    def loadIngredientsParsedLogFile
      xml = File.read(@ingredientsParsedLogFilePath)
      @ingredientsParsedLog = Nokogiri::XML(xml,&:noblanks)
      @ingredientsParsedLog.search('URLs').children.each do |url|
        @urlsParsed.append url.content
      end
    end

    def saveIngredientsParsedLogFile
      File.write(@ingredientsParsedLogFilePath, @ingredientsParsedLog.to_xml(indent: 4, indent_text: " "))
    end

  end

end
