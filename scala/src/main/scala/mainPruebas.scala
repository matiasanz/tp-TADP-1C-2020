
import Dominio.Tipos.Plata
import Dominio.Utils.pesoTotal
import Dominio._
import Juegos._
import Juegos.TiposRuleta.ResultadoRuleta

object X{
	val apM = ApuestaSimple(JugadaMoneda(CARA), 300).compuestaCon(ApuestaSimple(JugadaMoneda(CRUZ), 300))
	val apR = ApuestaSimple(AColor(ROJO), 900).compuestaCon(ApuestaSimple(ANumero(25), 70)).compuestaCon(ApuestaSimple(AParidad(true), 2))


	def main(args: Array[String]): Unit = {


		val comb1 = List((MonedaComun, apM))
		val comb2 = List((Ruleta, apR))


		val sdaf: Distribucion[Marcador] = SimulacionCompuesta(List(
			SimulacionSimple(MonedaComun, ApuestaSimple(JugadaMoneda(CARA), 300))
			, SimulacionSimple(MonedaComun, ApuestaSimple(JugadaMoneda(CARA), 300))
			, SimulacionSimple(MonedaComun, ApuestaSimple(JugadaMoneda(CRUZ), 300))
			, SimulacionSimple(MonedaComun, ApuestaSimple(JugadaMoneda(CRUZ), 300))
		)).simular(500)

		println(sdaf.toString)

//		print(Cauto.elegirEntre(Jugador(70000), List(comb1, comb2)).toString)
//		val combinacion = List((MonedaComun, apM), (Ruleta, apR))

//		val x = Simuladores.simularJuegos(Jugador(5000), combinacion)

//		println(Stringer.arbolToString(x))
	}
}
