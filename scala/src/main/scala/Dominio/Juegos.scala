package Dominio

	import Tipos.Plata

	import scala.util.Try

	abstract class Juego[R](val corredor: Corredor){
		def distribucion: Distribucion[R]
	}

	trait Corredor

	trait Jugada{
		def montoPorGanar(inversion: Plata): Plata = ganancia*inversion
		def ganancia: Double
	}

	case class Apuesta[J](val jugada: J, val montoRequerido: Plata){
		def saldoPorApostar(saldoInicial: Plata) = saldoInicial-montoRequerido
	}
