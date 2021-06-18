import Apuestas.{Apuesta, Jugada}
import org.scalatest.freespec.AnyFreeSpec
import org.scalatest.matchers.should.Matchers._
import CaraCruz._
import Criterios.CriterioIgualdad

class ApuestaSpec extends AnyFreeSpec{

  val jugada = Jugada(1, CriterioIgualdad(CARA))
  val apuesta = Apuesta(200).conJugada(jugada)

  "TP" - {

    "Apuestas" - {
      "El resultado esperado cumple la apuesta" in {
        apuesta.cumpleCriterio(CARA) should be(true)
      }

      "Si se cumple la apuesta, se multiplica el monto" - {
        apuesta.evaluarResultado(CARA).montoActual should be(400)
      }
    }
  }

}
