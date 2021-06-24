package Dominio

//TODO Usar max by

/*TODO:
 * Dudas ->
 * 1) No lo puedo ejecutar por los tipos
 * 2) Al simular una combinacion, se saltean los juegos que no se pueden pagar. Es importante?
 * 3) En los groupMap, probe parametrizar la funcion del medio y no pude hacer que matchee el tipo
 * Pendientes ->
 * 1) Testear
 * 2) Sacar codigo repetido (los reduce)
 *  >> Los dos primeros eligen agrupando, mientras que el tercero compara todos contra todos
*/

trait CriterioJuego{
	type Combinacion = List[(Juego[Any], Apuesta[Any])]
	def	elegirEntre(jugador: Jugador, combinaciones: List[Combinacion]): Combinacion

	def analizarCombinaciones(jugador: Jugador, combinaciones: List[Combinacion]) = {
		for {
			combinacion <- combinaciones
			hoja <- Simuladores.simularJuegos(jugador, combinacion).hojas
		} yield (combinacion, hoja.gananciaRespectoDe(jugador), hoja.probabilidad)
	}
}

case object Racional extends CriterioJuego {

	override def elegirEntre(jugador: Jugador, combinaciones: List[Combinacion]): Combinacion = {
		analizarCombinaciones(jugador, combinaciones)
			.groupMapReduce(_._1) (comb=> comb._2*comb._3) (_+_).reduce{
			(una, otra) => if(una._2 >= otra._2) una else otra
		}._1
}


case object Arriesgado extends CriterioJuego {
	override def elegirEntre(jugador: Jugador, combinaciones: List[Combinacion]): Combinacion = {
		analizarCombinaciones(jugador, combinaciones)
			.groupMapReduce(_._1) (comb=> comb._2) (_+_).reduce{
				(una, otra) => if(una._2 >= otra._2) una else otra
			}._1
	}
}

case object Cauto extends CriterioJuego {

	override def elegirEntre(jugador: Jugador, combinaciones: List[Combinacion]): Combinacion = {
		analizarCombinaciones(jugador, combinaciones)
			.reduce{
				(una, otra) => if(una._3 >= otra._3) una else otra
			}._1
		}
	}
}
