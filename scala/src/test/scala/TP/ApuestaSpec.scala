package TP

import Dominio.{Distribuciones, _}
import Juegos._
import org.scalatest.freespec.AnyFreeSpec
import org.scalatest.matchers.should.Matchers._


class ApuestaSpec extends AnyFreeSpec{

  val jugada = ACara(CARA)

  val apuesta = ApuestaSimple(jugada, 200)

  "TP" - {
      "Apuestas" - {
          "El resultado esperado cumple la apuesta" in {
              jugada.satisfechaPor(CARA) shouldBe true
          }

          "Si se cumple la apuesta, se multiplica el monto" - {
              jugada.montoPorGanar(200.00) shouldBe 400
          }
      }

      "distribuciones" - {
          "equiprobable" in {
              val equiprobable = Distribuciones.equiprobable(List(CARA, CRUZ))
              equiprobable.probabilidadDe(CARA) shouldBe 0.5
              equiprobable.probabilidadDe(CRUZ) shouldBe 0.5
          }

          "evento unico" in{
              val eventoUnico = Distribuciones.eventoSeguro[CaraMoneda](CARA)
              eventoUnico.probabilidadDe(CARA) shouldBe 1
              eventoUnico.probabilidadDe(CRUZ) shouldBe 0
          }

          "Ponderada" in {
              val sucesos: Map[CaraMoneda, Double] = Map((CARA, 7500), (CRUZ, 2500))
              val ponderada = Distribuciones.ponderada(sucesos)

              ponderada.probabilidadDe(CARA) shouldBe 0.75
              ponderada.probabilidadDe(CRUZ) shouldBe 0.25
          }
        }
     }
}