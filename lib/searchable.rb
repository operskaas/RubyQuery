module Searchable

  def where(params)
    Relation.new(params, self)
  end

end

class Relation
  include Enumerable

  attr_reader :params, :target_class

  def initialize(params, target_class)
    @params = params
    @target_class = target_class
  end

  def where(params)
    self.params.merge!(params)
    self
  end

  def [](index)
    self.target_class.new(rows[index])
  end

  def each(&prc)
    rows.each do |row|
      prc.call(self.target_class.new(row))
    end
  end

  def length
    rows.length
  end

  def to_a
    objects ||= rows.map do |row|
      self.target_class.new(row)
    end
  end


  private

  attr_accessor :objects

  def rows
    @rows ||= query_db
  end

  def query_db
    where_line = params.keys.map do |attr_name|
      "#{attr_name} = ?"
    end.join(" AND ")

    rows = DBConnection.execute(<<-SQL, *params.values)
    SELECT
    *
    FROM
    #{self.target_class.table_name}
    WHERE
    #{where_line}
    SQL

    rows
  end
end
