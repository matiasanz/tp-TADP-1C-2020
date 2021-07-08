package Dominio

import Dominio.Cauto.{CriterioPonderacion, analizarCombinaciones, probabilidadDeNoPerder}
import Dominio.Marcadores.seJugo
import Dominio.Tipos.Plata

import scala.math.BigDecimal.int2bigDecimal

trait CriterioJuego{
	def	elegirEntre(presupuesto: Plata, combinaciones: List[Simulacion]): Option[Simulacion]

	type CriterioPonderacion[Ord] = ((Simulacion, Distribucion[Marcador]))=>Ord

	def analizarCombinaciones[S:Ordering]
		(presupuesto: Plata, combinaciones: List[Simulacion], criterio: CriterioPonderacion[S]): Option[Simulacion]
		= combinaciones.map(c=> c -> c.simular(presupuesto))
			.filter{_._2.probabilidadDeExito(seJugo(_)) > 0}
			.maxByOption(criterio(_)).map(_._1)
}

/*TODO: Aca quise hacer un template method, pero no pude tipar a Ordenable
 * y en metodos heredados no pude usar tipo generico.
 * El pattern matching lo descarte porque me parecieron metodos medio largos o poco expresivos. Capaz se podria optimizar eso
 * pero al menos por como esta ahora no me convencio
 * Despues, en todos los casos trabajo unicamente con la distribucion, con lo cual podria haber sacado "factor comun" el _._2
 * , pero se me ocurrio que no tiene por que ir orientado a eso. Por ej, un criterio que no quiera incluir tal juego, etc.
 */
case object Racional extends CriterioJuego {

	val puntaje: CriterioPonderacion[Plata] =
		_._2.probabilidades.map{case(marcador, proba) => (marcador.ganancia)*proba}.sum

	override def elegirEntre(presupuesto: Plata, combinaciones: List[Simulacion]): Option[Simulacion]
		= analizarCombinaciones(presupuesto, combinaciones, puntaje)
}

case object Arriesgado extends CriterioJuego {
	val gananciaMaxima: CriterioPonderacion[Plata] = _._2.sucesos.map(_.ganancia).max

	override def elegirEntre(presupuesto: Plata, combinaciones: List[Simulacion]): Option[Simulacion]
		= analizarCombinaciones(presupuesto, combinaciones, gananciaMaxima)
}

case object Cauto extends CriterioJuego {
	/*TODO: Me quedo pendiente sacar el parametro de presupuesto
	 * Mi idea era con los marcadores hacer algun tipo de reduce(lista)
	 * y que el resultante me diera la ganancia total o la perdida, pero no llegue
	 */
	val probabilidadDeNoPerder: CriterioPonderacion[Plata] =
		_._2.probabilidadDeExito(_.ganancia>=0)

	override def elegirEntre(presupuesto: Plata, combinaciones: List[Simulacion]): Option[Simulacion]
		= analizarCombinaciones(presupuesto, combinaciones, probabilidadDeNoPerder)
}

//Criterio extra
case class Miedoso(presupuesto: Plata) extends CriterioJuego {
	val menorPerdida: CriterioPonderacion[Plata] = _._2.sucesos.map(marcador=>0.max(marcador.ganancia)).min

	override def elegirEntre(presupuesto: Plata, combinaciones: List[Simulacion]): Option[Simulacion]
		= analizarCombinaciones(presupuesto, combinaciones, menorPerdida)
}