require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject

  def self.columns
    unless @columns
      rows = DBConnection.execute2(<<-SQL)
        SELECT
          *
        FROM
          #{table_name}
      SQL
      @columns = rows.first.map(&:to_sym)
    end
    @columns
  end

  def self.finalize!
    columns.each do |col_name|
      define_method(col_name) do
        attributes[col_name]
      end

      define_method(col_name.to_s + "=") do |value|
        attributes[col_name] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    unless @table_name
      tableized = self.to_s.tableize
      self.table_name = (tableized)
    end
    @table_name
  end

  def self.all
    data = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL
    self.parse_all(data)
  end

  def self.parse_all(results)
    results.map do |result|
      self.new(result)
    end
  end

  def self.find(id)
    data = DBConnection.execute(<<-SQL, id: id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = :id
    SQL
    return nil if data.empty?
    self.new(data.first)
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      attr_name = attr_name.to_sym
      unless self.class.columns.include?(attr_name)
        raise "unknown attribute '#{attr_name}'"
      else
        send(attr_name.to_s + "=", value)
      end
    end
  end

  def attributes
    unless @attributes
      @attributes = {}
    end
    @attributes
  end

  def attribute_values
    self.class.columns.map do |attr_name|
      send(attr_name)
    end
  end

  def insert
    col_names = self.class.columns.join(", ")
    question_marks = (["?"] * attribute_values.length).join(", ")
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_line = self.class.columns.map do |col_name|
      "#{col_name} = ?"
    end.join(", ")

    DBConnection.execute(<<-SQL, *attribute_values, id: id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        id = :id
    SQL
  end

  def save
    id.nil? ? insert : update
  end
end
