require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

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
