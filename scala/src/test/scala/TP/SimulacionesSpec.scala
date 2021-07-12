package TP

import Dominio.Tipos.Plata
import Dominio._
import Juegos._
import org.scalatest.freespec.AnyFreeSpec
import org.scalatest.matchers.should.Matchers._

import scala.util.{Failure, Success, Try}

trait Proveedor{
    val jugadorConPresupuesto: Plata=>Jugador = Jugador(_, null)
}

class SimulacionesSpec extends AnyFreeSpec with Proveedor {

    "Simulando un solo juego" - {
        "Generalidades" - {
            "Jugador no se puede crear con menos plata" in {
                Try(jugadorConPresupuesto(-30)).isFailure should be(true)
            }

            "A un jugador no se le puede desacreditar mas plata de la que tiene" in {
                Try(jugadorConPresupuesto(15).desacreditar(16)).isFailure should be(true)
            }
        }

        "Cara cruz" - {
            val jugador = jugadorConPresupuesto(200)
            val apuesta = ApuestaSimple(AMoneda(CARA), 200)

            /*
            "Moneda Comun" - {
                "50% de probabilidad de ganar y de perder" in {
                    simularJuego(jugador, SimulacionSimple(MonedaComun, apuesta)) should contain only (
                        (jugadorConPresupuesto(400), 0.5)
                        , (jugadorConPresupuesto(0), 0.5)
                    )
                }
            }

            "Un juego con una apuesta compuesta perdedora en cualquier caso se simula correctamente" in {
                val ap = apuesta.compuestaCon(ApuestaSimple(JugadaMoneda(CARA), 300))
                simularJuego(jugadorConPresupuesto(600), SimulacionSimple(MonedaComun, ap)) should contain only (
                    (jugadorConPresupuesto(1100.0), 0.5.toFloat)
                    , (jugadorConPresupuesto(100),0.5.toFloat)
                )
            }*/

            "Un juego con una apuesta perdedora se simula correctamente" in {
                Try(jugadorConPresupuesto(70)
                    .jugarApuesta(ApuestaSimple(AMoneda(CARA), 200), CARA)
                ) should be(Failure(SaldoInsuficienteException(jugadorConPresupuesto(70), 200)))
            }

        }
    }
}