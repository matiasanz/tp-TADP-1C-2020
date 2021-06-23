package Dominio

	import Distribuciones.Distribucion
	import Utils.pesoTotal
	import Tipos.Plata

	abstract class Juego[R](distribucion: Distribucion[R]){
		require(pesoTotal(distribucion)-1 <= 0.00001)

		def probabilidadDe(suceso: R): Float = distribucion.getOrElse(suceso, 0)
		def sucesosPosibles: Map[R, Float] = distribucion.filter(_._2>0)
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

	case class ApuestaSimple[R](jugada: Jugada[R], montoRequerido: Plata)
		extends Apuesta[R] {
		override def compuestaCon(apuesta: Apuesta[R]) = ApuestaCompuesta(this::List(apuesta))
		override def gananciaPorResultado(resultado: R): Plata = if(jugada.cumple(resultado)) jugada.montoPorGanar(montoRequerido) else 0
	}

	case class ApuestaCompuesta[R](apuestas: List[Apuesta[R]]) extends Apuesta[R]{
		override def montoRequerido: Plata = apuestas.map(_.montoRequerido).sum
		override def compuestaCon(apuesta: Apuesta[R]) = copy(apuestas:+apuesta)
		override def gananciaPorResultado(resultado: R): Plata = apuestas.map(_.gananciaPorResultado(resultado)).sum
	}