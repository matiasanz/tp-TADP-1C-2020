package TP

import Juegos._
import org.scalatest.freespec.AnyFreeSpec
import org.scalatest.matchers.should.Matchers._

class RuletaSpec extends AnyFreeSpec{

    "Ruleta" - {
        import Juegos.Cuadricula._

        "Columna se calcula correctamente" in {
            columna(1) should be(1)
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

        "paridad" - {
            "0 no cumple para par ni impar" in {
                AParidad(true).satisfechaPor(0) should be(false)
                AParidad(false).satisfechaPor(0) should be(false)
            }

            "Numeros pares son pares" in {
                for (numero <- 2 to 36 by 2)
                    AParidad(true).satisfechaPor(numero) should be(true)
            }

            "Numeros impares son impares" in {
                for (numero <- 1 to 36 by 2)
                    AParidad(false).satisfechaPor(numero) should be(true)
            }
        }
    }
}