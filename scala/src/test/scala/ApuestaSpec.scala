import Apuestas.Apuesta
import org.scalatest.freespec.AnyFreeSpec
import org.scalatest.matchers.should.Matchers._
import CaraCruz._

class ApuestaSpec extends AnyFreeSpec{

  val apuesta = Apuesta(200).conJugada(JugadaCara)

  "TP" - {

    "Apuestas" - {
      "El resultado esperado cumple la apuesta" in {
        apuesta.cumple(CARA) should be(true)
      }

      "Si se cumple la apuesta, se multiplica el monto" - {
        apuesta.evaluarResultado(CARA).montoActual should be(400)
      }
    }
  }

}
