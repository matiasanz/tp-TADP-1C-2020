import Juego._

package object Criterios {
  type CriterioJugada = Resultado => Boolean

  case object CriterioIgualdad extends (Resultado => CriterioJugada) {
    override def apply(esperado: Resultado): CriterioJugada = (resultado => resultado == esperado)
  }
}