import Criterios.CriterioJugada
import Utils._

package object Apuestas {
    class Juego(jugadasPosibles: List[Jugada]) {
        def resultado: Resultado = ???
    }

    class Jugada(val ganancia: Double, val cumple: CriterioJugada)

    case class Apuesta(montoActual: Plata, jugadas: List[Jugada] = List.empty) {

        def conJugada(jugada: Jugada) = copy(jugadas = jugadas:+jugada)

        def evaluarResultado(resultado: Resultado): Apuesta = copy(
            montoActual = montoPorResultado(resultado),
            jugadas = jugadas.tail
        )

        def montoPorResultado(resultado: Resultado): Plata =
            if (cumple(resultado)) (1+ganancia) * montoActual else 0

        def ganancia: Double = if(jugadas.isEmpty) 0 else jugadas.head.ganancia

        def cumple(resultado: Resultado): Boolean = jugadas.head.cumple(resultado)
    }

}
