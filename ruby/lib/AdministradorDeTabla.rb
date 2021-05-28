module AdministradorDeTabla

  def tiene_tabla
    return true if @tabla
    false
  end

  def inicializar_tabla
    @tabla = TADB::DB.table(name)
    #analizar_ancestros
    self
  end

  def insertar_en_tabla(hash)
    @tabla.insert(hash)
  end

  def borrar_de_tabla(id)
    @tabla.delete(id)
    self
  end

  def borrar_tabla
    @tabla.clear
  end

  def hash_atributos_persistidos(id)
    @tabla.entries.each{ |entrada| return entrada if entrada.has_value?(id) }
    nil
  end

  # redefino "all_instances" con respecto a EntidadPersistible
  def all_instances
    if @tabla
      all_instances_de_hijos + @tabla.entries.map { |entrada| generar_instancia(entrada) }
    else
        []
    end
  end

  def generar_instancia(entrada_de_tabla)
    instancia = self.new
    instancia.send(:id=, entrada_de_tabla[:id])
    instancia.refresh!
  end

end
