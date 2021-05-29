
module AdministradorDeTabla

  # redefino "all_instances" con respecto a EntidadPersistible para cortar con la recursion
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