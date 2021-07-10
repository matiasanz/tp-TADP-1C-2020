package Dominio

import Dominio.Cauto.{CriterioPonderacion, elegirSegunCriterio, probabilidadDeNoPerder}
import Dominio.Tipos.Plata

import scala.math.BigDecimal.int2bigDecimal
import Marcadores._

trait CriterioJuego{
	def	elegirEntre(presupuesto: Plata, combinaciones: List[Simulacion]): Option[Simulacion]

	type CriterioPonderacion[Ord] = ((Simulacion, Distribucion[List[Marcador]]))=>Ord

	def elegirSegunCriterio[S:Ordering]
		(presupuesto: Plata, combinaciones: List[Simulacion], criterio: CriterioPonderacion[S]): Option[Simulacion]
		= combinaciones.map(c=> c -> c.simular(presupuesto))
			.filter{_._2.probabilidadDeExito(seJugo(_)) > 0}
			.maxByOption(criterio).map(_._1)
}

/*TODO: Aca quise hacer un template method, pero no pude tipar a Ordenable
 * y en metodos heredados no pude usar tipo generico.
 * El pattern matching lo descarte porque me parecieron metodos medio largos o poco expresivos. Capaz se podria optimizar eso
 * pero al menos por como esta ahora no me convencio.
 * Por otro lado, tratandose de un criterio, tiene logica que vayan a aumentar las subclases primero que las operaciones
 * o, llegado el caso que aumenten las operaciones, supongo que vendrian asociadas
 * Despues, en todos los casos trabajo unicamente con la distribucion, con lo cual podria haber sacado "factor comun" el _._2
 * , pero se me ocurrio que no tiene por que ir orientado a eso. Por ej, un criterio que no quiera incluir tal juego, etc.
 */
case object Racional extends CriterioJuego {

	val puntaje: CriterioPonderacion[Plata] =
		_._2.probabilidades.map{case(marcadores, proba) => diferenciaSaldo(marcadores)*proba}.sum

	override def elegirEntre(presupuesto: Plata, combinaciones: List[Simulacion]): Option[Simulacion]
		= elegirSegunCriterio(presupuesto, combinaciones, puntaje)
}

case object Arriesgado extends CriterioJuego {
	val gananciaMaxima: CriterioPonderacion[Plata] = _._2.sucesos.map(diferenciaSaldo(_)).max

	override def elegirEntre(presupuesto: Plata, combinaciones: List[Simulacion]): Option[Simulacion]
		= elegirSegunCriterio(presupuesto, combinaciones, gananciaMaxima)
}

case object Cauto extends CriterioJuego {

	val probabilidadDeNoPerder: CriterioPonderacion[Plata] =
		_._2.probabilidadDeExito(diferenciaSaldo(_)>=0)

	override def elegirEntre(presupuesto: Plata, combinaciones: List[Simulacion]): Option[Simulacion]
		= elegirSegunCriterio(presupuesto, combinaciones, probabilidadDeNoPerder)
}

//Criterio extra
case object Miedoso extends CriterioJuego {
	val menorPerdida: CriterioPonderacion[Plata] = _._2.sucesos.map(diferenciaSaldo(_).min(0)).min

	override def elegirEntre(presupuesto: Plata, combinaciones: List[Simulacion]): Option[Simulacion]
		= elegirSegunCriterio(presupuesto, combinaciones, menorPerdida)
}