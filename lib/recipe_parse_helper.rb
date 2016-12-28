module RecipeParseHelper
  # Used to parse ingredients from third party URLs

  require 'nokogiri'
  require 'open-uri'

  class RecipeParser

    # TODO: include site-speific css tags to search for (i.e. for allrecipes.com)

    def recipeParsedRaw
      unless @doc.present?
        Rails.logger.info "RecipeParser.recipeRawAsText: document not initialized"
        return nil
      end

      return {name: findName, url: @url, thumbnailImageUrl: findThumbnailImageURL, ingredients: findIngredients, directions: findDirections}
    end

    # initailizes html file for importing
    # returns true if successful
    # returns false if unsuccessful
    def loadHTMLFromURL(url)
      begin
        @doc = Nokogiri::HTML(open(url))
        @url = url
      rescue
        Rails.logger.info "RecipeParser.loadURL: unable to load URL #{url}"
        return false
      end
      Rails.logger.info "RecipeParser.loadURL: successfully loaded URL #{url}"
      return true
    end

    # initailizes html file for importing
    # returns true if successful
    # returns false if unsuccessful
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

    def findName
      unless @doc.present?
        Rails.logger.info "RecipeParser.findRecipeName: document not initialized"
        return nil
      else
        recipeName = nil
        @doc.css('h1').each do |header|
          recipeName = header.content
          Rails.logger.info "RecipeParser.findRecipeName: found potential recipe name: #{recipeName}"
          break
        end

        if recipeName == nil
          Rails.logger.info "RecipeParser.findRecipeName: couldn't find recipe name looking for headers, using doc title as backup"
          recipeName = @doc.css('title')
        end

        if recipeName == nil
          Rails.logger.info "RecipeParser.findRecipeName: couldn't find recipe name"
        end

        return recipeName.squish
      end
    end

    # Returns an array of ingredients as string including quantity and unit
    def findIngredients
      unless @doc.present?
        Rails.logger.info "RecipeParser.findIngredients: document not initialized"
        return nil
      else

        ingredientsHeaderHTML = findHeaderContainingText(["ingredients"])

        if ingredientsHeaderHTML.present?
          ingredientsListHTML = findListAfterHTMLNode(ingredientsHeaderHTML)
        else
          Rails.logger.info "RecipeParser.findIngredients: unable to find ingredients header"
          return nil
        end

        if ingredientsListHTML.present?
          Rails.logger.info "RecipeParser.findIngredients: found ingredients list HTML as #{ingredientsListHTML.name}"
          ingredientsListParsed = parseListHTML(ingredientsListHTML)
          Rails.logger.info "RecipeParser.findIngredients: found ingredients #{ingredientsListParsed}"
          return ingredientsListParsed
        else
          Rails.logger.info "RecipeParser.findIngredients: unable to find ingredients list HTML"
          return nil
        end

      end
    end

    # returns an array of directions as string
    def findDirections
      unless @doc.present?
        Rails.logger.info "RecipeParser.findDirections: document not initialized"
        return nil
      else
        directionsHeaderHTML = findHeaderContainingText(["directions", "instructions"])

        if directionsHeaderHTML.present?
          directionsListHTML = findListAfterHTMLNode(directionsHeaderHTML)
        else
          Rails.logger.info "RecipeParser.findDirections: unable to find directions header"
          return nil
        end

        if directionsListHTML.present?
          Rails.logger.info "RecipeParser.findDirections: found directions HTML as #{directionsListHTML.name}"
          directionsListParsed = parseListHTML(directionsListHTML)
          Rails.logger.info "RecipeParser.findDirections: found directions #{directionsListParsed}"
        else
          Rails.logger.info "RecipeParser.findDirections: unable to find directions list HTML"
          return nil
        end

        return directionsListParsed

      end
    end

    # returns URL to most relevant thumbnail to use
    def findThumbnailImageURL
      unless @doc.present?
        Rails.logger.info "RecipeParser.findThumbnailImageURL: document not initialized"
        return nil
      end

      # meta tags to tell social media which image to use for links in order of importance
      # Reference: https://moz.com/blog/meta-data-templates-123
      metaTagsLookingFor = ["meta[property='og:image:secure_url']", "meta[property='og:image']", "meta[itemprop='image']", "meta[name='twitter:image:src']", "link[rel='image_src']", "a[rel='image_src']"]

      metaTagsLookingFor.each do |metaTag|
        node = @doc.at_css(metaTag)
        if node != nil
          imageURL = node.attribute('content') || note.attribute('href')
          Rails.logger.info "RecipeParser.findThumbnailImageURL: found image thumbnail #{imageURL}"
          return imageURL
        end
      end

      #TODO: Find image if page does not use social media meta.

      Rails.logger.info "RecipeParser.findThumbnailImageURL: unable to find thumbnail image URL"
      return nil
    end

    private

    def findHeaderContainingText(textOptionsArray)
      @doc.css('h2', 'h3', 'h4', 'h5', 'h6', 'dt').each do |header|
        textOptionsArray.each do |text|
          if header.content.downcase.include? text
            Rails.logger.info "RecipeParser.findIngredients: found ingredients #{header.name} header titled \"#{header.content.squish}\""
            return header
          end
        end
      end
      return nil
    end

    def findListAfterHTMLNode(node)

      if node != nil
        Rails.logger.info "RecipeParser.findListAfterHTMLNode: searching for list in #{node.name}"

        nodeIsListNode = (%w(ol ul).include? node.name)
        if nodeIsListNode
          Rails.logger.info "RecipeParser.findListAfterHTMLNode: found list node #{node.name}"
          return node
        end

        listCouldBeDefinitionList = (node.name == 'dl')
        if listCouldBeDefinitionList
          Rails.logger.info "RecipeParser.findListAfterHTMLNode: found list node as definition list"
          listNodeAsDefinitionList = node.parent
          return listNodeAsDefinitionList
        end

        listNodeCouldBeChild = node.children.count > 0
        if listNodeCouldBeChild
          Rails.logger.info "RecipeParser.findListAfterHTMLNode: no list in #{node.name}, searching children"
          node.children.each do |childNode|
            listNodeAsChild = findListAfterHTMLNode(childNode)
            if listNodeAsChild != nil
              return listNodeAsChild
            end
          end
        end

        listNodeCouldBeNextSibling = (node.next != nil)
        if listNodeCouldBeNextSibling
          Rails.logger.info "RecipeParser.findListAfterHTMLNode: no list in #{node.name}, searching next node"
          listNodeAsNextSibling = findListAfterHTMLNode(node.next)
          if listNodeAsNextSibling != nil
            return listNodeAsNextSibling
          end
        end
      end

      return nil
    end

    def parseListHTML(listHTML)
      parsedList = []

      listHTML.children.each do |listItem|
          nodeContent = listItem.content
          if nodeContent.present?
            Rails.logger.info "RecipeParser.parseListHTML: found content in #{listItem.name}"
            nodeContentCleaned = nodeContent.squish
            contentJustEmptySpace = nodeContentCleaned.length < 2
            parsedList.append(nodeContentCleaned) unless contentJustEmptySpace
          else
            listItem.children.each do |childNode|
              parsedList = parsedList.concat(parseListHTML(childNode))
            end
          end
      end

      return parsedList
    end

  end # RecipeParser class

end
