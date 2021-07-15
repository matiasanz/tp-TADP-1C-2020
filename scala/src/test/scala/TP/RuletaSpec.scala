package TP

import Juegos._
import org.scalatest.freespec.AnyFreeSpec
import org.scalatest.matchers.should.Matchers._

class RuletaSpec extends AnyFreeSpec{

    "Ruleta" - {
        import Juegos.Cuadricula._

        "Columna se calcula correctamente" in {
            columna(1) shouldBe 1
            columna(14) shouldBe 2
            columna(20) shouldBe 2
            columna(36) shouldBe 3
        }

        "Color es correcto" in {
            color(0) shouldBe INCOLORO
            color(14) shouldBe ROJO
            color(17) shouldBe NEGRO
            color(20) shouldBe NEGRO
            color(10) shouldBe NEGRO
        }

        "docena" in {
            docena(12) shouldBe 1
            docena(13) shouldBe 2
            docena(24) shouldBe 2
        }

        "paridad" - {
            "0 no cumple para par ni impar" in {
                AParidad(true).satisfechaPor(0) shouldBe false
                AParidad(false).satisfechaPor(0) shouldBe false
            }

            "Numeros pares son pares" in {
                for (numero <- 2 to 36 by 2)
                    AParidad(true).satisfechaPor(numero) shouldBe true
            }

            "Numeros impares son impares" in {
                for (numero <- 1 to 36 by 2)
                    AParidad(false).satisfechaPor(numero) shouldBe true
            }
        }
    }
}