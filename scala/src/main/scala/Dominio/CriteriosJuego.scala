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
		case Racional 	=> _.probabilidades.map(gananciaMedia.tupled).sum
		case Arriesgado => _.sucesos.map(variacionDeSaldo).max
		case Cauto 		=> _.probabilidadDeCumplir(variacionDeSaldo(_)>=0)
		case Pesimista 	=> _.sucesos.map(variacionDeSaldo).min
	}

	val gananciaMedia: (List[Marcador], Probabilidad)=>Double
		= (marcadores, proba) => proba*variacionDeSaldo(marcadores)
}