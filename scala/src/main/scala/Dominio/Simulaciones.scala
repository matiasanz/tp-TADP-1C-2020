package Dominio

import Dominio.Distribuciones.Probabilidad
import Juegos._

import scala.util.{Success, Try}
import Tipos._
import Juegos.TiposRuleta.ResultadoRuleta

	trait Simulacion{
		def simular(presupuesto: Plata): Distribucion[Marcador]
			= simular(Distribuciones.eventoSeguro[Marcador](  Empece(presupuesto)  ))

		def simular(distribucion: Distribucion[Marcador]): Distribucion[Marcador]
	}

	case object SimulacionVacia extends Simulacion {
		override def simular(distr: Distribucion[Marcador]): Distribucion[Marcador] = identity(distr)
	}

	case class SimulacionCompuesta(simulaciones: List[Simulacion]) extends Simulacion {
		override def simular(distribucion: Distribucion[Marcador]): Distribucion[Marcador]
			= simulaciones.foldLeft(distribucion) {
			case(distribucion, simulacion)=>simulacion.simular(distribucion)
		}
	}

	case class SimulacionSimple[R](juego: Juego[R], apuesta: Apuesta[R]) extends Simulacion {

		override def simular(distribucion: Distribucion[Marcador]): Distribucion[Marcador] ={
			val escenarios = for {
				(marcadorAnterior, probaLlegada) <- distribucion.toList
				(ganancia, probaTransicion) <- juego.distribucionDeGananciasPor(apuesta).toList
			} yield (marcador(marcadorAnterior, apuesta.montoRequerido, ganancia), probaLlegada*probaTransicion)

			Distribuciones.agrupar(escenarios)
		}

		def marcador(marcadorAnterior: Marcador, costo: Plata, ganancia: Plata): Marcador = {
			val saldo = marcadorAnterior.saldo - costo

			//ganancia - costo me diria si gano o pierdo

			if(saldo>=0) Jugue(saldo+ganancia, this, marcadorAnterior) //Juego
			else 		 Saltee(this, marcadorAnterior)	//Salteo
		}
	}