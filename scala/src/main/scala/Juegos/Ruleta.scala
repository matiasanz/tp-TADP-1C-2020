package Juegos

import Dominio.{Apuesta, Jugada}
import Tablero.color
import Tablero.docena

object TiposRuleta{
	type ResultadoRuleta = Int
}

import TiposRuleta._

	class JugadaRuleta extends Jugada(2) //TODO

	case class ANumero(numero: ResultadoRuleta) extends JugadaRuleta
	case class ADocena(cual: Int) extends JugadaRuleta
	case class AColor(color: Color) extends JugadaRuleta

	object CorredorRuleta {
		def evaluarApuesta(apuesta: Apuesta[JugadaRuleta], resultado: ResultadoRuleta): Boolean = {
			apuesta.jugada match {
				case ANumero(cual) => cual == resultado
				case AColor(cual) => cual == color(resultado)
				case ADocena(cual) => cual == docena(resultado)
			}
		}
	}

	//Colores
	trait Color

	case object ROJO extends Color
	case object NEGRO extends Color
	case object INCOLORO extends Color

	object Tablero{
		//Paridad
		def esPar(numero: Int) = numero%2==0 && numero!=0
		def impar(numero: Int) = !esPar(numero) && numero!=0

		//Docenas
		def docena(numero: Int) = Math.ceil(numero.toDouble / 12).toInt

		//Colores
		def color(numero: Int): Color = columna(numero) match {
			case 0 => INCOLORO
			case 1 => if (numero == 10) NEGRO else color(numero + 2)
			case 2 => colorOpuesto(color(numero + 1))
			case 3 => if (numero % 9 == 6) NEGRO else ROJO
		}

		def colorOpuesto(color: Color): Color = color match {
			case NEGRO => ROJO
			case ROJO => NEGRO
			case INCOLORO => INCOLORO
		}

		def columna(numero: Int): Int = {
			val columna = numero % 3
			if (columna == 0 && numero != 0) 3 else columna
		}
	}