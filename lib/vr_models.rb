require_relative 'sqlite3_model'
require_relative 'db_connection'

class VRHeadset < SQLite3Model
  self.finalize!
end


if __FILE__ == $PROGRAM_NAME
  DBConnection.reset
  a = VRHeadset.find(2)
  p a
  p a.attributes
end
