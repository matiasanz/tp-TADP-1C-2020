package Dominio
import Dominio.Tipos.Plata
import Dominio.Utils.pesoTotal
import Juegos.{CARA, JugadaMoneda, MonedaComun}

import scala.util.Try
object Ti{
	type Escenario = (Try[Jugador], Float)
}
import Ti.Escenario

	case class ArbolEscenarios(escenario: Escenario, subescenarios: List[ArbolEscenarios] = List.empty){
		def simularJuego[R](juego: Juego[R], apuesta: Apuesta[R]): ArbolEscenarios = {

			if(subescenarios.isEmpty){
				val resultadoAnterior = escenario._1
				if(resultadoAnterior.isSuccess){ //TODO: Esto saltea recien a partir de que rompe. La idea es que se haga desde antes
					copy(subescenarios = resultadoAnterior.get.simularJuego(juego, apuesta).map(ArbolEscenarios(_)))
				} else{
					this
				}
			} else{
				copy(subescenarios=subescenarios.map(_.simularJuego(juego, apuesta)))
			}
		}
	}

	object Simulador{
		//TODO
	}

	case class Jugador(val saldo: Plata){
		require(saldo>=0)

		def acreditar(monto: Plata) = copy(saldo+monto)
		def desacreditar(monto: Plata): Jugador = acreditar(-monto)

		def jugarApuesta[R](apuesta: Apuesta[R], resultado: R) = {
			desacreditar(apuesta.montoRequerido).acreditar(apuesta.gananciaPorResultado(resultado))
			//TODO: Esto capaz convenga hacerlo desde el lado de la apuesta
		}

		def simularJuego[R](juego: Juego[R], apuesta: Apuesta[R]): List[Escenario] = {
			sucesosPosibles(juego, apuesta).groupMap(_._1)(_._2).transform((_, p)=>p.sum).toList
		}

		//TODO Esto pedirselo al juego, ver si conviene sacar la clase distribucion
		def sucesosPosibles[R](juego: Juego[R], apuesta: Apuesta[R]): List[Escenario]
			= juego.distribucion.sucesosPosibles.toList map{case(suceso, proba)=>(Try(jugarApuesta(apuesta, suceso)), proba)}
														//TODO Obs: aca van a haber sucesos repetidos, con lo cual si uso map me los borra

		/*
	def simularJuegos(juegos: List[(Juego[R], Apuesta[R])]): Unit ={
		ArbolEscenarios((Try(this), 1))
		}

		def simularJuegosSucesivos[R](juegos: List[(Juego[R], Apuesta[R])]): List[ArbolEscenarios]
			= juegos match {
				case (juego, apuesta)::juegos => ArbolEscenarios(simularJuego(juego, apuesta)),
						.map(esc => esc.conSubescenarios(simularJuegosSucesivos(esc.resultado, juegos)))
				case Nil =>
		}*/
		/*
		def escenariosPosiblesPara[R](juego: Juego[R], apuesta: Apuesta[R])
			= juego.distribucion.sucesosPosibles
				.groupBy[Boolean]((sucesos) => apuesta.cumple(sucesos._1))
				.map(x => (x._1, x._2.values.sum))

		def jugar[R](juego: Juego[R], apuestas: List[Apuesta[R]]): Unit ={

			type Escenario = (Try[Jugador], Float, List[_])
			val escenarioInicial: Escenario = (Try(this), 1.toFloat, List.empty)

			apuestas.foldLeft(List(escenarioInicial))(
				(escenariosPosibles: List[Escenario], siguienteApuesta: Apuesta[R]) => {

					for{
						(intentoAnterior, proba, subarboles) <- escenariosPosibles

						if(intentoAnterior.isSuccess){
							val siguienteIntento = intentoAnterior.get.intentarApostar(siguienteApuesta)

							if(siguienteIntento.isSuccess){
								juego.distribucion.sucesosPosibles.groupBy[Boolean]((sucesos) => siguienteApuesta.jugada.cumple(sucesos._1)).map(
									x => (x._1, x._2.values.sum) //TODO Sumar las probabilidades de casos exitosos/fallidos
								)

							}
						}
					}.yield subarboles
				}
			)
		}*/


//		def elegirCombinacion()
	}

object X{
	def main(args: Array[String]): Unit = {



//		println(Map(("h1", 1), ("h2", 2), ("c1", 3), ("c2", 5)).groupBy(_._1.indexOf("h")==0).map( x => (x._1, x._2.values.sum) ).toString)
	}
}
