import Juego._

package object Apuestas {
    class Juego(jugadasPosibles: List[Jugada]) {
        def resultado: Resultado = ???
    }

    case class Jugada(ganancia: Double, cumple: Resultado => Boolean) {
        def generarApuesta(montoInicial: Plata): Apuesta = Apuesta(montoInicial).conJugada(this)
    }


    case class Apuesta(montoActual: Plata, jugadas: List[Jugada] = List.empty) {

        def conJugada(jugada: Jugada) = copy(jugadas = jugada :: jugadas)

        def evaluarResultado(resultado: Resultado): Apuesta = copy(
            montoActual = montoPorResultado(resultado),
            jugadas = jugadas.tail
        )

        def montoPorResultado(resultado: Resultado): Plata =
            if (cumple(resultado)) (1+ganancia) * montoActual else 0

        def ganancia: Double = jugadas.head.ganancia

        def cumple(resultado: Resultado): Boolean = jugadas.head.cumple(resultado)
    }

}
