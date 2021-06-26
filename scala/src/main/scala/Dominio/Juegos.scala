package Dominio

import Distribuciones.{Distribucion, Probabilidad}
import Utils.pesoTotal
import Tipos.Plata

	trait AnyJuego

	abstract class Juego[R](distribucion: Distribucion[R]) extends AnyJuego {
		require(pesoTotal(distribucion)-1 <= 0.00001)

		def probabilidadDe(suceso: R): Probabilidad = resultadosPosibles.getOrElse(suceso, 0)
		def resultadosPosibles: Distribucion[R] = distribucion.filter(_._2>0)

		def distribucionDeGananciasPor(apuesta: Apuesta[R]): Distribucion[Plata] = {
			resultadosPosibles.groupMapReduce
				{case(rdo, _)=>apuesta.gananciaPorResultado(rdo)}
				{case(_, proba)=>proba} (_+_)
		}
	}

	trait Jugada[R] {
		def montoPorResultado(inversion: Plata, resultado: R): Plata = if(cumple(resultado)) montoPorGanar(inversion) else 0
		def montoPorGanar(inversion: Plata): Plata = ganancia*inversion

		def cumple(resultado: R): Boolean
		def ganancia: Double
	}

	trait AnyApuesta

	trait Apuesta[R] extends AnyApuesta{
		def montoRequerido: Plata
		def compuestaCon(apuesta: Apuesta[R]): ApuestaCompuesta[R]
		def gananciaPorResultado(resultado: R): Plata
	}

	case class ApuestaSimple[R](jugada: Jugada[R], montoRequerido: Plata)
		extends Apuesta[R] {
		override def gananciaPorResultado(resultado:  R): Plata = jugada.montoPorResultado(montoRequerido, resultado)
		override def compuestaCon(apuesta: Apuesta[R]): ApuestaCompuesta[R] = ApuestaCompuesta(this::List(apuesta))
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