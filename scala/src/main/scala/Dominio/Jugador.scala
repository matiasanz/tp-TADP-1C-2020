package Dominio
import Dominio.Tipos.Plata
import Juegos.{CARA, CRUZ, JugadaMoneda, MonedaComun}
import scala.util.{Failure, Success, Try}
import Tipos._

	case class ArbolEscenarios(escenario: Escenario, subescenarios: List[ArbolEscenarios] = List.empty){
		val id = Auxiliar.generateID //TODO: Esto lo uso solo para imprimir
		val situacion = escenario._1
		val probabilidad = escenario._2

		def toStriiing(padre: Int): String ="---------------------\n hijo de "+padre.toString + "\n    "+ toString
	}

object Simulador{
	def simularJuegos[R](jugador: Jugador, juegos: List[(Juego[R], Apuesta[R])]) = {
		val raiz = ArbolEscenarios((Try(jugador), 1))
		juegos.foldLeft(raiz){
			case (arbol, (juego, apuesta) ) => arbol.subescenarios match {
				case Nil => simularAPartirDe(arbol, juego, apuesta)
				case subarboles => arbol.copy(
						subescenarios = subarboles.map(simularAPartirDe(_, juego, apuesta))
				)
			}
		}
	}

	def simularAPartirDe[R](arbol: ArbolEscenarios, juego: Juego[R], apuesta: Apuesta[R]): ArbolEscenarios={
		arbol.situacion match {
		case Success(jugador: Jugador) => arbol.copy(
				subescenarios = simularJuego(jugador, juego, apuesta, arbol.probabilidad).map(ArbolEscenarios(_))
			)

			case Failure(_) => arbol
		}
	}

	def simularJuego[R](jugador: Jugador, juego: Juego[R], apuesta: Apuesta[R], probaAcum: Float=1): List[Escenario] = (
		juego.distribucion.sucesosPosibles //Obviar esta parte
			.toList map{case(suceso, proba)=>(Try(jugador.jugarApuesta(apuesta, suceso)), probaAcum*proba)}
		).groupMap(_._1)(_._2).transform((_, p)=>p.sum).toList


		//TODO ver si vale la pena mover aca las funciones <simular>
	}


	case class Jugador(val saldo: Plata){
		require(saldo>=0)

		def acreditar(monto: Plata) = copy(saldo+monto)
		def desacreditar(monto: Plata): Jugador = acreditar(-monto)

		def jugarApuesta[R](apuesta: Apuesta[R], resultado: R) = {
			desacreditar(apuesta.montoRequerido).acreditar(apuesta.gananciaPorResultado(resultado))
			//TODO: Esto capaz convenga hacerlo desde el lado de la apuesta
		}
	}

