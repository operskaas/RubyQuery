require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  # def where(params)
  #
  #   where_line = params.keys.map do |attr_name|
  #     "#{attr_name} = ?"
  #   end.join(" AND ")
  #
  #   data = DBConnection.execute(<<-SQL, *params.values)
  #   SELECT
  #     *
  #   FROM
  #     #{table_name}
  #   WHERE
  #     #{where_line}
  #   SQL
  #
  #   data.map do |datum|
  #     self.new(datum)
  #   end
  # end

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

class SQLObject
  # Mixin Searchable here...
  extend Searchable
end

class Cat < SQLObject
  self.finalize!
end

p w = Cat.where(owner_id: 3)
# p w = w.where(name: "Haskell")
w.each do |cat|
  p cat
end
