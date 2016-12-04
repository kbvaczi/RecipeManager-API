namespace :gather_base_ingredients do
  
  desc "gathers base ingredients from a betty crocker recipe URL"
  task :from_url, [:url] => [:environment] do |t, args|
    include IngredientParse

    parser = IngredientParser.new
    if parser.loadHTMLFromURL(args[:url])
      puts "file loaded, starting parse"
      loop do 
        parser.logIngredientsOnPage
        parser.findOtherBettyCrockerRecipesLinkedOnPage
        break if parser.urlsToBeParsed.empty?
        break if parser.loadHTMLFromURL(parser.urlsToBeParsed.first) == false
      end
    else
      puts "could not load file"
    end

  end

end
