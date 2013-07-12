require 'active_support/core_ext'
require 'active_support'
require 'pry'

ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.plural /^(ox)$/, '\1\2en'
  inflect.singular /^(ox)en/, '\1'

  inflect.irregular 'octopus', 'octopi'

  inflect.uncountable 'equipment'
end


#puts 'manual_warehousing'.camelize
puts 'ox'.pluralize
puts 'octopi'.singularize
puts 'octopus'.pluralize
puts 'equipment'.pluralize
