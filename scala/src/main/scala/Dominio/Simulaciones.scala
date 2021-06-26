package Dominio

import Dominio.Distribuciones.Probabilidad
import Juegos.{CARA, JugadaMoneda, ResultadoMoneda}

import scala.util.{Failure, Success, Try}
import Simulaciones.Escenario
import Tipos._
import Juegos.TiposRuleta.ResultadoRuleta

	object Simulaciones {
		type Escenario = (Jugador, Probabilidad)

		def simularJuego[R](jugador: Jugador, juego: Juego[R], apuesta: Apuesta[R], probaAcum: Probabilidad = 1): List[Escenario] = {

			val escenarios = for{
				(suceso, proba) <- juego.sucesosPosibles.toList
			} yield Try(jugador.jugarApuesta(apuesta, suceso) -> probaAcum * proba)

			escenarios.collect{case Success(escenario)=>escenario}
		}

		def simularJuegos(jugador: Jugador, juegos: List[(AnyJuego, AnyApuesta)]): ArbolEscenarios = {
			val raiz = ArbolEscenarios((jugador, 1))
			juegos.foldLeft(raiz) {
				case (arbol, (juego: Juego[ResultadoRuleta], apuesta: Apuesta[ResultadoRuleta])) => analizarSubArbol(arbol, juego, apuesta)
				case (arbol, (juego: Juego[ResultadoMoneda], apuesta: Apuesta[ResultadoMoneda])) => analizarSubArbol(arbol, juego, apuesta)
			}
		}

		private

		def analizarSubArbol[R](nodo: ArbolEscenarios, juego: Juego[R], apuesta: Apuesta[R]): ArbolEscenarios = {
			val conSubescenarios = nodo.copy( subescenarios = nodo.subescenarios.map(analizarSubArbol(_, juego, apuesta) ))
			if(nodo == conSubescenarios) analizarNodo(nodo, juego, apuesta)
			else conSubescenarios
			//Si entra en el if quiere decir que: Es el primer intento o no tiene plata suficiente para apostar al juego
		}

		def analizarNodo[R](arbol: ArbolEscenarios, juego: Juego[R], apuesta: Apuesta[R]): ArbolEscenarios
			= arbol.copy(subescenarios = simularJuego(arbol.situacion, juego, apuesta, arbol.probabilidad).map(ArbolEscenarios(_)))
	}

	case class ArbolEscenarios(escenario: Escenario, subescenarios: List[ArbolEscenarios] = List.empty) {
		val situacion: Jugador = escenario._1
		val probabilidad: Probabilidad = escenario._2

		def gananciaRespectoDe(jugador: Jugador): Plata = situacion.saldo - jugador.saldo

		def esHoja: Boolean = subescenarios.isEmpty
		def hojas: List[ArbolEscenarios] = asList.filter(_.esHoja)
		def asList: List[ArbolEscenarios] = this::subescenarios.flatMap(_.asList)
	}