module AdministradorDeTabla

  def tiene_tabla
    return true if @tabla
    false
  end

  def inicializar_tabla
    @tabla = TADB::DB.table(name)
    analizar_ancestros
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

  # redefino "all_instances"
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

  def analizar_ancestros
    ancestros = []
    ancestors.each do |ancestro|
      break if ancestro == ORM
      ancestros.push(ancestro) if ancestro.is_a?(EntidadPersistible)
    end
    ancestros.delete_at(0)
    agregar_atributos_de_ancestros(ancestros) if ancestros.size > 0
    self
  end

  def agregar_atributos_de_ancestros(ancestros)
    ancestros.reverse!
    atr_persistibles_original = atributos_persistibles.clone
    atr_has_many_original = atributos_has_many.clone
    ancestros.each { |modulo| agregar_atributos_de(modulo.atributos_persistibles, modulo.atributos_has_many) }
    agregar_atributos_de(atr_persistibles_original, atr_has_many_original)
    atributos_has_many = atributos_has_many.uniq if atributos_has_many
    self
  end

  def agregar_atributos_de(hash_atributos, atributos_has_many)
    hash_atributos.each do |nombre, tipo|
      if es_atributo_has_many(atributos_has_many, nombre)
        has_many(tipo, named: nombre)
      else
        has_one(tipo, named: nombre)
      end
    end
    self
  end
end
