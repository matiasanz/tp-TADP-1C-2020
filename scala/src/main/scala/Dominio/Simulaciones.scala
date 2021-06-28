package Dominio

import Dominio.Distribuciones.{Distribucion, Probabilidad}
import Juegos._

import scala.util.{Success, Try}
import Simulaciones.Escenario
import Tipos._
import Juegos.TiposRuleta.ResultadoRuleta

	case class Simulacion[R](juego: Juego[R], apuesta: Apuesta[R]){
		def simularJuego[R](jugador: Jugador, probaAcum: Probabilidad = 1): List[Escenario] = {

			val escenarios = for{
				(suceso, proba) <- juego.resultadosPosibles.toList
			} yield Try(jugador.jugarApuesta(apuesta, suceso) -> probaAcum * proba)

			escenarios.collect{case Success(escenario)=>escenario}.groupMapReduce(_._1)(_._2)(_+_).toList
		}
	}

	object Simulaciones {
		type Escenario = (Jugador, Probabilidad)

		def simularJuego[R](jugador: Jugador, simulacion: Simulacion[R], proba: Probabilidad = 1.0)
			= simulacion.simularJuego(jugador, proba)

		def simularJuegos(jugador: Jugador, simulaciones: List[Simulacion[_]]): ArbolEscenarios = {
			val raiz = ArbolEscenarios((jugador, 1))
			simulaciones.foldLeft(raiz) {
				case (arbol, simulacion) => analizarSubArbol(arbol, simulacion)
			}
		}

		private
		def analizarSubArbol[R](nodo: ArbolEscenarios, simulacion: Simulacion[R]): ArbolEscenarios = {
			val conSubescenarios = nodo.copy( subescenarios = nodo.subescenarios.map(analizarSubArbol(_, simulacion) ))
			if(nodo == conSubescenarios) analizarNodo(nodo, simulacion)
			else conSubescenarios
			//Si entra en el if quiere decir que: Es el primer intento o no tiene plata suficiente para apostar al juego
		}

		def analizarNodo[R](arbol: ArbolEscenarios, simulacion: Simulacion[R]): ArbolEscenarios
			= arbol.copy(subescenarios = simularJuego(arbol.situacion, simulacion, arbol.probabilidad).map(ArbolEscenarios(_)))
	}

	case class ArbolEscenarios(escenario: Escenario, subescenarios: List[ArbolEscenarios] = List.empty) {
		val situacion: Jugador = escenario._1
		val saldo: Plata = situacion.saldo
		val probabilidad: Probabilidad = escenario._2

		def distribucionFinal: Distribucion[Plata] = hojas.map(a=>a.saldo->a.probabilidad).toMap

		def gananciaRespectoDe(jugador: Jugador): Plata = saldo - jugador.saldo

		def esHoja: Boolean = subescenarios.isEmpty
		def hojas: List[ArbolEscenarios] = asList.filter(_.esHoja)
		def asList: List[ArbolEscenarios] = this::subescenarios.flatMap(_.asList)
	}