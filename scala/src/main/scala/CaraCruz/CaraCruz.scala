import Apuestas.Jugada
import CriterioJugada.CriterioIgualdad
import Juegos.Juego
import Utils.Resultado
import scala.util.Random

package object CaraCruz {
	case object CARA extends Resultado
	case object CRUZ extends Resultado

	case class CaraCruz() extends Juego{
		val resultadosPosibles = List(CARA, CRUZ)

		override def jugadasPosibles: List[Jugada] = resultadosPosibles.map(r=>Jugada(1, CriterioIgualdad(r)))
		override def resultado: Resultado = Random.shuffle(resultadosPosibles).head
	}
}
