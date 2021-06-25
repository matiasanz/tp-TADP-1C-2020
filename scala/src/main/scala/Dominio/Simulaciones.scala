package Dominio

import Juegos.{CARA, JugadaMoneda, ResultadoMoneda}

import scala.util.{Failure, Success, Try}
import Simulaciones.Escenario
import Tipos._
import Juegos.TiposRuleta.ResultadoRuleta

	object Simulaciones {
		type Escenario = (Try[Jugador], Float)

		def simularJuego[R](jugador: Jugador, juego: Juego[R], apuesta: Apuesta[R], probaAcum: Float = 1): List[Escenario] = {
			val escenarios = juego.sucesosPosibles.toList map {
				case (suceso, proba) => (Try(jugador.jugarApuesta(apuesta, suceso)), probaAcum * proba)
			}

			escenarios.groupMapReduce(_._1)(_._2)(_+_).toList
		}

		def simularJuegos(jugador: Jugador, juegos: List[(AnyJuego, AnyApuesta)]): ArbolEscenarios = {
			val raiz = ArbolEscenarios((Try(jugador), 1))
			juegos.foldLeft(raiz) {
				case (arbol, (juego: Juego[ResultadoRuleta], apuesta: Apuesta[ResultadoRuleta])) => analizarSubArbol(arbol, juego, apuesta)
				case (arbol, (juego: Juego[ResultadoMoneda], apuesta: Apuesta[ResultadoMoneda])) => analizarSubArbol(arbol, juego, apuesta)
			}
		}

		private

		def analizarSubArbol[R](nodo: ArbolEscenarios, juego: Juego[R], apuesta: Apuesta[R]): ArbolEscenarios = {
			val arbol = nodo.copy( subescenarios = nodo.subescenarios.map(analizarSubArbol(_, juego, apuesta) ))

			if (arbol.esPuntoMuerto || arbol.esHoja) analizarNodo(arbol, juego, apuesta)
			else 								 arbol
		}

		def analizarNodo[R](arbol: ArbolEscenarios, juego: Juego[R], apuesta: Apuesta[R]): ArbolEscenarios = {

			arbol.situacion match {
				case Success(jugador: Jugador) => arbol.copy(
					subescenarios = simularJuego(jugador, juego, apuesta, arbol.probabilidad).map(ArbolEscenarios(_))
				)

				case Failure(_) => arbol
			}
		}
	}

	case class ArbolEscenarios(escenario: Escenario, subescenarios: List[ArbolEscenarios] = List.empty) {
		val situacion: Try[Jugador] = escenario._1
		val probabilidad: Float = escenario._2

		def gananciaRespectoDe(jugador: Jugador): Plata = situacion.map(_.saldo).getOrElse(BigDecimal(0)) - jugador.saldo

		def esHoja: Boolean = (situacion.isSuccess && subescenarios.isEmpty) || esPuntoMuerto
		def esPuntoMuerto: Boolean = subescenarios.forall(_.situacion.isFailure)

		def hojas: List[ArbolEscenarios] = asList.filter(_.esHoja)
		def asList: List[ArbolEscenarios] = this::subescenarios.flatMap(_.asList)
	}