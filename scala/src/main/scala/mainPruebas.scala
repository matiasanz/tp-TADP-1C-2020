
import Alt.SimuladorAlternativo
import Alt.Cauto.Combinacion
import Dominio.Distribuciones.Distribucion
import Dominio.Tipos.Plata
import Dominio.Utils.pesoTotal
import Dominio._
import Juegos._
import Juegos.TiposRuleta.ResultadoRuleta

object Stringer{
	var id = 0
	def generateID = {
		id = id+1
		id
	}

	def arbolToString(arbolEscenarios: ArbolEscenarios, padre: Int = 0): String ={

		import arbolEscenarios._
		//val exito = situacion.isSuccess

		val id = generateID

		String.join(
			"\n >>"
			, "\n*******"+id+"*********"
			, "hijo de "+ (if(padre==0) "nadie" else padre.toString)
			, "plata: "+ situacion.saldo.toString
			, "proba: "+probabilidad.toString
			, "subarboles: "+subescenarios.map(arbolToString(_, id)).toString
		)

	}
}

object X{
	val apM = ApuestaSimple(JugadaMoneda(CARA), 300).compuestaCon(ApuestaSimple(JugadaMoneda(CRUZ), 300))
	val apR = ApuestaSimple(AColor(ROJO), 900).compuestaCon(ApuestaSimple(ANumero(25), 70)).compuestaCon(ApuestaSimple(AParidad(true), 2))


	def main(args: Array[String]): Unit = {


		val comb1 = List((MonedaComun, apM))
		val comb2 = List((Ruleta, apR))


		val sdaf: Distribucion[Plata] = SimuladorAlternativo.simularJuegos(500, List(
			Simulacion(MonedaComun, ApuestaSimple(JugadaMoneda(CARA), 300))
			, Simulacion(MonedaComun, ApuestaSimple(JugadaMoneda(CARA), 300))
			, Simulacion(MonedaComun, ApuestaSimple(JugadaMoneda(CRUZ), 300))
			, Simulacion(MonedaComun, ApuestaSimple(JugadaMoneda(CRUZ), 300))
		))

		println(sdaf.toString)

//		print(Cauto.elegirEntre(Jugador(70000), List(comb1, comb2)).toString)
//		val combinacion = List((MonedaComun, apM), (Ruleta, apR))

//		val x = Simuladores.simularJuegos(Jugador(5000), combinacion)

//		println(Stringer.arbolToString(x))
	}
}
