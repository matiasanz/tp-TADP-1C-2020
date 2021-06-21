package Dominio

	import Tipos.Plata

	trait Corredor

	class Jugada(ganancia: Double){
		def montoPorGanar(inversion: Plata): Plata = ganancia*inversion
	}

	case class Apuesta[J](val jugada: J, val montoRequerido: Plata){
		val alcanza: Plata=>Boolean = presupuesto => presupuesto>=montoRequerido
	}

	class Juego[R](val corredor: Corredor){
		val distribucion: Distribucion[R] = ???
	}
