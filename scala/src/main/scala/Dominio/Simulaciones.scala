package Dominio

import Dominio.Distribuciones.Probabilidad
import Juegos._

import scala.util.{Success, Try}
import Tipos._
import Juegos.TiposRuleta.ResultadoRuleta

	trait Simulacion{
		def simular(presupuesto: Plata): Distribucion[List[Marcador]]
			= simular(Distribuciones.eventoSeguro[List[Marcador]](  List(Empece(presupuesto))  ))

		def simular(distribucion: Distribucion[List[Marcador]]): Distribucion[List[Marcador]]
	}

	case object SimulacionVacia extends Simulacion {
		override def simular(distr: Distribucion[List[Marcador]]): Distribucion[List[Marcador]] = identity(distr)
	}

	case class SimulacionCompuesta(simulaciones: List[Simulacion]) extends Simulacion {
		override def simular(distribucion: Distribucion[List[Marcador]]): Distribucion[List[Marcador]]
			= simulaciones.foldLeft(distribucion) {
			case(distribucion, simulacion)=>simulacion.simular(distribucion)
		}
	}

	case class SimulacionSimple[R](juego: Juego[R], apuesta: Apuesta[R]) extends Simulacion {

		override def simular(distribucion: Distribucion[List[Marcador]]): Distribucion[List[Marcador]] ={
			val escenarios = for {
				(marcadorAnterior, probaLlegada) <- distribucion.toList
				(ganancia, probaTransicion) <- juego.distribucionDeGananciasPor(apuesta).toList
			} yield (siguienteMarcador(marcadorAnterior, apuesta.montoRequerido, ganancia)::marcadorAnterior, probaLlegada*probaTransicion)

			Distribuciones.agrupar(escenarios)
		}

		def siguienteMarcador(marcadoresAnteriores: List[Marcador], costo: Plata, ganancia: Plata): Marcador = {
			val saldoInicial = Marcadores.saldo(marcadoresAnteriores)
			val saldo = saldoInicial - costo

			if(saldo>=0) Jugue(saldo+ganancia, this) //Juego
			else 		 Saltee(saldoInicial, this)	//Salteo
		}
	}