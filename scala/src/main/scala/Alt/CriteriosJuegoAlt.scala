package Alt

import Dominio.Tipos.Plata
import Dominio.{Distribucion, Simulacion, SimulacionCompuesta, SimulacionSimple}

trait CriterioJuego{
	def	elegirEntre(presupuesto: Plata, combinaciones: List[Simulacion]): Simulacion

	type CriterioPonderacion[Ord] = ((Simulacion, Distribucion[Plata]))=>Ord

	def analizarCombinaciones[S:Ordering]
		(presupuesto: Plata, combinaciones: List[Simulacion], criterio: CriterioPonderacion[S]): Simulacion
		= combinaciones.map(c=> c -> c.simular(presupuesto)).maxBy(criterio(_))._1
}

case object Racional extends CriterioJuego {

	val puntaje: Plata=>CriterioPonderacion[Plata] = presupuesto=>
		_._2.probabilidades.map{case(plata, proba) => (presupuesto - plata)*proba}.sum

	override def elegirEntre(presupuesto: Plata, combinaciones: List[Simulacion]): Simulacion = {
		analizarCombinaciones(presupuesto, combinaciones, puntaje(presupuesto))
	}
}

case object Arriesgado extends CriterioJuego {
	val gananciaMaxima: CriterioPonderacion[Plata] = _._2.sucesos.max

	override def elegirEntre(presupuesto: Plata, combinaciones: List[Simulacion]): Simulacion = {
		analizarCombinaciones(presupuesto, combinaciones, gananciaMaxima)
	}
}

case object Cauto extends CriterioJuego {

	val probabilidadDeNoPerder: Plata=>CriterioPonderacion[Plata] = presupuesto =>
		_._2.probabilidades.collect{case(plata, proba) if(presupuesto>=plata) =>  proba}.sum

	override def elegirEntre(presupuesto: Plata, combinaciones: List[Simulacion]): Simulacion = {
		analizarCombinaciones(presupuesto, combinaciones, probabilidadDeNoPerder(presupuesto))
	}
}