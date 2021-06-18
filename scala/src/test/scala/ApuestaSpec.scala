import org.scalatest.freespec.AnyFreeSpec
import org.scalatest.matchers.should.Matchers._
import CaraCruz._
import Criterios._

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

      "Ruleta" - {
          "Columna se calcula correctamente" in {
              columna(1) should be (1)
              columna(14) should be(2)
              columna(20) should be(2)
              columna(36) should be(3)
          }

          "Color es correcto" in {
              color(14) should be(ROJO)
              color(17) should be(NEGRO)
              color(20) should be(NEGRO)
              color(10) should be(NEGRO)
          }

          "docena" in {
              docena(12) should be(1)
              docena(13) should be(2)
              docena(24) should be(2)
          }
      }
  }

}
