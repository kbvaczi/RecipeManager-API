module IngredientParse

  class IngredientParser

    # TODO: include site-speific css tags to search for (i.e. for allrecipes.com)

    def initialize(ingredientStringRaw)
      @ingredientStringRaw = ingredientStringRaw
      @ingredientStringCleaned = cleanedIngredientStringFrom(ingredientStringRaw)
      @ingredientName = nil
      @ingredientAmountUnit = nil
      @ingredientAmountUnitAlias = nil
      @ingredientAmount = nil
    end

    #TODO make these private

    def ingredientAmountUnitAlias
      unless @ingredientAmountUnitAlias == nil
        return @ingredientAmountUnitAlias
      end
      
      @ingredientAmountUnitAlias = unitAliasInString(@ingredientStringCleaned)
      return @ingredientAmountUnitAlias
    end

    def ingredientAmountUnit
      unless @ingredientAmountUnit == nil
        return @ingredientAmountUnit
      end

      if ingredientAmountUnitAlias == nil
        @ingredientAmountUnit = "count"
        return "count"
      end

      @ingredientAmountUnit = unitAliasedAs(ingredientAmountUnitAlias)
      return @ingredientAmountUnit
    end

    def ingredientAmount
      unless @ingredientAmount == nil
        return @ingredientAmount
      end

      # TODO handle all patterns
      # Possible Patterns:
      # Vanilla: "3 cups"
      # Fraction: "1 1/2 cups"
      # Compound units: "3 lbs 2 ounces"
      # Multipliers: "2 12oz cans" or "2x 12oz cans"
      
      amountString = ingredientStringSplit[:amountString]
      
      if amountString != nil
        @ingredientAmount = amountRepresentedByString(amountString)
      else
        @ingredientAmount = 1
      end
      
      return @ingredientAmount
    end

    def ingredientName
      unless @ingredientName == nil
        return @ingredientName
      end

      @ingredientName = ingredientStringSplit[:nameString].squish
      return @ingredientName
    end

    private

    def ingredientStringSplit
      unless @ingredientStringSplit == nil
        return @ingredientStringSplit 
      end
      
      @ingredientStringSplit = {amountString: nil, nameString: nil}

      if ingredientAmountUnitAlias != nil
        ingredientSplitString = @ingredientStringCleaned.split(ingredientAmountUnitAlias)
        @ingredientStringSplit = {amountString: ingredientSplitString[0], nameString: ingredientSplitString.last}
      else
        amountString = amountStringFrom(@ingredientStringCleaned)
        if amountString != nil
          nameString = @ingredientStringCleaned.gsub(amountString, "")
        else
          nameString = @ingredientStringCleaned
        end        
        @ingredientStringSplit = {amountString: amountString, nameString: nameString}
      end

      return @ingredientStringSplit
    end

    def unitAliasInString(string)
      possibleUnitAliases = UNIT_ALIASES_POSSIBLE # defined in units.rb initializer
      possibleUnitAliases.each do |aliasString|
        if string.include?(aliasString + " ")
          return aliasString
        end
      end
      return nil
    end

    def unitAliasedAs(aliasString)
      Unit.definitions.each do |unit|
        if unit[1].aliases.include?(aliasString)
          unit = unit[1].name.match(/\w+\s*-*\w+/)[0]
          return unit
        end
      end
      return nil
    end

    def amountStringFrom(string)
      matchData = string.match(/(\d+[x]?\s+)*(\d+[\s|\W]?\d*\/?\d*)/i)
      if matchData != nil 
        return matchData[0]
      else
        return nil
      end
    end

    def amountRepresentedByString(amountString)
      matchData = amountString.match(/(\d+[x]?\s+)*(\d+[\s|\W]?\d*\/?\d*)/i)
      unless matchData == nil
        mulitplier = matchData[1]||1 rescue 1
        amount = matchData[2]||1 rescue 1
        totalAmountUnit = Unit.new(amount) * Unit.new(mulitplier)
        totalAmount = totalAmountUnit.to_r
        return totalAmount
      end
      return 1
    end

    def cleanedIngredientStringFrom(rawString)
      unless rawString != nil
        return ""
      end

      cleanedIngredientString = replaceProblemCharacters(rawString) # convert vulgar fractions to readable fractions
      cleanedIngredientString.gsub!(/\(.+\)/,"") # get rid of anything in parenthesis
      return cleanedIngredientString
    end

    def replaceProblemCharacters(string)
      replacedString = string
      problemCharacters.each {|f| replacedString.gsub!(f[0], f[1])}
      return replacedString.downcase
    end

    def problemCharacters 
      return {
        # Vulgar Fraction Characters
        "\u00BC" => " 1/4",
        "\u00BD" => " 1/2",
        "\u00BE" => " 3/4",
        "\u2150" => " 1/7",
        "\u2151" => " 1/9",
        "\u2152" => " 1/10",
        "\u2153" => " 1/3",
        "\u2154" => " 2/3",
        "\u2155" => " 1/5",
        "\u2156" => " 2/5",
        "\u2157" => " 3/5",
        "\u2158" => " 4/5",
        "\u2159" => " 1/6",
        "\u215A" => " 5/6",
        "\u215B" => " 1/8",
        "\u215C" => " 3/8",
        "\u215D" => " 5/8",
        "\u215E" => " 7/8",
        # Other Problem Characters
        "⁄" => "/", # weird pseudo slash
      }
    end



  end

end