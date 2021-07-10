package Dominio

import Dominio.Tipos.Plata

trait Marcador{
	def simulacion: Simulacion
	def saldo: Plata
}

object Marcadores{
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
/*TODO: En algun momento pense dividirlo en GANE y PERDI, pero se repetirian muchas cosas entre uno y otro,
 * pensaba hacer eso y reducirlo con el case tipo el ejemplo del microprocesador cuando reduce las instrucciones
 * pero no llegue a plantearlo de forma que me convenciera
 */

case class Saltee(saldo: Plata, simulacion: Simulacion) extends Marcador
