module IngredientParseHelper

  class IngredientParser

    def initialize(ingredientTextRaw)
      @ingredientText = ingredientTextRaw.squish
      @ingredientTextSanitized = sanitizeTextFrom(@ingredientText.dup)
      @ingredientDescription = nil
      @ingredientName = nil
      @ingredientAmountUnit = nil
      @ingredientAmountUnitAlias = nil
      @ingredientAmount = nil
    end

    def ingredientText
      return @ingredientText
    end

    def ingredientComponents
      return {  description: ingredientDescription,
                name: ingredientName,
                amount: ingredientAmount,
                amountUnit: ingredientAmountUnit }
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
      @ingredientName = ingredientStringComponents[:name]
      return @ingredientName
    end

    def ingredientDescription
      unless @ingredientDescription == nil
        return @ingredientDescription
      end
      @ingredientDescription = ingredientStringComponents[:description]
      return @ingredientDescription
    end

    #private

    def ingredientAmountUnitAlias
      unless @ingredientAmountUnitAlias == nil
        return @ingredientAmountUnitAlias
      end
      @ingredientAmountUnitAlias = unitAliasInString(@ingredientTextSanitized)
      return @ingredientAmountUnitAlias
    end

    def ingredientStringComponents
      unless @ingredientStringComponents == nil
        return @ingredientStringComponents
      end
      @ingredientStringComponents = { amountString: nil, name: nil, description: nil }
      if ingredientAmountUnitAlias != nil
        sanitizedIngredientStringSplitByUnitAlias = @ingredientTextSanitized.split(ingredientAmountUnitAlias)
        rawIngredientStringSplitByUnitAlias = @ingredientText.split(ingredientAmountUnitAlias)
        descriptionRawSplit = rawIngredientStringSplitByUnitAlias[1..rawIngredientStringSplitByUnitAlias.length-1]
        descriptionRaw = descriptionRawSplit.join(ingredientAmountUnitAlias)
        @ingredientStringComponents =
          { amountString: sanitizedIngredientStringSplitByUnitAlias[0].squish,
            name: removeUnwantedLeadingCharactersFrom(sanitizedIngredientStringSplitByUnitAlias.last),
            description: removeUnwantedLeadingCharactersFrom(descriptionRaw) }
      else
        amountString = amountStringFrom(@ingredientTextSanitized)
        if amountString != nil
          nameString = @ingredientTextSanitized.gsub(amountString, "").squish
          description = @ingredientText.gsub(amountString, "").squish
        else
          nameString = @ingredientTextSanitized
          description = @ingredientText
        end
        @ingredientStringComponents = { amountString: amountString,
                                        name: nameString,
                                        description: description }
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
          unitName = unit[1].name.match(/\w+\s*-*\w+/)[0]
          return unitName
        end
      end
      return nil
    end

    def amountStringFrom(string)
      amountStringRegex = /\d*\s?(?:x|count|item)?(?:\(?s\)?)?\s?\d+[\s\W]?\d*\s?\/?\s?\d*/i
      amountStringMatch = string.match(amountStringRegex)
      if amountStringMatch
        return amountStringMatch[0]
      else
        return nil
      end
    end

    def amountRepresentedByString(string)
      amountString = "1"
      multiplierString = "1"
      amountStringCaptureRegex = /((?<multiplier>\d+)\s?(x|count)?\s?)?(?=((?<whole>\d+)([\s\W](?<fraction>\d+\s?\/\s?\d+)))|((?<!\d(\s|\W))(?<fraction>\d+\s?\/\s?\d+))|((?<whole>\d+)(?!\s?\/\s?)))/i
      amountStringMatch = string.match(amountStringCaptureRegex)
      if amountStringMatch
        amountString = (amountStringMatch['whole'] || "") + " " + (amountStringMatch['fraction'] || "")
        multiplierString = (amountStringMatch['multiplier'] || "1")
      end
      totalAmountAsUnit = Unit.new(amountString) * Unit.new(multiplierString) rescue 1
      totalAmount = totalAmountAsUnit.to_r
      return totalAmount
    end

    def removeUnwantedLeadingCharactersFrom(rawString)
      cleanedString = rawString.dup
      cleanedString.gsub!(/\A\s*of\s*/i, "") # remove leading "of" i.e. 3 cups of bacon
      cleanedString.gsub!(/\A\W+/, "") # remove leading non-word characters
      cleanedString.squish! # Remove whitespace potentially introduced
      return cleanedString
    end

    def sanitizeTextFrom(rawString)
      if rawString == nil
        return ""
      end
      cleanedString = rawString.dup
      cleanedString = replaceProblemCharactersFrom(cleanedString) # convert vulgar fractions to readable fractions
      cleanedString.gsub!(/\(.+\)/,"") # get rid of anything in parenthesis (typically instructional)
      cleanedString.gsub!(/,.+/,"") # get rid of anything after a comma (typically instructional)
      cleanedString.downcase # downcase string
      cleanedString.squish! # Remove whitespace potentially introduced
      return cleanedString
    end

    def replaceProblemCharactersFrom(string)
      replacedString = string.dup
      problemCharacterReplacementRules.each {|f| replacedString.gsub!(f[0], f[1])}
      return replacedString
    end

    def problemCharacterReplacementRules
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
        # Spelled-out numbers
        /one/i => "1",
        /two/i => "2",
        /three/i => "3",
        /four/i => "4",
        /five/i => "5",
        /six/i => "6",
        /seven/i => "7",
        /eight/i => "8",
        /nine/i => "9",
        /ten/i => "10",
        # Other Problem Characters
        "⁄" => "/", # weird pseudo slash
      }
    end

  end

end
