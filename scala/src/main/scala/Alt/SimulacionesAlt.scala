package Alt

import Dominio.Distribuciones.Distribucion
import Dominio.Tipos.Plata
import Dominio._
import Juegos.ResultadoMoneda
import Juegos.TiposRuleta.ResultadoRuleta

object SimuladorDivertido {

	def monto[R](plata: Plata, apuesta: Apuesta[R], ganancia: Plata) = {
		if (plata >= apuesta.montoRequerido) plata - apuesta.montoRequerido + ganancia
		else plata
	}

	def simularJuego[R](distribucion: Distribucion[Plata], juego: Juego[R], apuesta: Apuesta[R]): Distribucion[Plata] ={
		val escenarios = for {
			(plata, probaLlegada) <- distribucion.toList
			(ganancia, probaTransicion) <- juego.distribucionDeGananciasPor(apuesta).toList
		} yield (monto(plata, apuesta, ganancia) -> probaLlegada * probaTransicion)
		//TODO: Al tenerlo como map se pisan los resultados iguales
		//TODO: La proba tambien depende de si se hizo la apuesta o no... aunque se va a agrupar
		escenarios.groupMapReduce(_._1)(_._2)(_+_)
	}

	def simularJuegosDivertido(jugador: Jugador, juegos: List[(AnyJuego, AnyApuesta)]): Distribucion[Plata]
	= juegos.foldLeft(Distribuciones.eventoSeguro(jugador.saldo)) {
		case (distribucion, (juego: Juego[ResultadoMoneda], apuesta: Apuesta[ResultadoMoneda])) => simularJuego(distribucion, juego, apuesta)
		case (distribucion, (juego: Juego[ResultadoRuleta], apuesta: Apuesta[ResultadoRuleta])) => simularJuego(distribucion, juego, apuesta)
	}
}