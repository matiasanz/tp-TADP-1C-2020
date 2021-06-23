package Dominio

trait Criterio{
	type Combinacion = List[(Juego[Any], Apuesta[Any])]
	def	elegirEntre(jugador: Jugador, combinaciones: List[Combinacion]): Combinacion
}

/*
case object Racional extends Criterio {

	override def elegirEntre(jugador: Jugador, combinaciones: List[Combinacion]): Combinacion = {
		val x = for {
			combinacion <- combinaciones
			hoja <- Simulador.simularJuegos(jugador, combinacion).hojas
		} yield (combinacion, hoja.gananciaRespectoDe(jugador), hoja.probabilidad)

		x.groupMapReduce(_._1) (comb=> comb._2*comb._3) (_+_).reduce{
			(una, otra) => if(una._2 >= otra._2) una else otra
		}._1
	}
}
*/