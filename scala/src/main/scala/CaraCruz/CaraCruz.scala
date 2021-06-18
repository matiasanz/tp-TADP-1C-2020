import Apuestas.{Juego, Jugada}
import Criterios.CriterioIgualdad
import Utils.Resultado

package object CaraCruz {

	case object CARA extends Resultado
	case object CRUZ extends Resultado

	case object JugadaCara extends Jugada(1, CriterioIgualdad(CARA))
	case object JugadaCruz extends Jugada(1, CriterioIgualdad(CRUZ))

	case class CaraCruz() extends Juego(List(JugadaCara, JugadaCruz))
}
