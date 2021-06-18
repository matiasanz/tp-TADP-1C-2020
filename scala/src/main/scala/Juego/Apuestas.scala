import CriterioJugada.CriterioJugada
import Utils._

package object Apuestas {
    case class Jugada(val ganancia: Double, val cumpleCriterio: CriterioJugada){
        def crearApuesta(monto: Plata) = Apuesta(monto, List(this))

        def montoPorResultado(montoInicial: Plata, resultado: Resultado): Plata =
            if (cumpleCriterio(resultado)) (1+ganancia) * montoInicial else 0
    }

    case class Apuesta(montoActual: Plata, jugadas: List[Jugada] = List.empty) {

        def conJugada(jugada: Jugada) = copy(jugadas = jugadas :+ jugada)

        def evaluarResultado(resultado: Resultado): Apuesta = {
          copy(montoPorResultado(resultado), jugadas.tail)
        }

        def montoPorResultado(resultado: Resultado) = {
            if(jugadas.isEmpty) montoActual
            else jugadas.head.montoPorResultado(montoActual, resultado)
        }

        def ganancia: Double = if(jugadas.isEmpty) 0 else jugadas.head.ganancia

        def cumpleCriterio(resultado: Resultado): Boolean = jugadas.head.cumpleCriterio(resultado)
    }

}
