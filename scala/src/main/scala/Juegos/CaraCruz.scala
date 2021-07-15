package Juegos

import Dominio._

//Juego ********************************************************************

case object MonedaComun
	extends Juego[CaraMoneda](Distribuciones.equiprobable(List(CARA, CRUZ)))

case class MonedaCargada(distribucion: Distribucion[CaraMoneda])
	extends Juego(distribucion)

//Resultados ********************************************************************
sealed trait CaraMoneda

case object CARA extends CaraMoneda
case object CRUZ extends CaraMoneda

//Jugadas ********************************************************************
case class ACara(queCara: CaraMoneda) extends JugadaRatioONada[CaraMoneda](2){
	override def satisfechaPor: CaraMoneda => Boolean
		= (_==queCara)
}