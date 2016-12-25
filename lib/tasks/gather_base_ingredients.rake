namespace :gather_base_ingredients do
  
  desc "gathers base ingredients from a betty crocker recipe URL"
  task :from_url, [:url] => [:environment] do |t, args|
    
    include IngredientSeed

    parser = IngredientSeeder.new
    if parser.loadHTMLFromURL(args[:url])
      Rails.logger.info "file loaded, starting parse"
      loop do 
        parser.logIngredientsOnPage
        parser.findOtherBettyCrockerRecipesLinkedOnPage
        break if parser.urlsToBeParsed.empty?
        break if parser.loadHTMLFromURL(parser.urlsToBeParsed.first) == false
      end
    else
      Rails.logger.info "could not load file"
    end

  end

  desc "gathers base ingredients from a betty crocker recipe files saved to project"
  task :from_file => [:environment] do    
    
    include IngredientSeed

    parser = IngredientSeeder.new    
    recipeHTMLFiles.each do |filePath|
      if parser.loadHTMLFromFile(filePath)
        Rails.logger.info "file loaded, starting parse"
        loop do
          if parser.urlsToBeParsed.empty?
            Rails.logger.info "no more URLs to be parsed, stopping task"
            break
          end
          parser.logIngredientsOnPage
          parser.findOtherBettyCrockerRecipesLinkedOnPage
          while parser.urlsToBeParsed.count > 0
            if parser.loadHTMLFromURL(parser.urlsToBeParsed.first)
              break
            else
              Rails.logger.info parser.urlsToBeParsed
              parser.urlsToBeParsed.delete(parser.urlsToBeParsed.first)
              Rails.logger.info parser.urlsToBeParsed
            end
          end
        end
      else
        Rails.logger.info "could not load file"
      end
    end    
  end

end
