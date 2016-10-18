require_relative '../lib/sqlite3_model'
require_relative '../lib/db_connection'

commands = [
  "rm './vr.db'",
  "cat './vr.sql' | sqlite3 './vr.db'"
]
# resetting database
commands.each { |command| `#{command}` }

DBConnection.open('./vr.db')


class VRHeadset < SQLite3Model
  self.finalize!

  belongs_to :manufacturer,
    class_name: 'Company'
end

class Company < SQLite3Model
  self.finalize!

  has_many :vr_headsets,
    foreign_key: :manufacturer_id,
    class_name: 'VRHeadset'
end

class VRApp < SQLite3Model
  self.finalize!

  belongs_to :vr_headset,
    class_name: 'VRHeadset',
    foreign_key: :headset_id

  has_one_through :licensor,
    :vr_headset,
    :manufacturer
end


if __FILE__ == $PROGRAM_NAME

  oculus = Company.where({name: 'Oculus'}) # lazy, chainable where method returns a Relation
  p oculus
  oculus = oculus.where({id: 1})
  p oculus
  oculus = oculus.first # calling first on the Relation returns an actual Company object
  p oculus
  p oculus.vr_headsets.to_a

  spt = VRApp.find(1)
  p spt
  p spt.vr_headset
  p spt.licensor # demonstrating has_one_through
end
