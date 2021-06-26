package Dominio

import Distribuciones.{Distribucion, Probabilidad}
import Utils.pesoTotal
import Tipos.Plata

	trait AnyJuego

	abstract class Juego[R](distribucion: Distribucion[R]) extends AnyJuego {
		require(pesoTotal(distribucion)-1 <= 0.00001)

		def probabilidadDe(suceso: R): Probabilidad = distribucion.getOrElse(suceso, 0)
		def sucesosPosibles: Map[R, Probabilidad] = distribucion.filter(_._2>0)
	}

	trait Jugada[R]{
		def montoPorGanar(inversion: Plata): Plata = ganancia*inversion
		def ganancia: Double
		def cumple(resultado: R): Boolean
	}

	trait AnyApuesta

	trait Apuesta[R] extends AnyApuesta{
		def montoRequerido: Plata
		def compuestaCon(apuesta: Apuesta[R]): ApuestaCompuesta[R]
		def gananciaPorResultado(resultado: R): Plata
	}

	case class ApuestaSimple[R](jugada: Jugada[R], montoRequerido: Plata)
		extends Apuesta[R] {
		override def compuestaCon(apuesta: Apuesta[R]): ApuestaCompuesta[R] = ApuestaCompuesta(this::List(apuesta))
		override def gananciaPorResultado(resultado: R): Plata = if(jugada.cumple(resultado)) jugada.montoPorGanar(montoRequerido) else 0
	}

	case class ApuestaCompuesta[R](apuestas: List[Apuesta[R]]) extends Apuesta[R]{
		override def montoRequerido: Plata = apuestas.map(_.montoRequerido).sum
		override def compuestaCon(apuesta: Apuesta[R]): ApuestaCompuesta[R] = copy(apuestas:+apuesta)
		override def gananciaPorResultado(resultado: R): Plata = apuestas.map(_.gananciaPorResultado(resultado)).sum
	}

	case class Jugador(saldo: Plata) {
		require(saldo >= 0)

		def acreditar(monto: Plata): Jugador = copy(saldo + monto)

		def desacreditar(monto: Plata): Jugador = {
			validarExtraccion(monto)
			copy(saldoPorDesacreditar(monto))
		}

		def validarExtraccion(monto: Plata): Unit = {
			if(saldoPorDesacreditar(monto)<0)
				throw SaldoInsuficienteException(this, monto)
		}

		val saldoPorDesacreditar: Plata => Plata = monto => saldo-monto

		def jugarApuesta[R](apuesta: Apuesta[R], resultado: R): Jugador = {
			desacreditar(apuesta.montoRequerido).acreditar(apuesta.gananciaPorResultado(resultado))
			//TODO: Esto capaz convenga hacerlo desde el lado de la apuesta
		}
	}