	package Dominio

	import Dominio.Tipos.Plata
	import scala.util.{Failure, Success, Try}
	import Tipos._

	case class ArbolEscenarios(escenario: Escenario, subescenarios: List[ArbolEscenarios] = List.empty) {
		val situacion = escenario._1
		val probabilidad = escenario._2

		def esHoja = subescenarios.isEmpty
		def puntoMuerto = subescenarios.forall(_.situacion.isFailure)
		def aislar = copy(subescenarios = List.empty)
	}

	object Simulador {
		def simularJuegos[R](jugador: Jugador, juegos: List[(Juego[R], Apuesta[R])]) = {
			val raiz = ArbolEscenarios((Try(jugador), 1))
			juegos.foldLeft(raiz) {case (arbol, (juego, apuesta)) => analizarSubArbol(arbol, juego, apuesta)}
		}

		def analizarSubArbol[R](nodo: ArbolEscenarios, juego: Juego[R], apuesta: Apuesta[R]): ArbolEscenarios = {
			import nodo.subescenarios

			val conSubnodos = nodo.copy( subescenarios = subescenarios.map(analizarSubArbol(_, juego, apuesta) ))

			if (nodo.puntoMuerto || nodo.esHoja) {
				analizarNodo(nodo, juego, apuesta)
			} else conSubnodos
		}

		def analizarNodo[R](arbol: ArbolEscenarios, juego: Juego[R], apuesta: Apuesta[R]): ArbolEscenarios = {

			arbol.situacion match {
				case Success(jugador: Jugador) => arbol.copy(
					subescenarios = simularJuego(jugador, juego, apuesta, arbol.probabilidad).map(ArbolEscenarios(_))
				)

				case Failure(_) => arbol
			}
		}

		def simularJuego[R](jugador: Jugador, juego: Juego[R], apuesta: Apuesta[R], probaAcum: Float = 1): List[Escenario] = (
			juego.distribucion.sucesosPosibles //TODO Esto querria pedirselo directamente al juego, pero me queda ver por donde cortar
				.toList map { case (suceso, proba) => (Try(jugador.jugarApuesta(apuesta, suceso)), probaAcum * proba) }
			).groupMap(_._1)(_._2).transform((_, p) => p.sum).toList
	}


	case class Jugador(val saldo: Plata) {
		require(saldo >= 0)

		def acreditar(monto: Plata) = copy(saldo + monto)

		def desacreditar(monto: Plata): Jugador = acreditar(-monto)

		def jugarApuesta[R](apuesta: Apuesta[R], resultado: R) = {
			desacreditar(apuesta.montoRequerido).acreditar(apuesta.gananciaPorResultado(resultado))
			//TODO: Esto capaz convenga hacerlo desde el lado de la apuesta
		}
	}

