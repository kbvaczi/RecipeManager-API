module IngredientParse

  class IngredientParser

    def initialize(ingredientTextRaw)
      @ingredientText = ingredientTextRaw.squish
      @ingredientTextCleaned = cleanedStringFrom(@ingredientText)
      @ingredientName = nil
      @ingredientAmountUnit = nil
      @ingredientAmountUnitAlias = nil
      @ingredientAmount = nil
    end

    def ingredientComponents
      return {description: @ingredientText, name: ingredientName, amount: ingredientAmount,
              amountUnit: ingredientAmountUnit}
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
      amountString = ingredientStringComponents[:amountString]
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
      @ingredientName = ingredientStringComponents[:nameString]
      return @ingredientName
    end

    private

    def ingredientAmountUnitAlias
      unless @ingredientAmountUnitAlias == nil
        return @ingredientAmountUnitAlias
      end
      @ingredientAmountUnitAlias = unitAliasInString(@ingredientTextCleaned)
      return @ingredientAmountUnitAlias
    end

    def ingredientStringComponents
      unless @ingredientStringComponents == nil
        return @ingredientStringComponents
      end
      @ingredientStringComponents = {amountString: nil, nameString: nil}
      if ingredientAmountUnitAlias != nil
        ingredientStringSplitByUnitAlias = @ingredientTextCleaned.split(ingredientAmountUnitAlias)
        @ingredientStringComponents = {amountString: ingredientStringSplitByUnitAlias[0].squish, nameString: ingredientStringSplitByUnitAlias.last.squish}
      else
        amountString = amountStringFrom(@ingredientTextCleaned)
        if amountString != nil
          nameString = @ingredientTextCleaned.gsub(amountString, "").squish
        else
          nameString = @ingredientTextCleaned
        end
        @ingredientStringComponents = {amountString: amountString, nameString: nameString}
      end
      return @ingredientStringComponents
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

    def amountWithFractionRegex
      return /(\d+x?\s+)?(\d+[\s\W]\d+\s?\/\s?\d+)/
    end

    def amountWithoutFractionRegex
      return /(\d+x?\s+)?(\d+)/
    end

    def amountStringFrom(string)
      matchDataWithFraction = string.match(amountWithFractionRegex)
      return matchDataWithFraction[0] if matchDataWithFraction
      matchDataWithoutFraction = string.match(amountWithoutFractionRegex)
      return matchDataWithoutFraction[0] if matchDataWithoutFraction
      return nil
    end

    def amountRepresentedByString(string)
      amountString = "1"
      multiplierString = "1"
      amountWithFractionMatch = string.match(amountWithFractionRegex)
      if amountWithFractionMatch
        amountString = amountWithFractionMatch[2]
        multiplierString = amountWithFractionMatch[1] if amountWithFractionMatch[1]
      else
        amountWithoutFractionMatch = string.match(amountWithoutFractionRegex)
        if amountWithoutFractionMatch
          amountString = amountWithoutFractionMatch[2]
          multiplierString = amountWithoutFractionMatch[1] if amountWithoutFractionMatch[1]
        end
      end
      totalAmountAsUnit = Unit.new(amountString) * Unit.new(multiplierString) rescue 1
      totalAmount = totalAmountAsUnit.to_r
      return totalAmount
    end

    def cleanedStringFrom(rawString)
      if rawString == nil
        return ""
      end
      cleanedString = replaceProblemCharactersFrom(rawString) # convert vulgar fractions to readable fractions
      cleanedString.gsub!(/\(.+\)/,"") # get rid of anything in parenthesis (typically instructional)
      cleanedString.gsub!(/,.+/,"") # get rid of anything after a comma (typically instructional)
      cleanedString.squish! # Remove whitespace potentially introduced
      return cleanedString
    end

    def replaceProblemCharactersFrom(string)
      replacedString = string
      problemCharacters.each {|f| replacedString.gsub!(f[0], f[1])}
      return replacedString.downcase
    end

    def problemCharacters
      return {
        # Vulgar Fraction Characters
        "\u00BC" => " 1/4 ",
        "\u00BD" => " 1/2 ",
        "\u00BE" => " 3/4 ",
        "\u2150" => " 1/7 ",
        "\u2151" => " 1/9 ",
        "\u2152" => " 1/10 ",
        "\u2153" => " 1/3 ",
        "\u2154" => " 2/3 ",
        "\u2155" => " 1/5 ",
        "\u2156" => " 2/5 ",
        "\u2157" => " 3/5 ",
        "\u2158" => " 4/5 ",
        "\u2159" => " 1/6 ",
        "\u215A" => " 5/6 ",
        "\u215B" => " 1/8 ",
        "\u215C" => " 3/8 ",
        "\u215D" => " 5/8 ",
        "\u215E" => " 7/8 ",
        # Other Problem Characters
        "⁄" => "/", # weird pseudo slash
      }
    end

  end

end
