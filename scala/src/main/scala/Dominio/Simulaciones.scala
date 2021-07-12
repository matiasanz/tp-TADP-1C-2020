package Dominio
import Marcadores._
import Tipos._

	sealed trait Simulacion{
		def simular(presupuesto: Plata): Distribucion[List[Marcador]] = {
			val puntoDePartida = Marcadores.puntoDePartida(presupuesto)
			simular(Distribuciones.eventoSeguro(puntoDePartida))
		}

		def simular: Distribucion[List[Marcador]] => Distribucion[List[Marcador]]

		def presupuestoSuficiente: Plata=>Boolean
	}

	case class SimulacionSimple[R](juego: Juego[R], apuesta: Apuesta[R]) extends Simulacion {

		override def simular: Distribucion[List[Marcador]] => Distribucion[List[Marcador]] = distribucion =>{
			val escenarios = for {
				(marcadoresAnteriores, probaLlegada) <- distribucion.toList
				(ganancia, probaTransicion) <- juego.distribucionDeGananciasPor(apuesta).toList
			} yield (marcadoresFinales(marcadoresAnteriores, ganancia), probaLlegada*probaTransicion)

			Distribuciones.agrupar(escenarios)
		}

		def marcadoresFinales(marcadoresAnteriores: List[Marcador], ganancia: Plata)
			= intentarJugar(saldoFinal(marcadoresAnteriores), ganancia)::marcadoresAnteriores

		def intentarJugar(saldoInicial: Plata, ganancia: Plata): Marcador = {
			if(presupuestoSuficiente(saldoInicial))
				Jugue(ganancia - apuesta.montoRequerido, this) //Juego
			else
				Saltee(saldoInicial, this)	//Salteo
		}

		def presupuestoSuficiente: Plata => Boolean = _ - apuesta.montoRequerido >=0
	}

	case class SimulacionCompuesta(simulaciones: List[Simulacion]) extends Simulacion {
		override def simular: Distribucion[List[Marcador]] => Distribucion[List[Marcador]]
			= simulaciones.foldLeft(_)((distribucion, simulacion)=>simulacion.simular(distribucion))

		def presupuestoSuficiente: Plata=>Boolean
			= presupuesto => simulaciones.exists(_.presupuestoSuficiente(presupuesto))
	}

	case object SimulacionVacia extends Simulacion {
		override def simular: Distribucion[List[Marcador]] => Distribucion[List[Marcador]]
			= identity

		override def presupuestoSuficiente: Plata => Boolean = _=>true
	}