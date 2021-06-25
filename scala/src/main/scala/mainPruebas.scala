import Dominio.{ApuestaSimple, ArbolEscenarios, Jugador, Simuladores}
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
				, "plata: "+ (if(exito) situacion.get.saldo.toString else "0")
				, "proba: "+probabilidad.toString
				, "punto muerto: " + esPuntoMuerto.toString
				, "subarboles: "+subescenarios.map(hijoToString(_, id)).toString
			)
		}
	}

	def hijoToString(arbol: ArbolEscenarios, padre: Int): String = "\n\n-------------------\nEl que viene es hijo de " + padre.toString + "\n    " + arbolToString(arbol)
}

object X{
	val apM = ApuestaSimple(JugadaMoneda(CARA), 300).compuestaCon(ApuestaSimple(JugadaMoneda(CRUZ), 300))
	val apR = ApuestaSimple(AColor(ROJO), 900).compuestaCon(ApuestaSimple(ANumero(25), 70)).compuestaCon(ApuestaSimple(AParidad(true), 2))

	/*
	def listaJuegos: (Int, Int, Int)=> List[(Juego[_], Apuesta[_])] = (monedasSinCarga, monedasConCargaCara, monedasConCargaCruz) => {
		List(1 to monedasSinCarga).map(_ => (MonedaComun, apM))
			.concat((List(1 to monedasConCargaCara).map(_ => MonedaCargada(CARA)))
				.concat((List(1 to monedasConCargaCruz).map(_ => (MonedaCargada(CRUZ), apM)))))
	}
*/
	def main(args: Array[String]): Unit = {


		val combinacion1 = List(
			(MonedaComun, apM)
/*			, (MonedaComun, apM)
			, (MonedaComun, apM)
			, (MonedaComun, apM)
			, (MonedaComun, apM)
			, (MonedaComun, apM)
			, (MonedaComun, apM)
			, (MonedaComun, apM)
			, (MonedaComun, apM)
			, (MonedaComun, apM)*/
//			, (MonedaCargada(CARA), apM)
//			, (MonedaCargada(CRUZ), apM)
		/*				 (Ruleta, apR)
						, (Ruleta, apR)
						, (Ruleta, apR)
						, (Ruleta, apR)*/
		)

		val arbolEscenarios = Simuladores.simularJuegos(Jugador(15), combinacion1)

		println(Stringer.arbolToString(arbolEscenarios))

		print("**************************************************************************\n")

//		println(Cauto.analizarCombinaciones(Jugador(90), List(combinacion1, listaJuegos(2, 2, 3))))
//		println(arbolEscenarios.asList.filter(_.situacion.isFailure).toString)


		//		println(Map(("h1", 1), ("h2", 2), ("c1", 3), ("c2", 5)).groupBy(_._1.indexOf("h")==0).map( x => (x._1, x._2.values.sum) ).toString)
	}
}
