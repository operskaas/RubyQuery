module Searchable

  def where(params)
    Relation.new(params, self)
  end

end

class Relation
  include Enumerable

  def where(params)
    @params.merge!(params)
    self
  end

  def [](index)
    @target_class.new(data[index])
  end

  def each(&prc)
    data.each do |datum|
      prc.call(@target_class.new(datum))
    end
  end

  def initialize(params, target_class)
    @params = params
    @data = nil
    @target_table = target_class.table_name
    @target_class = target_class
  end

  def params
    @params
  end

  def query_db
    where_line = params.keys.map do |attr_name|
      "#{attr_name} = ?"
    end.join(" AND ")

    data = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{@target_table}
      WHERE
        #{where_line}
    SQL

    data
  end

  def data
    @data ||= query_db
  end

end
