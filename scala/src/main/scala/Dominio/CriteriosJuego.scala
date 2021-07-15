package Dominio
import Dominio.Distribuciones.Probabilidad
import Dominio.Tipos.Plata
import Simulaciones.presupuestoSuficiente
import Marcadores.variacionDeSaldo

sealed trait CriterioJuego{
	def elegirEntre(presupuesto: Plata, combinaciones: List[Simulacion]): Option[Simulacion]
	= combinaciones
		.filter(presupuestoSuficiente(_, presupuesto))
		.maxByOption(CriterioPonderacion(this).compose(_.simular(presupuesto)))
}

case object Racional extends CriterioJuego
case object Cauto extends CriterioJuego
case object Arriesgado extends CriterioJuego
case object Pesimista extends CriterioJuego //Criterio extra

object CriterioPonderacion{
	def apply(criterio: CriterioJuego): (Distribucion[List[Marcador]]=>Double) = criterio match{
		case Racional 	=> _.promedio(variacionDeSaldo)
		case Arriesgado => variacionesDeSaldo(_).max
		case Cauto 		=> _.probabilidadDeCumplir(variacionDeSaldo(_)>=0)
		case Pesimista 	=> variacionesDeSaldo(_).min
	}

	val variacionesDeSaldo: Distribucion[List[Marcador]]=>Iterable[Plata]
		= _.sucesos.map(variacionDeSaldo)
}