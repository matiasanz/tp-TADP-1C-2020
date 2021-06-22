package Dominio

	import Tipos.Plata

	import scala.util.Try

	abstract class Juego[R](){
		def distribucion: Distribucion[R]
	}

	trait Jugada[R]{
		def montoPorGanar(inversion: Plata): Plata = ganancia*inversion
		def ganancia: Double
		def cumple(resultado: R): Boolean
	}

	trait Apuesta[R]{
		def montoRequerido: Plata
		def compuestaCon(apuesta: Apuesta[R]): ApuestaCompuesta[R]
		def gananciaPorResultado(resultado: R): Plata
	}

	case class ApuestaSimple[R](val jugada: Jugada[R], val montoRequerido: Plata)
		extends Apuesta[R] {
		override def compuestaCon(apuesta: Apuesta[R]) = ApuestaCompuesta(this::List(apuesta))
		override def gananciaPorResultado(resultado: R): Plata = if(jugada.cumple(resultado)) jugada.montoPorGanar(montoRequerido) else 0
	}

	case class ApuestaCompuesta[R](apuestas: List[Apuesta[R]]) extends Apuesta[R]{
		override def montoRequerido: Plata = apuestas.map(_.montoRequerido).sum
		override def compuestaCon(apuesta: Apuesta[R]) = copy(apuestas:+apuesta)
		override def gananciaPorResultado(resultado: R): Plata = apuestas.map(_.gananciaPorResultado(resultado)).sum
	}