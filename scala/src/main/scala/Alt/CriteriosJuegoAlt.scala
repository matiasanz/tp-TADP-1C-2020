package Alt

import Dominio.Distribuciones.Distribucion
import Dominio.Tipos.Plata
import Dominio._
import Juegos.ResultadoMoneda
import Juegos.TiposRuleta.ResultadoRuleta

import Alt.SimuladorDivertido._

trait CriterioJuego{
	type Combinacion = List[(AnyJuego, AnyApuesta)]
	def	elegirEntre(jugador: Jugador, combinaciones: List[Combinacion]): Combinacion

	def analizarCombinaciones: (Jugador, List[Combinacion]) => List[(Combinacion, Distribucion[Plata])]
	= (jugador, combinaciones) => combinaciones.map{c=> c->simularJuegosDivertido(jugador, c)}
}

case object Racional extends CriterioJuego {

	override def elegirEntre(jugador: Jugador, combinaciones: List[Combinacion]): Combinacion = {
		val puntaje: ((Combinacion, Distribucion[Plata]))=>Plata =
			_._2.map{case(plata, proba) => (jugador.saldo - plata)*proba}.sum
			//TODO duda: plata no necesariamente es ganancia

		analizarCombinaciones(jugador, combinaciones). maxBy(puntaje)._1
	}
}

case object Arriesgado extends CriterioJuego {
	override def elegirEntre(jugador: Jugador, combinaciones: List[Combinacion]): Combinacion = {
		val gananciaMaxima: ((Combinacion, Distribucion[Plata]))=>Plata =
			_._2.map{case(plata, _) => plata}.max

		analizarCombinaciones(jugador, combinaciones).maxBy(gananciaMaxima)._1
	}
}

case object Cauto extends CriterioJuego {

	override def elegirEntre(jugador: Jugador, combinaciones: List[Combinacion]): Combinacion = {
		val probabilidadDeNoPerder: ((Combinacion, Distribucion[Plata]))=>Plata =
			_._2.collect{case (plata, proba) if(jugador.saldo>=plata) =>  proba}.sum

		analizarCombinaciones(jugador, combinaciones)
			.maxBy(probabilidadDeNoPerder)._1
	}
}