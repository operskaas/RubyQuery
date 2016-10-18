require 'active_support/inflector'
require_relative 'has_many_options'
require_relative 'belongs_to_options'

module Associatable
  def belongs_to(assoc, options = {})
    options = BelongsToOptions.new(assoc, options)
    self.assoc_options[assoc] = options

    define_method(assoc) do
      foreign_key_val = self.send(options.foreign_key)
      target_class = options.model_class

      target_class.where({options.primary_key => foreign_key_val}).first
    end
  end

  def has_many(assoc, options = {})
    options = HasManyOptions.new(assoc, self.to_s, options)

    define_method(assoc) do
      primary_key_val = self.send(options.primary_key)
      target_class = options.model_class

      target_class.where({options.foreign_key => primary_key_val})
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end

  def has_one_through(assoc, through_assoc, source_assoc)
    through_options = self.assoc_options[through_assoc]
    through_class = through_options.model_class
    through_table = through_class.table_name.to_s

    source_options = through_class.assoc_options[source_assoc]
    source_class = source_options.model_class
    source_table = source_class.table_name.to_s

    define_method(assoc) do
      through_fk_val = send(through_options.foreign_key)

      rows = DBConnection.execute(<<-SQL, through_fk_val)
        SELECT
          #{source_table}.*
        FROM
          #{through_table}
        JOIN
          #{source_table} ON #{through_table}.#{source_options.foreign_key} = #{source_table}.#{source_options.primary_key}
        WHERE
          #{through_table}.#{through_options.primary_key} = ?
      SQL

      source_class.parse_all(rows).first
    end
  end
end
