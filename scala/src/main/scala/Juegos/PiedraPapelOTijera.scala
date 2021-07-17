package Juegos
import Dominio.Tipos.Plata
import Dominio._

case object PiedraPapelOTijera
	extends Juego[FormaMano](Distribuciones.ponderada(Map((Piedra, 35), (Papel, 25), (Tijera, 40))))

class FormaMano(val ganaContra: FormaMano, val pierdeContra: FormaMano){
	def jugarContra: FormaMano => ResultadoContraOponente = {
		case _: this.type => Empata
		case _: ganaContra.type => Gana
		case _: pierdeContra.type => Pierde //Pude dejarlo como '_', pero preferi dejarlo explicito por si se agrega otro, que salte y se tenga que definir que hacer
		case otro => throw FormaManoInesperadaException(this, otro)
	}

	//TODO: Intente hacerlo de esta forma pero tambien rompe
	/*def jugarContra: FormaMano => ResultadoContraOponente = {
		case siMismo if siMismo==this => Empata
		case perdedor if perdedor==ganaContra => Gana
		case ganador if ganador==pierdeContra=> Pierde //Pude dejarlo como '_', pero preferi dejarlo explicito por si se agrega otro, que salte y se tenga que definir que hacer
		case otro => throw FormaManoInesperadaException(this, otro)
	}*/
}

case object Piedra extends FormaMano(Tijera, Papel)
case object Papel extends FormaMano(Piedra, Tijera)
case object Tijera extends FormaMano(Papel, Piedra)

case class AMano(queForma: FormaMano)
	extends RatioONada[FormaMano](2) with Jugada[FormaMano]{

	override def apply(inversion: Plata, jugadaOponente: FormaMano): Plata
		= queForma.jugarContra(jugadaOponente) match {
		case Gana => montoPorGanar(inversion)
		case Empata => montoPorEmpatar(inversion)
		case Pierde => montoPorPerder(inversion)
	}

	val montoPorEmpatar: Plata=>Plata = identity
}

sealed trait ResultadoContraOponente

case object Gana extends ResultadoContraOponente
case object Empata extends ResultadoContraOponente
case object Pierde extends ResultadoContraOponente