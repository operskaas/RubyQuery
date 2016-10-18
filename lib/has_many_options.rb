require_relative 'assoc_options'

class HasManyOptions < AssocOptions
  def initialize(assoc, self_class_name, options = {})
    @class_name = options[:class_name] || assoc.to_s.singularize.camelize
    @foreign_key = options[:foreign_key] || (self_class_name.underscore + "_id").to_sym
    @primary_key = options[:primary_key] || :id
  end
end
