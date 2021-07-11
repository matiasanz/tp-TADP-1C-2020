package Juegos

import Dominio._
import Cuadricula.{color, docena, esPar}
import Cuadricula.ResultadoRuleta

//Juego ********************************************************************
	object Ruleta extends Juego[ResultadoRuleta](Distribuciones.equiprobable((0 to 36).toList))

//Resultados ********************************************************************
	abstract class JugadaRuleta(val ratioGanancia: Double) extends Jugada[ResultadoRuleta]

	case class ANumero(numero: ResultadoRuleta) extends JugadaRuleta(36){
		def satisfechaPor: ResultadoRuleta => Boolean
			= (_ == numero)
	}

	case class ADocena(cual: Int)	extends JugadaRuleta(3){
		def satisfechaPor: ResultadoRuleta =>Boolean
			= docena(_) == cual
	}
	case class AColor(queColor: Color)	extends JugadaRuleta(2){
		def satisfechaPor: ResultadoRuleta =>Boolean
			= queColor == color(_)
	}

	case class AParidad(siONo: Boolean) extends JugadaRuleta(2){
		def satisfechaPor: ResultadoRuleta => Boolean
			= resultado => resultado!=0 && siONo == esPar(resultado)
	}

//Auxiliares ********************************************************************
	//Colores
	trait Color

	case object ROJO extends Color
	case object NEGRO extends Color
	case object INCOLORO extends Color

	object Cuadricula{
		type ResultadoRuleta = Int

		//Paridad
		val esPar: ResultadoRuleta=>Boolean = numero => numero%2==0

		//Docenas
		def docena(numero: ResultadoRuleta): Int = Math.ceil(numero.toDouble / 12).toInt

		//Colores
		def color(numero: ResultadoRuleta): Color = columna(numero) match {
			case 3 => if (numero % 9 == 6) NEGRO else ROJO
			case 2 => colorOpuesto(color(numero + 1))
			case 1 => if (numero == 10) NEGRO else color(numero + 2)
			case 0 => INCOLORO
		}

		def colorOpuesto(color: Color): Color = color match {
			case NEGRO => ROJO
			case ROJO => NEGRO
//			case INCOLORO => INCOLORO
		}

		def columna(numero: ResultadoRuleta): Int = {
			val columna = numero % 3
			if (columna == 0 && numero != 0) 3 else columna
		}
	}