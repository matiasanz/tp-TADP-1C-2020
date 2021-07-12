package Juegos

import Dominio._

//Juego ********************************************************************

case object MonedaComun
	extends Juego(Distribuciones.equiprobable[ResultadoMoneda](List(CARA, CRUZ)))

case class MonedaCargada(distribucion: Distribucion[ResultadoMoneda])
	extends Juego(distribucion)

//Resultados ********************************************************************
sealed trait ResultadoMoneda

case object CARA extends ResultadoMoneda
case object CRUZ extends ResultadoMoneda

case class AMoneda(resultadoEsperado: ResultadoMoneda) extends JugadaRatioONada[ResultadoMoneda](2) {

	override def satisfechaPor: ResultadoMoneda => Boolean
		= _ == resultadoEsperado
}