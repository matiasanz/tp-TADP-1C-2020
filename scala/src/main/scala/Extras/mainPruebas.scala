package Extras
import Dominio._
import Juegos._

object Stringer{
	var id = 0
	def generateID = {
		id = id+1
		id
	}

	def arbolToString(arbolEscenarios: ArbolEscenarios, padre: Int = 0): String ={

		import arbolEscenarios._
		val exito = situacion.isSuccess

		val id = generateID

		String.join(
			"\n >>"
			, "\n*******"+id+"*********"
			, "hijo de "+ (if(padre==0) "nadie" else padre.toString)
			,	"ok?: "+ exito.toString
			, "plata: "+ (if(exito) situacion.get.saldo.toString else "0")
			, "proba: "+probabilidad.toString
			, "punto muerto: " + esPuntoMuerto.toString
			, "subarboles: "+subescenarios.map(arbolToString(_, id)).toString
		)

	}
}

trait Otro

case class Algo[T](x: T) extends Otro

object X{
	val apM = ApuestaSimple(JugadaMoneda(CARA), 300).compuestaCon(ApuestaSimple(JugadaMoneda(CRUZ), 300))
	val apR = ApuestaSimple(AColor(ROJO), 900).compuestaCon(ApuestaSimple(ANumero(25), 70)).compuestaCon(ApuestaSimple(AParidad(true), 2))


	def imprimir(x: Otro) = println(x.getClass.toString)

	def main(args: Array[String]): Unit = {
		val c: Otro = Algo(3)

		imprimir(c)

		val comb1 = List((MonedaComun, apM))
		val comb2 = List((Ruleta, apR))



		print(Cauto.elegirEntre(Jugador(70000), List(comb1, comb2)).toString)
//		val combinacion = List((MonedaComun, apM), (Ruleta, apR))

//		val x = Simuladores.simularJuegos(Jugador(5000), combinacion)

//		println(Stringer.arbolToString(x))
	}
}
