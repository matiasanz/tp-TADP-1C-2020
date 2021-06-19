import Apuestas._
import CriterioJugada.CriterioIgualdad
import Juegos.Juego
import Utils.Resultado
import scala.util.Random

package object JuegosParticulares {
	case object CARA extends Resultado
	case object CRUZ extends Resultado

	case object JugarACara extends JugadaTodoONada(1, CriterioIgualdad(CARA))
	case object JugarACruz extends JugadaTodoONada(1, CriterioIgualdad(CRUZ))

	case class CaraCruz() extends Juego{
		val resultadosPosibles = List(CARA, CRUZ)
		override def resultado: Resultado = Random.shuffle(resultadosPosibles).head
	}
}
