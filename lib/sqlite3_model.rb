require_relative 'db_connection'
require_relative 'searchable'
require_relative 'associatable'
require 'active_support/inflector'

class SQLite3Model
  extend Searchable
  extend Associatable

  def self.finalize!
    self.columns.each do |col_name|
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
      self.table_name = tableized
    end

    @table_name
  end

  def self.all
    entries = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL

    self.parse_all(entries)
  end

  def self.find(id)
    entry = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = ?
    SQL

    return nil if entry.empty?
    self.new(entry.first)
  end

  def initialize(params = {})
    params.each do |attr_name, attr_value|
      attr_name = attr_name.to_sym
      unless self.class.columns.include?(attr_name)
        raise "unknown attribute '#{attr_name}'"
      else
        send(attr_name.to_s + "=", attr_value)
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def save
    id.nil? ? insert : update
  end

  private

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

  def self.parse_all(entries)
    entries.map do |entry|
      self.new(entry)
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
    set_str = self.class.columns.map do |col_name|
      "#{col_name} = ?"
    end.join(", ")

    DBConnection.execute(<<-SQL, *attribute_values, id: id)
    UPDATE
    #{self.class.table_name}
    SET
    #{set_str}
    WHERE
    id = :id
    SQL
  end

  def attribute_values
    self.class.columns.map do |attr_name|
      send(attr_name)
    end
  end

end
