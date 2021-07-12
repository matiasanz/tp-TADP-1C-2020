package Dominio
import Dominio.Distribuciones.Probabilidad
import Dominio.Tipos.Plata
import Marcadores._

sealed trait CriterioJuego{
	def elegirEntre(presupuesto: Plata, combinaciones: List[Simulacion]): Option[Simulacion]
	= combinaciones
		.filter(_.presupuestoSuficiente(presupuesto))
		.maxByOption(CriterioPonderacion(this).compose(_.simular(presupuesto)))
}

case object Racional extends CriterioJuego
case object Cauto extends CriterioJuego
case object Arriesgado extends CriterioJuego
case object Miedoso extends CriterioJuego //Criterio extra

case object CriterioPonderacion{
	def apply(criterio: CriterioJuego): (Distribucion[List[Marcador]]=>Double) = criterio match{
		case Racional 	=> _.probabilidades.map(puntaje.tupled).sum
		case Arriesgado => _.sucesos.map(diferenciaSaldo).max
		case Cauto 		=> _.probabilidadDeCumplir(diferenciaSaldo(_)>=0)
		case Miedoso 	=> _.sucesos.map(perdida).min
	}

	val puntaje: (List[Marcador], Probabilidad)=>Double
		= (marcadores, proba) => proba*diferenciaSaldo(marcadores)

	private def perdida(marcadores: List[Marcador]): Plata
		= diferenciaSaldo(marcadores).min(0.0)
}