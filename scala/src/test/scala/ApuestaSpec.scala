import Dominio.Distribuciones
import org.scalatest.freespec.AnyFreeSpec
import org.scalatest.matchers.should.Matchers._
import Juegos._
import Dominio._


class ApuestaSpec extends AnyFreeSpec{

  val jugada = JugadaMoneda(CARA)

  val apuesta = Apuesta(jugada, 200)

  "TP" - {
    "Apuestas" - {
      "El resultado esperado cumple la apuesta" in {
        CorredorMoneda.evaluarApuesta(apuesta, CARA) should be(true)
      }

      "Si se cumple la apuesta, se multiplica el monto" - {
        jugada.montoPorGanar(200.00) should be(400)
      }
    }

    "Ruleta" - {
      import Juegos.Tablero._
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

    "distribuciones" - {
      "equiprobable" in {
        val equiprobable = Distribuciones.equiprobable(List(CARA, CRUZ))
        equiprobable.probabilidadDe(CARA) should be(0.5)
        equiprobable.probabilidadDe(CRUZ) should be(0.5)
      }

      "evento unico" in{
        val eventoUnico = Distribuciones.eventoSeguro[ResultadoMoneda](CARA)
        eventoUnico.probabilidadDe(CARA) should be(1)
        eventoUnico.probabilidadDe(CRUZ) should be(0)
      }

      "Ponderada" in {
        val sucesos: Map[ResultadoMoneda, Int] = Map((CARA, 7500), (CRUZ, 2500))
        val ponderada = Distribuciones.ponderada(sucesos)

        ponderada.probabilidadDe(CARA) should be(0.75)
        ponderada.probabilidadDe(CRUZ) should be(0.25)
      }
    }
  }

}