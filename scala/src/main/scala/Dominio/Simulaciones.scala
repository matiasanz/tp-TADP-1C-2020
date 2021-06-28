package Dominio

import Dominio.Distribuciones.Probabilidad
import Juegos._

import scala.util.{Success, Try}
import Simulaciones.Escenario
import Tipos._
import Juegos.TiposRuleta.ResultadoRuleta

	sealed trait Marcador
	case object Empece extends Marcador
	case class Jugue(plata: Plata) extends Marcador
//	case class Gane(jugador: Jugador, simulacion: Simulacion[_]) extends Marcador
//	case class Perdi(jugador: Jugador, simulacion: Simulacion[_]) extends Marcador
	case object Saltee extends Marcador


	trait Simulacion{
		def simular(presupuesto: Plata): Distribucion[Plata] = simular(Distribuciones.eventoSeguro(presupuesto))
		def simular(distribucion: Distribucion[Plata]): Distribucion[Plata]
	}

	case class SimulacionCompuesta(simulaciones: List[Simulacion]) extends Simulacion {
		override def simular(distribucion: Distribucion[Plata]): Distribucion[Plata]
			= simulaciones.foldLeft(distribucion) {
			case(distribucion, simulacion)=>simulacion.simular(distribucion)
		}
	}

	case class SimulacionSimple[R](juego: Juego[R], apuesta: Apuesta[R]) extends Simulacion {
		//Esto seria la otra alternativa
		override def simular(distribucion: Distribucion[Plata]): Distribucion[Plata] ={
			val escenarios = for {
				(saldoInicial, probaLlegada) <- distribucion.toList
				(ganancia, probaTransicion) <- juego.distribucionDeGananciasPor(apuesta).toList
			} yield (montoFinal(saldoInicial, apuesta.montoRequerido, ganancia), probaLlegada*probaTransicion)

			Distribuciones.agrupar(escenarios)
		}

		def montoFinal(saldoInicial: Plata, costo: Plata, ganancia: Plata) = {
			val saldo = saldoInicial - costo

			//ganancia - costo me diria si gano o pierdo

			if(saldo>=0) saldo+ganancia //Juego
			else 		 saldoInicial	//Salteo
		}

//TODO **************************** Aca arranaca segunda alternativa ****************************************
		def simularJuego[R](jugador: Jugador, probaAcum: Probabilidad = 1): List[Escenario] = {

			val escenarios = for{
				(suceso, proba) <- juego.resultadosPosibles.toList
			} yield Try(jugador.jugarApuesta(apuesta, suceso) -> probaAcum * proba)

			Distribuciones.agrupar(escenarios.collect{case Success(escenario)=>escenario}).toList
		}


	}


	object Simulaciones {
		type Escenario = (Jugador, Probabilidad)

		def simularJuego[R](jugador: Jugador, simulacion: SimulacionSimple[R], proba: Probabilidad = 1.0)
			= simulacion.simularJuego(jugador, proba)

		def simularJuegos(jugador: Jugador, simulaciones: List[SimulacionSimple[_]]): ArbolEscenarios = {
			val raiz = ArbolEscenarios((jugador, 1))
			simulaciones.foldLeft(raiz) {
				case (arbol, simulacion) => analizarSubArbol(arbol, simulacion)
			}
		}

		private
		def analizarSubArbol[R](nodo: ArbolEscenarios, simulacion: SimulacionSimple[R]): ArbolEscenarios = {
			val conSubescenarios = nodo.copy( subescenarios = nodo.subescenarios.map(analizarSubArbol(_, simulacion) ))
			if(nodo == conSubescenarios) analizarNodo(nodo, simulacion)
			else conSubescenarios
			//Si entra en el if quiere decir que: Es el primer intento o no tiene plata suficiente para apostar al juego
		}

		def analizarNodo[R](arbol: ArbolEscenarios, simulacion: SimulacionSimple[R]): ArbolEscenarios
			= arbol.copy(subescenarios = simularJuego(arbol.situacion, simulacion, arbol.probabilidad).map(ArbolEscenarios(_)))
	}

	case class ArbolEscenarios(escenario: Escenario, subescenarios: List[ArbolEscenarios] = List.empty) {
		val situacion: Jugador = escenario._1
		val saldo: Plata = situacion.saldo
		val probabilidad: Probabilidad = escenario._2

		def distribucionFinal: Distribucion[Plata] = {
			val distr = hojas.map(h=>h.saldo->h.probabilidad).toMap
			Distribucion(distr)
		}

		def gananciaRespectoDe(jugador: Jugador): Plata = saldo - jugador.saldo

		def esHoja: Boolean = subescenarios.isEmpty
		def hojas: List[ArbolEscenarios] = asList.filter(_.esHoja)
		def asList: List[ArbolEscenarios] = this::subescenarios.flatMap(_.asList)
	}