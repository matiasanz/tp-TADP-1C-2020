package TP

import Dominio.{Distribuciones, _}
import Juegos._
import org.scalatest.freespec.AnyFreeSpec
import org.scalatest.matchers.should.Matchers._


class ApuestaSpec extends AnyFreeSpec{

  val jugada = JugadaMoneda(CARA)

  val apuesta = ApuestaSimple(jugada, 200)

  "TP" - {
      "Apuestas" - {
          "El resultado esperado cumple la apuesta" in {
              jugada.cumple(CARA) should be(true)
          }

          "Si se cumple la apuesta, se multiplica el monto" - {
              jugada.montoPorGanar(200.00) should be(400)
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
              val sucesos: Map[ResultadoMoneda, Double] = Map((CARA, 7500), (CRUZ, 2500))
              val ponderada = Distribuciones.ponderada(sucesos)

              ponderada.probabilidadDe(CARA) should be(0.75)
              ponderada.probabilidadDe(CRUZ) should be(0.25)
          }
        }
     }
}