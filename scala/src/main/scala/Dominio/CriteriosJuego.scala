package Dominio
import Dominio.Distribuciones.Probabilidad
import Dominio.Tipos.Plata
import Marcadores._

trait CriterioJuego{

	type CriterioPonderacion = Distribucion[List[Marcador]]=>Double
	def criterioPonderacion: CriterioPonderacion

	def elegirEntre(presupuesto: Plata, combinaciones: List[Simulacion]): Option[Simulacion]
		= combinaciones
			.filter(_.presupuestoSuficiente(presupuesto))
			.maxByOption(criterioPonderacion.compose(_.simular(presupuesto)))
}

case object Racional extends CriterioJuego {
	val criterioPonderacion: CriterioPonderacion = _.probabilidades.map(puntaje.tupled).sum

	val puntaje: (List[Marcador], Probabilidad)=>Double
		= (marcadores, proba) => proba*diferenciaSaldo(marcadores)
}

case object Arriesgado extends CriterioJuego {
	val criterioPonderacion: CriterioPonderacion = _.sucesos.map(diferenciaSaldo).max
}

case object Cauto extends CriterioJuego {
	val criterioPonderacion: CriterioPonderacion = _.probabilidadDeCumplir(diferenciaSaldo(_)>=0)
}

//Criterio extra
case object Miedoso extends CriterioJuego {
	val criterioPonderacion: CriterioPonderacion = _.sucesos.map(perdida).min

	private def perdida(marcadores: List[Marcador]): Plata
		= diferenciaSaldo(marcadores).min(0.0)
}