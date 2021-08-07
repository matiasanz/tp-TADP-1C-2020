package Juegos
import Dominio.Tipos.Plata
import Dominio._

case object PiedraPapelOTijera
	extends Juego[FormaMano](Distribuciones.ponderada(Map((Piedra, 35), (Papel, 25), (Tijera, 40))))

sealed trait FormaMano
case object Piedra extends FormaMano
case object Papel extends FormaMano
case object Tijera extends FormaMano

case class AMano(queForma: FormaMano)
	extends RatioONada[FormaMano](2) with Jugada[FormaMano]{

	override def apply(inversion: Plata, jugadaOponente: FormaMano): Plata
		= (queForma, jugadaOponente) match {
		case (Piedra, Tijera) | (Papel, Piedra) | (Tijera, Papel) => montoPorGanar(inversion)
		case (miForma, suForma) if miForma == suForma => inversion
		case (Piedra, Papel) | (Papel, Tijera) | (Tijera, Piedra) => montoPorPerder(inversion)
	}
}
