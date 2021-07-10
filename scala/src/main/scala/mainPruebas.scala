
import Dominio.Tipos.Plata
import Dominio._
import Juegos._
import Juegos.Cuadricula.ResultadoRuleta

object X{
	val apM = ApuestaSimple(AMoneda(CARA), 300).compuestaCon(ApuestaSimple(AMoneda(CRUZ), 300))
	val apR = ApuestaSimple(AColor(ROJO), 900).compuestaCon(ApuestaSimple(ANumero(25), 70)).compuestaCon(ApuestaSimple(AParidad(true), 2))


	def main(args: Array[String]): Unit = {


		val comb1 = List((MonedaComun, apM))
		val comb2 = List((Ruleta, apR))


		val sdaf: Distribucion[List[Marcador]] = SimulacionCompuesta(List(
			SimulacionSimple(MonedaComun, ApuestaSimple(AMoneda(CARA), 300))
			, SimulacionSimple(MonedaComun, ApuestaSimple(AMoneda(CARA), 300))
			, SimulacionSimple(MonedaComun, ApuestaSimple(AMoneda(CRUZ), 300))
			, SimulacionSimple(MonedaComun, ApuestaSimple(AMoneda(CRUZ), 300))
		)).simular(500)

		println(sdaf.toString)

//		print(Cauto.elegirEntre(Jugador(70000), List(comb1, comb2)).toString)
//		val combinacion = List((MonedaComun, apM), (Ruleta, apR))

//		val x = Simuladores.simularJuegos(Jugador(5000), combinacion)

//		println(Stringer.arbolToString(x))
	}
}
