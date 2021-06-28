package Alt

import Alt.SimuladorAlternativo._
import Dominio.Distribuciones.Distribucion
import Dominio.Tipos.Plata
import Dominio.Simulacion

trait CriterioJuego{
	type Combinacion = List[Simulacion[_]]
	def	elegirEntre(presupuesto: Plata, combinaciones: List[Combinacion]): Combinacion

	type CriterioPonderacion[S] = ((Combinacion, Distribucion[Plata]))=>S

	def analizarCombinaciones[S:Ordering]
		(presupuesto: Plata, combinaciones: List[Combinacion], criterio: CriterioPonderacion[S]): Combinacion
		= combinaciones.map(c=> c->simularJuegos(presupuesto, c)).maxBy(criterio(_))._1
}

case object Racional extends CriterioJuego {

	val puntaje: Plata=>CriterioPonderacion[Plata] = presupuesto=>
		_._2.map{case(plata, proba) => (presupuesto - plata)*proba}.sum

	override def elegirEntre(presupuesto: Plata, combinaciones: List[Combinacion]): Combinacion = {
		analizarCombinaciones(presupuesto, combinaciones, puntaje(presupuesto))
	}
}

case object Arriesgado extends CriterioJuego {
	val gananciaMaxima: CriterioPonderacion[Plata] =
		_._2.map{case(plata, _) => plata}.max

	override def elegirEntre(presupuesto: Plata, combinaciones: List[Combinacion]): Combinacion = {
		analizarCombinaciones(presupuesto, combinaciones, gananciaMaxima)
	}
}

case object Cauto extends CriterioJuego {

	val probabilidadDeNoPerder: Plata=>CriterioPonderacion[Plata] = presupuesto =>
		_._2.collect{case (plata, proba) if(presupuesto>=plata) =>  proba}.sum

	override def elegirEntre(presupuesto: Plata, combinaciones: List[Combinacion]): Combinacion = {
		analizarCombinaciones(presupuesto, combinaciones, probabilidadDeNoPerder(presupuesto))
	}
}