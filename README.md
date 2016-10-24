# RubyQuery

RubyQuery makes it easy to define Ruby classes that can query a SQLite3 database
and refer to each other with associations.

## Usage

In order to use RubyQuery, you must define model classes that inherit from
`SQLite3Model`, and create a `DBConnection` to your SQLite3 database.

### Inheriting from `SQLite3Model`

To use RubyQuery, you must require `sqlite3_model`, define a class that inherits
from SQLite3Model, and call `self.finalize!` in the class definition, as such:

```ruby
require_relative 'sqlite3_model'

class Dog < SQLite3Model
  self.finalize!
end
```

`Dog` will now have a reader and writer for each column in the presumed `dogs` table.
I.e. if the `dogs` table has a `name` column, `Dog` now has `#name` and `#name=`


If the table name is not easily inferred from the model class name, use `self.table_name=`
before `self.finalize!` in the class definition.

```ruby
class Goose < SQLite3Model
  self.table_name = 'geese'

  self.finalize!
end
```

### Creating a `DBConnection`

Require `db_connection` in any files that you intend to use RubyQuery, and call
`#open`, passing in the your database's file name.

A full implementation of RubyQuery will look something like the following:
```ruby
require_relative 'db_connection'
require_relative 'sqlite3_model'

DBConnection.open('my_db.db')

class Dog < SQLite3Model
  self.finalize!
end
```

## Associations

Classes that inherit from SQLite3Model have access to the macros `has_many`, `belongs_to`, and `has_one_through`.
These macros define instance methods that link the object to another `SQLite3Model` subclass with the
options `foreign_key`, `primary_key`, and `class_name`.

### `belongs_to`

In the example below, `Dog` instances have a method `#owner` that returns an `Owner` object.
Note that `Owner` must inherit from `SQLite3Model`, and the `dogs` table must have a foreign_key `owner_id`.

```ruby
class Dog < SQLite3Model
  self.finalize!

  belongs_to :owner,
    foreign_key: :owner_id
    primary_key: :id,
    class_name 'Owner'
end
```

In the example above, the options passed to `belongs_to` could have been omitted, since
in this case they are all easily derived from the first argument.
The following would be equivalent:
```ruby
class Dog < SQLite3Model
  self.finalize!

  belongs_to :owner
end
```
### `has_many`

Similarly, `has_many` will return an array of objects of type `class_name`.

```ruby
class Owner < SQLite3Model
  self.finalize!

  has_many :dogs,
    foreign_key: :owner_id,
    primary_key: :id,
    class_name 'Dog'
end
```

Again, the options may be omitted if they are easily derived, as they are in this case.

### `has_one_through`

The macro `has_one_through` allows for chaining through multiple `belongs_to` associations.
I.e. if a `Toy` `belongs_to` a `Dog`, and a `Dog` `belongs_to` an `Owner`, a `has_one_through`
association can be written that allows an instance of `Toy` to directly access its `Owner` without
writing `toy.dog.owner`. The arguments to `has_one_through` are the name of the association you wish
to create, the name of the association you are going 'through', and the name of your source association.

```ruby
class Toy < SQLite3Model
  self.finalize!

  belongs_to :dog,
    foreign_key: :dog_id,
    primary_key: :id,
    class_name: 'Dog'

  has_one_through :owner,
    :dog,
    :owner
end
```

## Querying a Database

A class that inherits from `SQLite3Model` will have a few useful methods that
simplify querying the SQLite3 database.

### `::where` and `Relation`

A chainable, lazy `where` class method is provided to subclasses of `SQLite3Model` that
will query the SQLite3 database when necessary. The first and subsequent calls to `where`
produce a `Relation` object which stores the `params` which will be used in the `WHERE` clause
of a SQL query. For example, `Dog.where({name: 'Fido'}).where({owner_id: 3})` will return a `Relation` object
with params `{name: 'Fido', owner_id: 3}`. Calling `#length`, `#to_a`, `#[]`, or any Enumerable
method on a `Relation` object will cause the database to be queried. Calling one of these methods again
on the same `Relation` object will not yield another query, as it will have cached the return of the query.  

The `Relation` methods `#to_a`, `#[]`, or any `Enumerable` method will return either a single instance,
or an array of instances, of the `SQLite3Model` as specified by the `target_class`.

For example, `Dog.where({name: 'Fido'}).first` will return a `Dog` object if such a dog exists in the `dogs` table.

## Demonstration

A couple of `SQLite3Model` subclasses have been created in the `vr_models.rb` file in the demo folder.

For a very quick demo, simply run `ruby vr_models.rb` from within the demo folder to see the output
of various API calls.
**NB:** You must be in the demo folder to successfully run the above command, otherwise it won't find the .sql file to
create the test database with.

To play around with it yourself, open a Ruby REPL such as Pry or IRB and require `vr_models.rb`.
From there, feel free to create new `VRHeadset` objects, play around with associations,
chaining `where` calls together, etc.

**NB:** In this demonstration, the SQLite3 database is generated in the `vr_models.rb` file,
but you can create your database however you wish. Just be sure to `::open` the `DBConnection`.
