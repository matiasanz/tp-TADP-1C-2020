
import Dominio._
import Juegos._

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

		println(sdaf.mapSucesos(_.map(_.getClass.toString).mkString("<--")).sucesos.mkString("\n"))

	}
}
