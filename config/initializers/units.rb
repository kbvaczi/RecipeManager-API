# Customization of ruby-units gem

# allow for space in aliases for fluid ounce
Unit.redefine!("fluid-ounce") do |floz|
  floz.aliases = floz.aliases.concat(%w(fl\ oz fluid\ ounce fluid\ ounces))
end

# add pinch unit
Unit.define("pinch") do |pinch|
  pinch.definition   = Unit.new("1/8 teaspoon")
  pinch.aliases      = %w(pinch pinches)
  pinch.display_name = "Pinch"
end

# Allow for 'heaping' units
unitsToAddHeapingAliasesTo = %w(cup tablespoon teaspoon)
unitsToAddHeapingAliasesTo.each do |unitName|
  Unit.redefine!(unitName) do |unit|
    heapingAliases = unit.aliases.map {|aliasText| "heaping " + aliasText}
    unit.aliases = unit.aliases.concat(heapingAliases)
  end
end

# List of all possible aliases sorted from most complex to least complex
# also removes aliases that are < 2 characters to avoid possible misidentification
#UNIT_ALIASES_POSSIBLE = Unit.definitions.map {|d| d[1].aliases if [:volume, :mass].include? d[1].kind}.compact.flatten.sort {|a, b| a.length > b.length ? -1 : 1}.map {|a| a if a.length > 1}.compact
UNIT_ALIASES_POSSIBLE = ["heaping tablespoons", "heaping tablespoon", "heaping teaspoons", "heaping teaspoon", "fluid ounces", "heaping cups", "heaping tbsp", "fluid-ounces", "heaping tbs", "tablespoons", "fluid-ounce", "heaping tsp", "fluid ounce", "heaping cup", "pound-mass", "metric-ton", "tablespoon", "kilograms", "teaspoons", "teaspoon", "kilogram", "gallons", "grammes", "gallon", "gramme", "liters", "pounds", "ounces", "quarts", "litres", "ounce", "quart", "liter", "pound", "fl oz", "pints", "grams", "litre", "tonne", "pinches", "pinch", "floz", "pint", "cups", "gram", "tbsp", "lbs", "lbm", "cup", "gal", "tsp", "tbs", "kg", "lb", "pt", "qt", "oz"]