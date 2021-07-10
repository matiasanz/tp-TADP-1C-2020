package Dominio
import Marcadores._
import Tipos._

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
				(marcadoresAnteriores, probaLlegada) <- distribucion.toList
				(ganancia, probaTransicion) <- juego.distribucionDeGananciasPor(apuesta).toList
			} yield (marcadoresFinales(marcadoresAnteriores, apuesta.montoRequerido, ganancia), probaLlegada*probaTransicion)

			Distribuciones.agrupar(escenarios)
		}

		def marcadoresFinales(marcadoresAnteriores: List[Marcador], costo: Plata, ganancia: Plata)
		 = siguienteMarcador(marcadoresAnteriores, apuesta.montoRequerido, ganancia)::marcadoresAnteriores

		def siguienteMarcador(marcadoresAnteriores: List[Marcador], costo: Plata, ganancia: Plata): Marcador = {
			val saldoInicial = saldo(marcadoresAnteriores)
			val saldoPorApostar = saldoInicial - costo

			if(saldoPorApostar>=0) Jugue(saldoPorApostar+ganancia, this) //Juego
			else 		 		   Saltee(saldoInicial, this)	//Salteo
		}
	}