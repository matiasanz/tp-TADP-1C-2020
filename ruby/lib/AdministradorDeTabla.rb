module AdministradorDeTabla

  def tabla
    @tabla ||= TADB::DB.table(name)
  end

  def insertar_en_tabla(hash)
    tabla.insert(hash)
  end

  def borrar_de_tabla(id)
    tabla.delete(id)
    self
  end

  def borrar_tabla
    tabla.clear
    self
  end

  def hash_atributos_persistidos(id)
    tabla.entries.find { |entrada| entrada.has_value?(id) }
  end

  # redefino "all_instances" con respecto a EntidadPersistible para cortar con la recursion
  def all_instances
    all_instances_de_hijos + tabla.entries.map { |entrada| generar_instancia(entrada) }
  end

  private

  def generar_instancia(entrada_de_tabla)
    instancia = self.new
    instancia.send(:id=, entrada_de_tabla[:id])
    instancia.refresh!
  end

end
