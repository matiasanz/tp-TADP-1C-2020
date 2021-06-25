package TP

import Dominio.Simulaciones._
import Dominio._
import Juegos._
import org.scalatest.freespec.AnyFreeSpec
import org.scalatest.matchers.should.Matchers._

import scala.util.{Failure, Success, Try}

class SimulacionesSpec extends AnyFreeSpec{
    "Simulando un solo juego" - {
        "Generalidades" - {
            "Jugador no se puede crear con menos plata" in {
                Try(Jugador(-30)).isFailure should be(true)
            }

            "A un jugador no se le puede desacreditar mas plata de la que tiene" in {
                Try(Jugador(15).desacreditar(16)).isFailure should be(true)
            }
        }

        "Cara cruz" - {
            val jugador = Jugador(200)
            val apuesta = ApuestaSimple(JugadaMoneda(CARA), 200)

            "Moneda Comun" - {
                "50% de probabilidad de ganar y de perder" in {
                    simularJuego(jugador, MonedaComun, apuesta) should contain only (
                        (Success(Jugador(400)), 0.5)
                        , (Success(Jugador(0)), 0.5)
                    )
                }
            }

            "Un juego con una apuesta compuesta perdedora en cualquier caso se simula correctamente" in {
                val ap = apuesta.compuestaCon(ApuestaSimple(JugadaMoneda(CARA), 300))
                simularJuego(Jugador(600), MonedaComun, ap) should contain only (
                    (Success(Jugador(1100.0)), 0.5.toFloat)
                    , (Success(Jugador(100)),0.5.toFloat)
                )
            }

            "Un juego con una apuesta perdedora se simula correctamente" in {
                Try(Jugador(70)
                    .jugarApuesta(ApuestaSimple(JugadaMoneda(CARA), 200), CARA)
                ) should be(Failure(SaldoInsuficienteException(Jugador(70), 200)))
            }

        }
    }
}