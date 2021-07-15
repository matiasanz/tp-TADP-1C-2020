package Dominio
import Marcadores._
import Tipos._

	sealed trait Simulacion{
		def simular(presupuesto: Plata): Distribucion[List[Marcador]] = {
			val puntoDePartida = Marcadores.puntoDePartida(presupuesto)
			simular(Distribuciones.eventoSeguro(puntoDePartida))
		}

		def simular: Distribucion[List[Marcador]] => Distribucion[List[Marcador]]
	}

	case class SimulacionSimple[R](juego: Juego[R], apuesta: Apuesta[R]) extends Simulacion {

		override def simular: Distribucion[List[Marcador]] => Distribucion[List[Marcador]] = distribucion =>{
			val escenarios = for {
				(marcadoresAnteriores, probaLlegada) <- distribucion.listar
				(ganancia, probaTransicion) <- juego.distribucionDeGananciasPor(apuesta).listar
			} yield (marcadoresFinales(marcadoresAnteriores, ganancia), probaLlegada*probaTransicion)

			Distribuciones.agrupar(escenarios)
		}

		def marcadoresFinales(marcadoresAnteriores: List[Marcador], ganancia: Plata)
			= marcadoresAnteriores:+intentarJugar(saldoFinal(marcadoresAnteriores), ganancia)

		def intentarJugar(saldoInicial: Plata, ganancia: Plata): Marcador = {
			if(presupuestoSuficiente(saldoInicial))
				Jugue(ganancia - apuesta.montoRequerido, this) //Juego
			else
				Saltee(this)	//Salteo
		}

		def presupuestoSuficiente(presupuesto: Plata): Boolean
			= presupuesto - apuesta.montoRequerido >=0
	}

	case class SimulacionCompuesta(simulaciones: List[Simulacion]) extends Simulacion {
		override def simular: Distribucion[List[Marcador]] => Distribucion[List[Marcador]]
			= simulaciones.foldLeft(_)((distribucion, simulacion)=>simulacion.simular(distribucion))
	}

	case object SimulacionVacia extends Simulacion {
		override def simular: Distribucion[List[Marcador]] => Distribucion[List[Marcador]]
			= identity
	}

	object Simulaciones{
		def presupuestoSuficiente: (Simulacion, Plata) => Boolean
		= (simulacion, presupuesto) => simulacion match {
			case simple:SimulacionSimple[_] => simple.presupuestoSuficiente(presupuesto)
			case SimulacionCompuesta(simulaciones) => simulaciones.exists(presupuestoSuficiente(_, presupuesto))
			case SimulacionVacia =>true
		}
	}