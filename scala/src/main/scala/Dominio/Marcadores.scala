package Dominio

import Dominio.Tipos.Plata

trait Marcador{
	def saldo: Plata
	def anteriores: List[Marcador]
	def simulacion: Simulacion
}

object Marcadores{
	def seJugo: Marcador => Boolean = { //TODO: debe haber alguna forma mas linda pero no se me ocurre
		case Jugue(_, _, _) => true
		case Saltee(_, anterior) => seJugo(anterior)
		case _ => false
	}

	def trayecto: Marcador=>List[Simulacion] = m=>m.anteriores.collect{case m if seJugo(m) => m.simulacion}

	/*TODO: La idea era para las simulaciones compuestas, poder aplanarlas a un solo marcador
	 * pero no me termino de cerrar para la implementacion actual. Capaz con un Gane y Perdi tendria mas sentido
	 * Y podria hacerlo mas facil con un case
	def flatten: List[Marcador]=>Marcador = m => {
		require(m.nonEmpty)

		val ultimo = m.last

		if (m.size <= 2) ultimo
		else{
			val simulacionCompuesta = SimulacionCompuesta(m.map(_.simulacion))
			if (m.exists(seJugo(_))) Jugue(ultimo.saldo, simulacionCompuesta, m.head)
			else Saltee(simulacionCompuesta, ultimo)
		}
	}*/
}

case class Empece(saldo: Plata) extends Marcador{
	override def simulacion: Simulacion = SimulacionVacia
	override def anteriores: List[Marcador] = List.empty
}

abstract class MarcadorRuntime(anterior: Marcador) extends Marcador{
	override def anteriores: List[Marcador] = anterior.anteriores:+this
}
case class Jugue(saldo: Plata, simulacion: Simulacion, anterior: Marcador) extends MarcadorRuntime(anterior)
//	case class Gane(jugador: Jugador, simulacion: Simulacion[_]) extends Marcador
//	case class Perdi(jugador: Jugador, simulacion: Simulacion[_]) extends Marcador
case class Saltee(simulacion: Simulacion, anterior: Marcador) extends MarcadorRuntime(anterior){
	def saldo: Plata = anterior.saldo
}
