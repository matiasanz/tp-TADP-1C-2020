package Dominio

import Dominio.Distribuciones.Probabilidad
import Dominio.Tipos.Plata

trait CriterioJuego{
	type Combinacion = List[(AnyJuego, AnyApuesta)]
	def	elegirEntre(jugador: Jugador, combinaciones: List[Combinacion]): Combinacion

	def analizarCombinaciones: (Jugador, List[Combinacion]) => List[(Combinacion, Plata, Probabilidad)]
		= (jugador, combinaciones) => for {
			combinacion <- combinaciones
			hoja <- Simulaciones.simularJuegos(jugador, combinacion).hojas
		} yield (combinacion, hoja.gananciaRespectoDe(jugador), hoja.probabilidad)
}

case object Racional extends CriterioJuego {

	override def elegirEntre(jugador: Jugador, combinaciones: List[Combinacion]): Combinacion = {
		analizarCombinaciones(jugador, combinaciones)
			.groupMapReduce(_._1) (comb=> comb._2*comb._3) (_+_) //puntaje = proba*plata
			.maxBy(_._2)._1 //max puntaje
	}
}

case object Arriesgado extends CriterioJuego {
	override def elegirEntre(jugador: Jugador, combinaciones: List[Combinacion]): Combinacion = {
		analizarCombinaciones(jugador, combinaciones)
			.maxBy(_._2)._1 //Maxima ganancia
	}
}

case object Cauto extends CriterioJuego {

	override def elegirEntre(jugador: Jugador, combinaciones: List[Combinacion]): Combinacion = {
		analizarCombinaciones(jugador, combinaciones)
			.filter{case(_, ganancia, _)=>ganancia>=0} //No perder plata
			.maxBy(_._3)._1 //Maxima probabilidad
	}
}