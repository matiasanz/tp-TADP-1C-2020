package Dominio

import Dominio.Tipos.Plata

trait Marcador{
	def simulacion: Simulacion
	def saldo: Plata
}

object Marcadores{
	val puntoDePartida: Plata => List[Marcador]
		= presupuesto => List(Empece(presupuesto))

	def seJugo: List[Marcador] => Boolean = _.exists{
		case Jugue(_, _) => true
		case _ => false
	}

	def saldo: List[Marcador] => Plata = _.head.saldo //Minimamente deberia haber un empece

	def diferenciaSaldo: List[Marcador] => Plata =
		marcadores => marcadores.head.saldo - marcadores.last.saldo
}

case class Empece(saldo: Plata) extends Marcador{
	override def simulacion: Simulacion = SimulacionVacia
}

case class Jugue(saldo: Plata, simulacion: Simulacion) extends Marcador
/*TODO: En algun momento pense dividirlo en GANE y PERDI, pero
 * no senti que me aportara o por lo menos no llegue a plantearlo de forma que me convenciera
 */

case class Saltee(saldo: Plata, simulacion: Simulacion) extends Marcador
