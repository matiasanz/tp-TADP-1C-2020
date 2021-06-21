package Dominio

	import Tipos.Plata

	trait Corredor

	trait Jugada{
		def montoPorGanar(inversion: Plata): Plata = ganancia*inversion
		def ganancia: Double
	}

	case class Apuesta[J](val jugada: J, val montoRequerido: Plata){
		val alcanza: Plata=>Boolean = presupuesto => presupuesto>=montoRequerido
	}

	abstract class Juego[R](val corredor: Corredor){
		def distribucion: Distribucion[R]
	}
