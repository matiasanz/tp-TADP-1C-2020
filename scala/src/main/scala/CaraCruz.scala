import Juego._
import Apuestas._
import Criterios._

package object CaraCruz {

    case object CARA extends Resultado
    case object CRUZ extends Resultado

    val Cara: Jugada = Jugada(2, CriterioIgualdad(CARA))
    val Cruz: Jugada = Jugada(2, CriterioIgualdad(CRUZ))

    case class CaraCruz() extends Juego(List(Cara, Cruz))
}
