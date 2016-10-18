require_relative 'assoc_options'

class BelongsToOptions < AssocOptions
  def initialize(assoc, options = {})
    assoc_str = assoc.to_s

    @class_name = options[:class_name] || assoc_str.camelize
    @foreign_key = options[:foreign_key] || (assoc_str + "_id").to_sym
    @primary_key = options[:primary_key] || :id
  end
end
