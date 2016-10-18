require 'active_support/inflector'
require_relative 'has_many_options'
require_relative 'belongs_to_options'

module Associatable
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options
    define_method(name) do
      foreign_key_val = send(options.foreign_key)
      target_class = options.model_class
      target_class.where({options.primary_key => foreign_key_val}).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.to_s, options)
    define_method(name) do
      primary_key_val = send(options.primary_key)
      target_class = options.model_class
      target_class.where({options.foreign_key => primary_key_val}).query_db
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end

  def has_one_through(name, through_name, source_name)
    through_options = assoc_options[through_name]

    define_method(name) do
      source_options = through_options.model_class.assoc_options[source_name]

      through_fk_val = send(through_options.foreign_key)
      source_table = "#{source_options.model_class.table_name}"
      through_table = "#{through_options.model_class.table_name}"
      data = DBConnection.execute(<<-SQL, through_fk_val)
        SELECT
          #{source_table}.*
        FROM
          #{through_table}
        JOIN
          #{source_table} ON #{through_table}.#{source_options.foreign_key} = #{source_table}.#{source_options.primary_key}
        WHERE
          #{through_table}.#{through_options.primary_key} = ?
      SQL

      source_options.model_class.parse_all(data).first
    end
  end
end
