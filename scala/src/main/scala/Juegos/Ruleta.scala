package Juegos

import Dominio._
import Cuadricula.{color, docena, esPar}
import Cuadricula.ResultadoRuleta
import Dominio._

//Juego ********************************************************************
	object Ruleta extends Juego[ResultadoRuleta](Distribuciones.equiprobable((0 to 36).toList))

//Jugadas ********************************************************************
	abstract class JugadaRuleta(override val ratioGanancia: Double)
		extends RatioONada[ResultadoRuleta](ratioGanancia) with JugadaACriterio[ResultadoRuleta]

	case class ANumero(queNumero: ResultadoRuleta) extends JugadaRuleta(36) {
		override def satisfechaPor: ResultadoRuleta => Boolean
			= (_ == queNumero)
	}

	case class ADocena(queDocena: Int)	extends JugadaRuleta(3){
		def satisfechaPor: ResultadoRuleta =>Boolean
			= queDocena == docena(_)
	}
	case class AColor(queColor: Color)	extends JugadaRuleta(2){
		def satisfechaPor: ResultadoRuleta =>Boolean
			= queColor == color(_)
	}

	case class AParidad(seraPar: Boolean) extends JugadaRuleta(2){
		def satisfechaPor: ResultadoRuleta => Boolean
			= resultado => resultado!=0 && seraPar == esPar(resultado)
	}

//Resultados ********************************************************************
	//Colores
	sealed trait Color

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

		def colorOpuesto: Color => Color = {
			case NEGRO => ROJO
			case ROJO => NEGRO
			case otro => throw ColorSinOpuestoException(otro)
		}

		def columna(numero: ResultadoRuleta): Int = {
			val columna = numero % 3
			if (columna == 0 && numero != 0) 3 else columna
		}
	}