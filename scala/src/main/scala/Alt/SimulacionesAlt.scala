package Alt

import Dominio.Distribuciones.Distribucion
import Dominio.Tipos.Plata
import Dominio._
import Juegos.ResultadoMoneda
import Juegos.TiposRuleta.ResultadoRuleta

object SimuladorAlternativo {

	def simularJuegos(presupuesto: Plata, juegos: List[(AnyJuego, AnyApuesta)]): Distribucion[Plata]
	= juegos.foldLeft(Distribuciones.eventoSeguro(presupuesto)) {
		case (distribucion, (juego: Juego[ResultadoMoneda], apuesta: Apuesta[ResultadoMoneda])) => simularJuego(distribucion, juego, apuesta)
		case (distribucion, (juego: Juego[ResultadoRuleta], apuesta: Apuesta[ResultadoRuleta])) => simularJuego(distribucion, juego, apuesta)
		case (_, (juego, apuesta)) => throw ApuestaIncompatibleException(apuesta, juego)
	}

	def simularJuego[R](distribucion: Distribucion[Plata], juego: Juego[R], apuesta: Apuesta[R]): Distribucion[Plata] ={
		val escenarios = for {
			(saldoInicial, probaLlegada) <- distribucion.toList
			(ganancia, probaTransicion) <- juego.distribucionDeGananciasPor(apuesta).toList
		} yield (monto(saldoInicial, apuesta.montoRequerido, ganancia), probaLlegada*probaTransicion)
		//Al tenerlo como map se pisan los resultados iguales
		escenarios.groupMapReduce(_._1)(_._2)(_+_)
	}

	def monto(saldoInicial: Plata, costo: Plata, ganancia: Plata) = {
		val saldo = saldoInicial - costo

		//TODO: Problema: Cada vez que pasa por un nodo y no puede pagar, lo duplica .'. estaba bien antes?
		if(saldo>=0) saldo+ganancia
		else 		 saldoInicial
	}
}