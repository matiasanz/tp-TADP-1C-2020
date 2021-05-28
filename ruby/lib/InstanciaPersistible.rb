
module InstanciaPersistible

  extend ClasePersistible

  has_one String, named: :id

  #Enunciado
  def save!
    set_defaults_on_empty
    save_attributes!
    tabla.persist(self)
    save_relations!
    self
  end

  #Enunciado
  def forget!
    each_persistible {|p| p.clean_relations}
    tabla.remove(self)
    self.id= nil
  end

  #Enunciado
  def refresh!
    tabla.recuperar_de_db(self)
    self
  end

  def validate!
    each_persistible do
    |atributo|
      valorActual = atributo.get_from(self)
      atributo.validar_instancia(valorActual)
    end
  end

  private
  def save_attributes!
    each_persistible {|atributo| atributo.persistir_de(self)}
  end

  def save_relations!
    each_persistible { |atributo| atributo.persistir_relaciones(self)}
  end

  def set_defaults_on_empty
    each_persistible {|atr| atr.set_default_on_empty(self)}
  end

  def each_persistible(&block)
    self.class.atributos_persistibles.each_value { |atributo| block.call(atributo) }
  end

  def tabla
    self.class.tabla
  end

end