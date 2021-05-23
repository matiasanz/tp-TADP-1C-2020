require_relative 'Boleean'
require_relative 'Persistible'
require_relative 'ClasePersistible'

module ORM

  def self.included(clase)
    clase.extend(ClasePersistible)
  end

  include ObjetoPersistible

end
