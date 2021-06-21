package Juegos

import Dominio.{Apuesta, Corredor, Distribucion, Distribuciones, Juego, Jugada}

//Juego ********************************************************************
abstract class JuegoMoneda() extends Juego[ResultadoMoneda](CorredorMoneda){
	def distribucion: Distribucion[ResultadoMoneda]
}

case object MonedaComun extends JuegoMoneda{
	val distribucion: Distribucion[ResultadoMoneda]
	= Distribuciones.equiprobable(List(CARA, CRUZ))
}

case class MonedaCargada(resultadoMoneda: ResultadoMoneda) extends JuegoMoneda {
	val distribucion: Distribucion[ResultadoMoneda]
	= Distribuciones.eventoSeguro(resultadoMoneda)
}

//Corredor **********************************************************************

object CorredorMoneda extends Corredor{
	val evaluarApuesta: (Apuesta[JugadaMoneda], ResultadoMoneda) => Boolean =
		(apuesta, resultado) => apuesta.jugada == JugadaMoneda(resultado)
}

//Resultados ********************************************************************
trait ResultadoMoneda

case object CARA extends ResultadoMoneda
case object CRUZ extends ResultadoMoneda

case class JugadaMoneda(resultado: ResultadoMoneda) extends Jugada{
	val ganancia = 2
}