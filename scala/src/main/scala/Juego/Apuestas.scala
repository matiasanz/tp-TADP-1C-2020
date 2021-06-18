import CriterioJugada.CriterioJugada
import Utils._

package object Apuestas {

    class Jugada(val ganancia: Double, val cumpleCriterio: CriterioJugada) extends (Plata => Apuesta){

        override def apply(montoInicial: Plata): Apuesta = Apuesta(r=>montoPorResultado(montoInicial, r))

        private def montoPorResultado(montoInicial: Plata, resultado: Resultado): Plata =
            if (cumpleCriterio(resultado)) (1 + ganancia) * montoInicial else 0
    }

    case class Apuesta(montoPorResultado: Resultado=>Plata) extends (Resultado=>Plata){
        override def apply(resultado: Resultado) = montoPorResultado(resultado)
    }

}
