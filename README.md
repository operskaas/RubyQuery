# RubyQuery

RubyQuery makes it easy to define Ruby classes that can query a SQLite3 database
and refer to each other with associations.

### Use

To use RubyQuery, you must require `sqlite3_model`, define a class that inherits
from SQLite3Model, and call `self.finalize!` in the class definition, as such:

```
require_relative 'sqlite3_model'

class Dog < SQLite3Model
  self.finalize!
end
```
