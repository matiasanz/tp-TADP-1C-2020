import Apuestas.{Apuesta, Jugada}
import org.scalatest.freespec.AnyFreeSpec
import org.scalatest.matchers.should.Matchers._
import CaraCruz._
import CriterioJugada.CriterioIgualdad

class ApuestaSpec extends AnyFreeSpec{

  val jugada = JugarACara
  val apuesta = jugada(200.00)

  "TP" - {

    "Apuestas" - {
      "El resultado esperado cumple la apuesta" in {
        jugada.cumpleCriterio(CARA) should be(true)
      }

      "Si se cumple la apuesta, se multiplica el monto" - {
        apuesta(CARA) should be(400)
      }
    }
  }

}
