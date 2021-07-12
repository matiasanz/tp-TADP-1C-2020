package Dominio

import Dominio.Tipos.Plata

sealed trait Marcador{
	def simulacion: Simulacion
}

case class Empece(saldo: Plata) extends Marcador{
	override def simulacion: Simulacion = SimulacionVacia
}

sealed trait Jugue extends Marcador
object Jugue{
	def apply(variacionSaldo: Plata, simulacion: Simulacion): Marcador ={
		if(variacionSaldo>=0) Gane(variacionSaldo, simulacion)
		else Perdi((-1)*variacionSaldo, simulacion)
	}
}

case class Gane(ganancia: Plata, simulacion: Simulacion) extends Jugue
case class Perdi(perdida: Plata, simulacion: Simulacion) extends Jugue
case class Saltee(saldo: Plata, simulacion: Simulacion) extends Marcador

object Marcadores{
	val puntoDePartida: Plata => List[Marcador]
		= presupuesto => List(Empece(presupuesto))

	def seJugo: List[Marcador] => Boolean = _.exists{
		case _: Jugue => true
		case _ => false
	}

	def saldoFinal: List[Marcador] => Plata = {
		case Gane(ganancia, _)::resto => ganancia + saldoFinal(resto)
		case Perdi(perdida, _)::resto => (-1)*perdida + saldoFinal(resto)
		case (_:Saltee)::resto => saldoFinal(resto)
		case Nil:+Empece(saldo) => saldo
		case marcadores => throw MarcadoresInvalidosException(marcadores)
	}

	def saldoInicial: List[Marcador] => Plata = {
		case _:+Empece(saldo) => saldo
		case marcadores => throw MarcadoresInvalidosException(marcadores)
	}

	def variacionDeSaldo: List[Marcador] => Plata =
		marcadores => saldoFinal(marcadores) - saldoInicial(marcadores)
}
