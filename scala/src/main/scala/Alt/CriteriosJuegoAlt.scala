package Alt

import Dominio.Distribuciones.Distribucion
import Dominio.Tipos.Plata
import Dominio.{AnyJuego, AnyApuesta, Jugador}

import Alt.SimuladorAlternativo._

trait CriterioJuego{
	type Combinacion = List[(AnyJuego, AnyApuesta)]
	def	elegirEntre(presupuesto: Plata, combinaciones: List[Combinacion]): Combinacion

	type CriterioPonderacion[S] = ((Combinacion, Distribucion[Plata]))=>S

	def analizarCombinaciones[S:Ordering]
		(presupuesto: Plata, combinaciones: List[Combinacion], criterio: CriterioPonderacion[S]): Combinacion
		= combinaciones.map(c=> c->simularJuegos(presupuesto, c)).maxBy(criterio(_))._1
}

case object Racional extends CriterioJuego {

	override def elegirEntre(presupuesto: Plata, combinaciones: List[Combinacion]): Combinacion = {
		val puntaje: CriterioPonderacion[Plata] =
			_._2.map{case(plata, proba) => (presupuesto - plata)*proba}.sum

		analizarCombinaciones(presupuesto, combinaciones, puntaje)
	}
}

case object Arriesgado extends CriterioJuego {
	override def elegirEntre(presupuesto: Plata, combinaciones: List[Combinacion]): Combinacion = {
		val gananciaMaxima: ((Combinacion, Distribucion[Plata]))=>Plata =
			_._2.map{case(plata, _) => plata}.max

		analizarCombinaciones(presupuesto, combinaciones, gananciaMaxima)
	}
}

case object Cauto extends CriterioJuego {

	override def elegirEntre(presupuesto: Plata, combinaciones: List[Combinacion]): Combinacion = {
		val probabilidadDeNoPerder: ((Combinacion, Distribucion[Plata]))=>Plata =
			_._2.collect{case (plata, proba) if(presupuesto>=plata) =>  proba}.sum

		analizarCombinaciones(presupuesto, combinaciones, probabilidadDeNoPerder)
	}
}