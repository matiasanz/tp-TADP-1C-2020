package Dominio

import Dominio.Tipos.Plata

sealed trait Marcador{
	def simulacion: Simulacion
	def saldo: Plata
}

object Marcadores{
	val puntoDePartida: Plata => List[Marcador]
		= presupuesto => List(Empece(presupuesto))

	def seJugo: List[Marcador] => Boolean = _.exists{
		case _: Jugue => true
		case _ => false
	}

	def saldo: List[Marcador] => Plata = _.head.saldo //Minimamente deberia haber un empece

	def variacionDeSaldo: List[Marcador] => Plata =
		marcadores => marcadores.head.saldo - marcadores.last.saldo
}

case class Empece(saldo: Plata) extends Marcador{
	override def simulacion: Simulacion = SimulacionVacia
}

case class Jugue(saldo: Plata, simulacion: Simulacion) extends Marcador
case class Saltee(saldo: Plata, simulacion: Simulacion) extends Marcador