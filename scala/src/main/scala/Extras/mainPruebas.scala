package Extras

import Dominio.{ApuestaSimple, ArbolEscenarios, Jugador, Simulador}
import Juegos._

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

			val id = Auxiliar.generateID

			String.join(
				"\n >>"
				, "\n*******"+id+"*********"
				,	"ok?: "+ exito.toString
				, if(exito) "plata: "+situacion.get.saldo.toString else "Ni idea"
				, "proba: "+probabilidad.toString
				, "punto muerto: " + esPuntoMuerto.toString
				, "subarboles: "+subescenarios.map(hijoToString(_, id)).toString
			)
		}
	}

	def hijoToString(arbol: ArbolEscenarios, padre: Int): String = "\n\n-------------------\nEl que viene es hijo de " + padre.toString + "\n    " + arbolToString(arbol)
}

object X{
	def main(args: Array[String]): Unit = {

		val apM = ApuestaSimple(JugadaMoneda(CARA), 20).compuestaCon(ApuestaSimple(JugadaMoneda(CRUZ), 10))
		val apR = ApuestaSimple(AColor(ROJO), 900).compuestaCon(ApuestaSimple(ANumero(25), 70)).compuestaCon(ApuestaSimple(AParidad(true), 2))

		val arbolEscenarios = Simulador.simularJuegos(Jugador(90), List(
			(MonedaComun, apM)
			, (MonedaComun, apM)
			, (MonedaComun, apM)
			, (MonedaComun, apM)
			, (MonedaComun, apM)
			, (MonedaComun, apM)
			, (MonedaComun, apM)
			, (MonedaComun, apM)
			, (MonedaComun, apM)
			, (MonedaComun, apM)
			, (MonedaCargada(CARA), apM)
			, (MonedaCargada(CRUZ), apM)
			/*				 (Ruleta, apR)
							, (Ruleta, apR)
							, (Ruleta, apR)
							, (Ruleta, apR)*/

		))

		println(Stringer.arbolToString(arbolEscenarios))

		print("**************************************************************************\n")

//		println(arbolEscenarios.asList.filter(_.situacion.isFailure).toString)


		//		println(Map(("h1", 1), ("h2", 2), ("c1", 3), ("c2", 5)).groupBy(_._1.indexOf("h")==0).map( x => (x._1, x._2.values.sum) ).toString)
	}
}
