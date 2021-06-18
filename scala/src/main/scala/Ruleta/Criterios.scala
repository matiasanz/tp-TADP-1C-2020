import java.math.RoundingMode

package object Criterios {

	//Docenas
	def docena(numero: Int) = Math.ceil(numero.toDouble/12).toInt

	//Colores
	trait Color

	case object ROJO extends Color
	case object NEGRO extends Color
	case object INCOLORO extends Color

	def color(numero: Int): Color = columna(numero) match{
		case 0 => INCOLORO
		case 1 => if(numero==10) NEGRO else color(numero+2)
		case 2 => colorOpuesto(color(numero+1))
		case 3 => if(numero%9==6) NEGRO else ROJO
	}

	def colorOpuesto(color: Color): Color = color match {
		//TODO Incoloro no tiene opuesto
		case NEGRO => ROJO
		case ROJO => NEGRO
	}

	def columna(numero: Int): Int = {
		if(numero<0 || numero >36){
			throw NumeroNoAdmitidoEnRuletaException(numero)
		}

		val columna = numero%3
		if(columna==0 && numero!=0) 3 else columna
	}

	case class NumeroNoAdmitidoEnRuletaException(numero: Int)
		extends RuntimeException("numero no admitido: "+numero.toString)
}
