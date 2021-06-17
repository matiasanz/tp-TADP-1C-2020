import Apuestas.Apuesta
import org.scalatest.freespec.AnyFreeSpec
import org.scalatest.matchers.should.Matchers._
import CaraCruz._

class ApuestaSpec extends AnyFreeSpec{

  "TP" - {

    "Apuestas" - {
      "esto deberia andar" in {
        Apuesta(200).conJugada(Cara).cumple(CARA) should be(true)
      }
    }
  }

}
