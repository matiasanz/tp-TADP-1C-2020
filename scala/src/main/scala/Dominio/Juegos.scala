package Dominio

import Distribuciones.Probabilidad
import Tipos.Plata

	abstract class Juego[R](distribucion: Distribucion[R]) {

		def resultadosPosibles = distribucion

		def distribucionDeGananciasPor(apuesta: Apuesta[R]): Distribucion[Plata]
			= distribucion.mapSucesos(rdo => apuesta(rdo))
	}

	trait Jugada[R] {
		def apply(inversion: Plata, resultado: R): Plata = if(satisfechaPor(resultado)) montoPorGanar(inversion) else montoPorPerder
		def montoPorGanar(inversion: Plata): Plata = ratioGanancia*inversion
		def montoPorPerder = 0

		def satisfechaPor: R => Boolean
		def ratioGanancia: Double
	}

	trait Apuesta[R] {
		def montoRequerido: Plata
		def compuestaCon(apuesta: Apuesta[R]): ApuestaCompuesta[R]
		def apply(resultado: R): Plata
	}

	case class ApuestaSimple[R](jugar: Jugada[R], montoRequerido: Plata) extends Apuesta[R] {
		override def apply(resultado:  R): Plata = jugar(montoRequerido, resultado)
		override def compuestaCon(apuesta: Apuesta[R]): ApuestaCompuesta[R] = ApuestaCompuesta(this::List(apuesta))
	}

	case class ApuestaCompuesta[R](apuestas: List[Apuesta[R]]) extends Apuesta[R]{
		override def apply(resultado: R): Plata = apuestas.map(_(resultado)).sum
		override def compuestaCon(apuesta: Apuesta[R]): ApuestaCompuesta[R] = copy(apuestas:+apuesta)
		override def montoRequerido: Plata = apuestas.map(_.montoRequerido).sum
	}

	object Tipos{
		type Plata = BigDecimal
	}