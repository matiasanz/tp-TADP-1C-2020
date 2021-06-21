package Dominio
import Dominio.Tipos.Plata
import scala.util.Try

	case class Jugador(val presupuesto: Plata){
		require(presupuesto>=0)

		def intentarApostar[R](apuesta: Apuesta[R]): Try[Jugador] ={
			val saldo = apuesta.saldoPorApostar(presupuesto)
			Try(copy(presupuesto = saldo))
		}

		def jugar[R](juego: Juego[R], apuestas: List[Apuesta[R]]): Unit ={
			for{
				apuesta <- apuestas
				jugador = intentarApostar(apuesta)
				escenariosPosibles = juego.distribucion.sucesosPosibles
				escenario <- escenariosPosibles

				//TODO...

			} yield apuestas
		}


//		def elegirCombinacion()
	}
