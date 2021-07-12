package Dominio

import Distribuciones.Probabilidad
import Tipos.Plata

	abstract class Juego[R](val resultadosPosibles: Distribucion[R]) {
		def distribucionDeGananciasPor(apuesta: Apuesta[R]): Distribucion[Plata]
			= resultadosPosibles.mapSucesos(rdo => apuesta(rdo))
	}

	trait Jugada[R] {
		def apply(inversion: Plata, resultado: R): Plata = if(satisfechaPor(resultado)) montoPorGanar(inversion) else montoPorPerder(inversion)
		def montoPorGanar(inversion: Plata): Plata = ratioGanancia*inversion
		def montoPorPerder(inversion: Plata) = 0

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
		type Plata = Double
	}

//******************************* Esto no se usa *******************************************
case class Jugador(saldo: Plata, criterio: CriterioJuego) {
	require(saldo >= 0)

	def acreditar(monto: Plata): Jugador = copy(saldo + monto)

	def desacreditar(monto: Plata): Jugador = {
		validarExtraccion(monto)
		copy(saldoPorDesacreditar(monto))
	}

	def elegirCombinacion(combinaciones: List[Simulacion]): Option[Simulacion]
		= criterio.elegirEntre(saldo, combinaciones)

	def validarExtraccion(monto: Plata): Unit = {
		if(saldoPorDesacreditar(monto)<0)
			throw SaldoInsuficienteException(this, monto)
	}

	val saldoPorDesacreditar: Plata => Plata = monto => saldo-monto

	def jugarApuesta[R](apostar: Apuesta[R], resultado: R): Jugador = {
		desacreditar(apostar.montoRequerido).acreditar(apostar(resultado))
	}
}
