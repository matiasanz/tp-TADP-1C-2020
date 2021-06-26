
import Dominio.Cauto.Combinacion
import Dominio.Distribuciones.Distribucion
import Dominio.Tipos.Plata
import Dominio._
import Juegos._
import Juegos.TiposRuleta.ResultadoRuleta

case class coso() {

	def monto[R](plata: Plata, apuesta: Apuesta[R], ganancia: Plata) = {
		if (plata >= apuesta.montoRequerido) plata - apuesta.montoRequerido + ganancia
		else plata
	}

	def simularJuego[R](distribucion: Distribucion[Plata], juego: Juego[R], apuesta: Apuesta[R]) ={
		val w = for {
			(plata, probaLlegada) <- distribucion
			(ganancia, probaTransicion) <- juego.distribucionDeGananciasPor(apuesta)
		} yield (monto(plata, apuesta, ganancia) -> probaLlegada * probaTransicion) //TODO La proba tambien depende de si se hizo la apuesta o no... aunque se va a agrupar

		w.groupMapReduce(_._1)(_._2)(_+_)
	}

	def simularJuegosDivertido(jugador: Jugador, juegos: List[(AnyJuego, AnyApuesta)])
		= juegos.foldLeft(Map((jugador.saldo, 1.0))) {
		case (distribucion, (juego: Juego[ResultadoMoneda], apuesta: Apuesta[ResultadoMoneda])) =>
			simularJuego(distribucion, juego, apuesta)
		case (distribucion, (juego: Juego[ResultadoRuleta], apuesta: Apuesta[ResultadoRuleta])) =>
			simularJuego(distribucion, juego, apuesta)
	}
}



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
		//	,	"ok?: "+ exito.toString
			, "plata: "+ situacion.saldo.toString
			, "proba: "+probabilidad.toString
//			, "punto muerto: " + esPuntoMuerto.toString
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


		val sdaf = coso().simularJuegosDivertido(Jugador(500), List((MonedaComun, ApuestaSimple(JugadaMoneda(CARA), 300)), (MonedaComun, ApuestaSimple(JugadaMoneda(CARA), 300))))
		println(sdaf.toString)

//		print(Cauto.elegirEntre(Jugador(70000), List(comb1, comb2)).toString)
//		val combinacion = List((MonedaComun, apM), (Ruleta, apR))

//		val x = Simuladores.simularJuegos(Jugador(5000), combinacion)

//		println(Stringer.arbolToString(x))
	}
}
