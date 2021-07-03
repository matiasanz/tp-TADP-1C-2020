package Dominio

import Dominio.Tipos.Plata

trait Marcador{
	def saldo: Plata
	def anteriores: List[Marcador] //
	def simulacion: Simulacion
}

object Marcadores{
	//TODO: Es raro. Lo deje asi provisorio, pero no tuve tiempo en la semana de replantearlo
	def seJugo: Marcador => Boolean = {
		case Jugue(_, _, _) => true
		case Saltee(_, anterior) => seJugo(anterior)
		case _ => false
	}
}

case class Empece(saldo: Plata) extends Marcador{
	override def simulacion: Simulacion = SimulacionVacia
	override def anteriores: List[Marcador] = List.empty
}

abstract class MarcadorRuntime(anterior: Marcador) extends Marcador{
	override def anteriores: List[Marcador] = anterior.anteriores:+this
}
case class Jugue(saldo: Plata, simulacion: Simulacion, anterior: Marcador) extends MarcadorRuntime(anterior)
/*TODO: En algun momento pense dividirlo en GANE y PERDI, pero se repetirian muchas cosas entre uno y otro,
 * hubiera estado bueno reducirlo con el case tipo el ejemplo del microprocesador cuando reduce las instrucciones
 * pero no llegue a plantearlo de forma que me convenciera
 */

case class Saltee(simulacion: Simulacion, anterior: Marcador) extends MarcadorRuntime(anterior){
	def saldo: Plata = anterior.saldo
}
