import Utils._

package object CriterioJugada {
  type CriterioJugada = Resultado => Boolean

    case object CriterioIgualdad extends (Resultado => CriterioJugada) {
        override def apply(esperado: Resultado): CriterioJugada = (resultado => resultado == esperado)
    }
}