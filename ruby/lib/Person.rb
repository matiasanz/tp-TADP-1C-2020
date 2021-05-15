require 'Persistible'
require 'Boleean'

class Person

  attr_accessor :first_name, :last_name, :age, :admin
  attr_accessor :some_other_non_persistible_attribute

  has_one String, named: :first_name
  has_one String, named: :last_name
  has_one Numeric, named: :age
  has_one Boolean, named: :admin

end
