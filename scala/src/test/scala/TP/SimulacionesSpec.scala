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

    "Implementacion actual" - {
        "No se generan marcadores de mas" in {
            val sdaf: Distribucion[List[Marcador]] = SimulacionCompuesta(List(
                SimulacionSimple(MonedaComun, ApuestaSimple(ACara(CARA), 300))
                , SimulacionSimple(MonedaComun, ApuestaSimple(ACara(CARA), 300))
                , SimulacionSimple(MonedaComun, ApuestaSimple(ACara(CRUZ), 300))
                , SimulacionSimple(MonedaComun, ApuestaSimple(ACara(CRUZ), 300))
            )).simular(500)

            sdaf.getSucesos.foreach(_.length should be(1+4))
        }
    }


    //TODO: Deprecados

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
            "Un juego con una apuesta perdedora se simula correctamente" in {
                Try(jugadorConPresupuesto(70)
                    .jugarApuesta(ApuestaSimple(ACara(CARA), 200), CARA)
                ) should be(Failure(SaldoInsuficienteException(jugadorConPresupuesto(70), 200)))
            }

        }
    }
}