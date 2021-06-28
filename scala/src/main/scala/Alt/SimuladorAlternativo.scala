package Alt

import Dominio.Distribuciones.Probabilidad
import Dominio.Tipos.Plata
import Dominio._
import Juegos.ResultadoMoneda
import Juegos.TiposRuleta.ResultadoRuleta

/*
object SimuladorAlternativo {

	def simularJuegos(presupuesto: Plata, juegos: List[Simulacion[_]]): Distribucion[Plata]
	= juegos.foldLeft(Distribuciones.eventoSeguro(presupuesto)) {
		case(distribucion, simulacion)=>simularJuego(distribucion, simulacion)
	}

	def simularJuego[R](distribucion: Distribucion[Plata], simulacion: Simulacion[R]): Distribucion[Plata] ={
		import simulacion._
		val escenarios = for {
			(saldoInicial, probaLlegada) <- distribucion.toList
			(ganancia, probaTransicion) <- juego.distribucionDeGananciasPor(apuesta).toList
		} yield (this.monto(saldoInicial, apuesta.montoRequerido, ganancia), probaLlegada*probaTransicion)

		Distribuciones.agrupar(escenarios)
	}

	def monto(saldoInicial: Plata, costo: Plata, ganancia: Plata) = {
		val saldo = saldoInicial - costo

		if(saldo>=0) saldo+ganancia //Continuo
		else 		 saldoInicial	//Salteo
	}

}*/