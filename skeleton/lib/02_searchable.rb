require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_line = params.keys.map do |attr_name|
      "#{attr_name} = ?"
    end.join(" AND ")

    data = DBConnection.execute(<<-SQL, *params.values)
    SELECT
      *
    FROM
      #{table_name}
    WHERE
      #{where_line}
    SQL

    data.map do |datum|
      self.new(datum)
    end
  end

end

class SQLObject
  # Mixin Searchable here...
  extend Searchable
end
