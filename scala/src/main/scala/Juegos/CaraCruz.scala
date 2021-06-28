package Juegos

import Dominio._

//Juego ********************************************************************

case object MonedaComun
	extends Juego(Distribuciones.equiprobable[ResultadoMoneda](List(CARA, CRUZ)))

case class MonedaCargada(distribucion: Distribucion[ResultadoMoneda])
	extends Juego(distribucion)

//Resultados ********************************************************************
trait ResultadoMoneda

case object CARA extends ResultadoMoneda
case object CRUZ extends ResultadoMoneda

case class JugadaMoneda(resultadoEsperado: ResultadoMoneda) extends Jugada[ResultadoMoneda] {
	val ganancia = 2

	def cumple(resultado: ResultadoMoneda) = resultado == resultadoEsperado
}