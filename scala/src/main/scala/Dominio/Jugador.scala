package Dominio
import Dominio.Tipos.Plata
import Juegos.TiposRuleta.ResultadoRuleta
import Juegos.{CARA, CRUZ, JugadaMoneda, MonedaCargada, MonedaComun, ROJO, ResultadoMoneda, Ruleta}

import scala.util.{Failure, Success, Try}
object Ti{
	type Escenario = (Try[Jugador], Float)
	type Resultado = ResultadoRuleta with ResultadoMoneda
}

import Ti.Escenario

object Auxiliar{
	var id = 0
	def generateID = {
		id = id+1
		id
	}
}

	case class ArbolEscenarios(escenario: Escenario, subescenarios: List[ArbolEscenarios] = List.empty){
		val id = Auxiliar.generateID
		val situacion = escenario._1
		val probabilidad = escenario._2

		override def toString: String = {
			val exito = situacion.isSuccess

			String.join(
				"\n >>"
			  	, "\n*******"+id+"*********"
				,	"ok?: "+ exito.toString
			    , if(exito) "plata: "+situacion.get.saldo.toString else "Ni idea"
			  	, "proba: "+probabilidad.toString
				, "subarboles: "+subescenarios.map(_.toStriiing(id)).toString
			)
		}

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

	def simularJuego[R](jugador: Jugador, juego: Juego[R], apuesta: Apuesta[R], probaAcum: Float): List[Escenario] = (
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

		def simularJuego[R](juego: Juego[R], apuesta: Apuesta[R]): List[Escenario] = {
				(juego.distribucion.sucesosPosibles //Obviar esta parte
					.toList map{case(suceso, proba)=>(Try(jugarApuesta(apuesta, suceso)), proba)})
					.groupMap(_._1)(_._2).transform((_, p)=>p.sum).toList
		}
		//Obs: aca van a haber sucesos repetidos, con lo cual con un Map me los borra

	}

object X{
	def main(args: Array[String]): Unit = {

		val apM = ApuestaSimple(JugadaMoneda(CARA), 20).compuestaCon(ApuestaSimple(JugadaMoneda(CRUZ), 10))
	//	val apR = ApuestaSimple(AColor(ROJO), 900)


		println(Simulador.simularJuegos(Jugador(30), List(
			(MonedaComun, apM), (MonedaComun, apM), (MonedaComun, apM), (MonedaComun, apM)
//		  , (Ruleta, apR)
		)))

//		println(Map(("h1", 1), ("h2", 2), ("c1", 3), ("c2", 5)).groupBy(_._1.indexOf("h")==0).map( x => (x._1, x._2.values.sum) ).toString)
	}
}
