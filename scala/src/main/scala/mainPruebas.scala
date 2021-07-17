
import Dominio._
import Juegos._

//TODO: Se queja de que ACara no es jugada, pero esta mixeado con el trait JugadaCriterio
// , que extiende de Jugada
object Pruebas{

	val apM = ApuestaSimple(ACara(CARA), 300)
		.compuestaCon(ApuestaSimple(ACara(CRUZ), 300))
	val apR = ApuestaSimple(AColor(ROJO), 900).compuestaCon(ApuestaSimple(ANumero(25), 70)).compuestaCon(ApuestaSimple(AParidad(true), 2))


	def main(args: Array[String]): Unit = {

		val sdaf: Distribucion[List[Marcador]] = SimulacionCompuesta(
			List(
				SimulacionSimple(MonedaComun, ApuestaSimple(ACara(CARA), 300))
				, SimulacionSimple(MonedaComun, ApuestaSimple(ACara(CARA), 300))
				, SimulacionSimple(MonedaComun, ApuestaSimple(ACara(CRUZ), 300))
				, SimulacionSimple(MonedaComun, ApuestaSimple(ACara(CRUZ), 300))
			)
		).simular(500.0)

		println(sdaf.mapSucesos(_.map(_.getClass.toString).mkString("-->")).getSucesos.mkString("\n"))

	}
}
