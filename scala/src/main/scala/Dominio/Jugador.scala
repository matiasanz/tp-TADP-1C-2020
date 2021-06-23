	package Dominio

	import scala.util.{Failure, Success, Try}
	import Tipos._

	case class ArbolEscenarios(escenario: Escenario, subescenarios: List[ArbolEscenarios] = List.empty) {
		val situacion = escenario._1
		val probabilidad = escenario._2

		def esHoja = subescenarios.isEmpty
		def puntoMuerto = subescenarios.forall(_.situacion.isFailure)

		def asList: List[ArbolEscenarios] = this::subescenarios.flatMap(_.asList)
	}

	object Simulador {

		def simularJuego[R](jugador: Jugador, juego: Juego[R], apuesta: Apuesta[R], probaAcum: Float = 1): List[Escenario] = (
				juego.sucesosPosibles.toList map { case (suceso, proba) => (Try(jugador.jugarApuesta(apuesta, suceso)), probaAcum * proba) }
			).groupMap(_._1)(_._2).transform((_, p) => p.sum).toList

		def simularJuegos[R](jugador: Jugador, juegos: List[(Juego[R], Apuesta[R])]) = {
			val raiz = ArbolEscenarios((Try(jugador), 1))
			juegos.foldLeft(raiz) {case (arbol, (juego, apuesta)) => analizarSubArbol(arbol, juego, apuesta)}
		}

		private

		def analizarSubArbol[R](nodo: ArbolEscenarios, juego: Juego[R], apuesta: Apuesta[R]): ArbolEscenarios = {
			val arbol = nodo.copy( subescenarios = nodo.subescenarios.map(analizarSubArbol(_, juego, apuesta) ))

			if (arbol.puntoMuerto || arbol.esHoja) analizarNodo(arbol, juego, apuesta)
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

	case class Jugador(saldo: Plata) {
		require(saldo >= 0)

		def acreditar(monto: Plata) = copy(saldo + monto)

		def desacreditar(monto: Plata): Jugador = acreditar(-monto)

		def jugarApuesta[R](apuesta: Apuesta[R], resultado: R) = {
			desacreditar(apuesta.montoRequerido).acreditar(apuesta.gananciaPorResultado(resultado))
			//TODO: Esto capaz convenga hacerlo desde el lado de la apuesta
		}
	}

