package Dominio

import Dominio.Marcadores.seJugo
import Dominio.Tipos.Plata

trait CriterioJuego{
	def	elegirEntre(presupuesto: Plata, combinaciones: List[Simulacion]): Option[Simulacion]

	type CriterioPonderacion[Ord] = ((Simulacion, Distribucion[Marcador]))=>Ord

	def analizarCombinaciones[S:Ordering]
		(presupuesto: Plata, combinaciones: List[Simulacion], criterio: CriterioPonderacion[S]): Option[Simulacion]
		= combinaciones.map(c=> c -> c.simular(presupuesto))
			.filter{_._2.probabilidadDeExito(seJugo(_)) > 0}
			.maxByOption(criterio(_)).map(_._1)
}

//TODO: Aca quise hacer un template method, pero no le pude poner un tipo Ordenable
case object Racional extends CriterioJuego {

	val puntaje: Plata=>CriterioPonderacion[Plata] = presupuesto=>
		_._2.probabilidades.map{case(marcador, proba) => (marcador.saldo-presupuesto)*proba}.sum

	override def elegirEntre(presupuesto: Plata, combinaciones: List[Simulacion]): Option[Simulacion]
		= analizarCombinaciones(presupuesto, combinaciones, puntaje(presupuesto))
}

case object Arriesgado extends CriterioJuego {
	val gananciaMaxima: CriterioPonderacion[Plata] = _._2.sucesos.map(_.saldo).max

	override def elegirEntre(presupuesto: Plata, combinaciones: List[Simulacion]): Option[Simulacion]
		= analizarCombinaciones(presupuesto, combinaciones, gananciaMaxima)
}

case object Cauto extends CriterioJuego {

	val probabilidadDeNoPerderRespectoA: Plata=>CriterioPonderacion[Plata] = presupuesto =>
		_._2.probabilidadDeExito(_.saldo>=presupuesto)

	override def elegirEntre(presupuesto: Plata, combinaciones: List[Simulacion]): Option[Simulacion]
		= analizarCombinaciones(presupuesto, combinaciones, probabilidadDeNoPerderRespectoA(presupuesto))
}