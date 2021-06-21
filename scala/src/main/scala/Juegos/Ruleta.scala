package Juegos

import Dominio.{Apuesta, Corredor, Distribucion, Distribuciones, Juego, Jugada}
import Tablero.color
import Tablero.docena
import TiposRuleta._

//Juego ********************************************************************
	object Ruleta extends Juego[ResultadoRuleta](CorredorRuleta){
		val distribucion: Distribucion[ResultadoRuleta] = Distribuciones.equiprobable((0 to 36).toList)
	}

//Corredor **********************************************************************
	object CorredorRuleta extends Corredor{
		def evaluarApuesta(apuesta: Apuesta[JugadaRuleta], resultado: ResultadoRuleta): Boolean = {
			apuesta.jugada match {
				case ANumero(cual) => cual == resultado
				case AColor(cual) => cual == color(resultado)
				case ADocena(cual) => cual == docena(resultado)
				case AParidad(criterio) => criterio(resultado)
			}
		}
	}

//Resultados ********************************************************************
	class JugadaRuleta(val ganancia: Double) extends Jugada //TODO

	case class ANumero(numero: ResultadoRuleta) extends JugadaRuleta(36)
	case class ADocena(cual: Int) 				extends JugadaRuleta(3)
	case class AColor(color: Color) 			extends JugadaRuleta(2)
	case class AParidad(criterio: CriterioParidad) extends JugadaRuleta(2)

//Auxiliares ********************************************************************
	//Colores
	trait Color

	case object ROJO extends Color
	case object NEGRO extends Color
	case object INCOLORO extends Color

	object Tablero{
		//Paridad
		val esPar: CriterioParidad = numero => numero%2==0 && numero!=0
		def impar: CriterioParidad = numero => !esPar(numero) && numero!=0

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

object TiposRuleta{
	type ResultadoRuleta = Int
	type CriterioParidad = ResultadoRuleta=>Boolean
}