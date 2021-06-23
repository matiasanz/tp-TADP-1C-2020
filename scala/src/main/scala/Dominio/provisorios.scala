package Dominio

import Juegos.{AColor, CARA, CRUZ, JugadaMoneda, MonedaComun, ROJO}

object Auxiliar{
	var id = 0
	def generateID = {
		id = id+1
		id
	}
}

object Stringer{
	def arbolToString(arbolEscenarios: ArbolEscenarios): String ={
		{
			import arbolEscenarios._
			val exito = situacion.isSuccess

			String.join(
				"\n >>"
				, "\n*******"+id+"*********"
				,	"ok?: "+ exito.toString
				, if(exito) "plata: "+situacion.get.saldo.toString else "Ni idea"
				, "proba: "+probabilidad.toString
				, "subarboles: "+subescenarios.map(_.toString(id)).toString
			)
		}
	}
}

object X{
	def main(args: Array[String]): Unit = {

		val apM = ApuestaSimple(JugadaMoneda(CARA), 20).compuestaCon(ApuestaSimple(JugadaMoneda(CRUZ), 10))
		val apR = ApuestaSimple(AColor(ROJO), 900)

		println(Stringer.arbolToString(

			Simulador.simularJuegos(Jugador(30), List(
				(MonedaComun, apM)
				, (MonedaComun, apM)
				, (MonedaComun, apM)
				, (MonedaComun, apM)
			//	, (Ruleta, apR)
			)
		)))

		//		println(Map(("h1", 1), ("h2", 2), ("c1", 3), ("c2", 5)).groupBy(_._1.indexOf("h")==0).map( x => (x._1, x._2.values.sum) ).toString)
	}
}
