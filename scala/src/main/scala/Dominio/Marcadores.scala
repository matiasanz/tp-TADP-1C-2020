package Dominio

import Dominio.Tipos.Plata

sealed trait Marcador{
	def simulacion: Simulacion
}

case class Empece(saldo: Plata) extends Marcador{
	override def simulacion: Simulacion = SimulacionVacia
}

abstract class Jugue(val variacion: Plata) extends Marcador
object Jugue{
	def apply(variacionSaldo: Plata, simulacion: Simulacion): Marcador ={
		variacionSaldo match {
			case n if n>0 => Gane(variacionSaldo, simulacion)
			case n if n<0 => Perdi(variacionSaldo.abs, simulacion)
			case 0 => ComoEntre(simulacion)
		}
	}
}

case class Gane(ganancia: Plata, simulacion: Simulacion) extends Jugue(ganancia)
case class Perdi(perdida: Plata, simulacion: Simulacion) extends Jugue((-1)*perdida)
case class ComoEntre(simulacion: Simulacion) 			 extends Jugue(0)
case class Saltee(simulacion: Simulacion) extends Marcador

object Marcadores{
	val puntoDePartida: Plata => List[Marcador]
		= presupuesto => List(Empece(presupuesto))

	def seJugo: List[Marcador] => Boolean = _.exists{
		case _: Jugue => true
		case _ => false
	}

	def saldoFinal: List[Marcador] => Plata = {
		case primeros:+(jugue:Jugue) => jugue.variacion + saldoFinal(primeros)
		case primeros:+(_:Saltee) => saldoFinal(primeros)
		case Empece(saldo)::Nil => saldo
		case marcadores => throw MarcadoresInvalidosException(marcadores)
	}

	def saldoInicial: List[Marcador] => Plata = {
		case Empece(saldo)::_ => saldo
		case marcadores => throw MarcadoresInvalidosException(marcadores)
	}

	def variacionDeSaldo: List[Marcador] => Plata =
		marcadores => saldoFinal(marcadores) - saldoInicial(marcadores)
}
