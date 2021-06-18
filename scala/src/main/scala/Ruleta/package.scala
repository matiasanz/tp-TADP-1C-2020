import Utils.esPar

import scala.::

package object Colores {
	trait Color

	case object ROJO extends Color
	case object NEGRO extends Color

	def color(numero: Int): Color = columna(numero) match{
		case 1 => if(numero==10) NEGRO else color(numero+2)
		case 2 => colorOpuesto(color(numero+1))
		case 3 => if(numero%9==6) NEGRO else ROJO
	}

	def colorOpuesto(color: Color): Color = color match {
		case NEGRO => ROJO
		case ROJO => NEGRO
	}

	def columna(numero: Int): Int = {
		if(numero<0 || numero >36){
			throw new RuntimeException("numero no admitido: "+numero.toString)
		}

		val columna = numero%3
		if(columna==0) 3 else columna
	}
}
