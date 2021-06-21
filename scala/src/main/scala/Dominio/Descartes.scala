import Dominio.{Apuesta, Distribucion, Juego}
import Dominio.Tipos.Plata

//TODO Validar que R<Resultado (agregar trait)
package object Descartes {

	class Jugador{
		type Combinacion = List[(Juego[_], List[Apuesta[_]])]

		def jugar(juegos: Combinacion): Unit ={
			//		armarCombinaciones(juegos).map
		}

		def armarCombinaciones(juegos: Combinacion): List[Combinacion] = ???
		//TODO
	}

	abstract class Jugada[R](ganancia: Double) extends (Plata => Apuesta[R]) {
		def criterio: R => Boolean

		override def apply(montoRequerido: Plata): Apuesta[R] = Apuesta(montoRequerido, criterio, ganancia)
	}

	class JugadaIgualdad[R](esperado: R, ganancia: Double) extends Jugada[R](ganancia) {
		val criterio: R => Boolean = actual => actual == esperado
	}

	case class Apuesta[R](montoRequerido: Plata, val criterio: R => Boolean, ganancia: Double)
		extends (R => Plata) {
		require(montoRequerido > 0) //TODO esto se debera validar cuando se llame

		override def apply(resultado: R): Plata = if (criterio(resultado)) ganancia * montoRequerido else 0

		def alcanza(presupuesto: Plata): Boolean = presupuesto < montoRequerido
	}

	trait Juego[R] {
		def distribucion: Distribucion[R]
	}
}