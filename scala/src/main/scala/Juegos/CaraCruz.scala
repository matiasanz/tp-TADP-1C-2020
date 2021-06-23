package Juegos

import Dominio.Distribuciones.Distribucion
import Dominio.{Apuesta, Distribuciones, Juego, Jugada}

//Juego ********************************************************************
abstract class JuegoMoneda(distribucion: Distribucion[ResultadoMoneda])	extends Juego(distribucion)

case object MonedaComun
	extends JuegoMoneda(Distribuciones.equiprobable(List(CARA, CRUZ)))

case class MonedaCargada(resultado: ResultadoMoneda)
	extends JuegoMoneda(Distribuciones.eventoSeguro(resultado))

/* TODO: Duda - El enunciado primero dice que es evento seguro y en la consigna dice ponderado
case class MonedaCargada(probaCara: Float, probaCruz: Float)
	extends JuegoMoneda(Distribuciones.ponderada[ResultadoMoneda](Map((CARA, probaCara), (CRUZ, probaCruz))))
*/

//Resultados ********************************************************************
trait ResultadoMoneda

case object CARA extends ResultadoMoneda
case object CRUZ extends ResultadoMoneda

case class JugadaMoneda(resultadoEsperado: ResultadoMoneda) extends Jugada[ResultadoMoneda] {
	val ganancia = 2

	def cumple(resultado: ResultadoMoneda) = resultado == resultadoEsperado
}