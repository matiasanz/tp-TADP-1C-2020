package Juegos

import Dominio.{Apuesta, Distribucion, Distribuciones, Juego, Jugada}

//Juego ********************************************************************
abstract class JuegoMoneda() extends Juego[ResultadoMoneda]{
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

//Resultados ********************************************************************
trait ResultadoMoneda

case object CARA extends ResultadoMoneda
case object CRUZ extends ResultadoMoneda

case class JugadaMoneda(resultadoEsperado: ResultadoMoneda) extends Jugada[ResultadoMoneda] {
	val ganancia = 2

	def cumple(resultado: ResultadoMoneda) = resultado == resultadoEsperado
}