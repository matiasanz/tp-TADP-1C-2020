package Juegos

import Dominio.{Apuesta, Distribucion, Distribuciones, Jugada}

trait ResultadoMoneda

case object CARA extends ResultadoMoneda
case object CRUZ extends ResultadoMoneda

case class JugadaMoneda(resultado: ResultadoMoneda) extends Jugada(2)

object CorredorMoneda {
	val evaluarApuesta: (Apuesta[JugadaMoneda], ResultadoMoneda) => Boolean =
		(apuesta, resultado) => apuesta.jugada == JugadaMoneda(resultado)
}

case object MonedaComun{
	val distribucion: Distribucion[ResultadoMoneda]
		= Distribuciones.equiprobable(List(CARA, CRUZ))
}

case class MonedaCargada(resultadoMoneda: ResultadoMoneda){
	val distribucion: Distribucion[ResultadoMoneda]
		= Distribuciones.eventoSeguro(resultadoMoneda)
}




