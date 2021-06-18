import CriterioJugada.CriterioJugada
import Utils._

package object Apuestas {

    trait Jugada extends (Plata => Apuesta) with ((Plata, Resultado)=>Plata){
        override def apply(montoInicial: Plata): Apuesta = Apuesta(montoInicial, this)
    }

    class JugadaTodoONada(val ganancia: Double, val criterio: CriterioJugada) extends Jugada {
        override def apply(montoInicial: Plata, resultado: Resultado): Plata = {
            if (criterio(resultado)) (1 + ganancia) * montoInicial else 0
        }

        /*TODO: Duda - Para que realmente sea aplicacion parcial, entiendo que deberia llamar
         * a la otra implementacion. El problema es que para eso, la apuesta necesitaria conocer
		 * todo esto y me es raro.
		 */
    }

    case class Apuesta(montoInicial: Plata, montoPorResultado: Jugada) extends (Resultado=>Plata){
        override def apply(resultado: Resultado) = montoPorResultado(montoInicial, resultado)
        def compuestaCon(jugada: Jugada) = ApuestaCompuesta(montoInicial, montoPorResultado::List(jugada))
    }

    case class ApuestaCompuesta(montoActual: Plata, jugadas: List[Jugada]){

        def evaluarResultado(resultado: Resultado): ApuestaCompuesta = jugadas match {
            case Nil => copy()
            case jugada::jugadas => copy(montoActual=jugada(montoActual)(resultado), jugadas = jugadas)
        }

        def compuestaCon(jugada: Jugada) = copy(jugadas=jugadas:+jugada)

        def finalizada = jugadas.isEmpty
    }
}