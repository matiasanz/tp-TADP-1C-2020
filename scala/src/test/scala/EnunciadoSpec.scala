import Alt.{Arriesgado, Cauto, CriterioJuego, Racional}
import Dominio.Distribuciones.Probabilidad
import Dominio.Tipos.Plata
import Dominio.{ApuestaCompuesta, ApuestaSimple, Distribuciones, Jugador, Jugue, Saltee, Simulacion, SimulacionCompuesta, SimulacionSimple, SimulacionVacia, Simulaciones}
import Juegos._
import org.scalactic.TripleEqualsSupport
import org.scalatest.freespec.AnyFreeSpec
import org.scalatest.matchers.should.Matchers._
import Distribuciones._

class EnunciadoSpec extends AnyFreeSpec {

    val errorProbabilidad: Double = 0.01
    def be_aprox(exacto: Double) = ===(aprox(exacto))
    def aprox(exacto: Double): TripleEqualsSupport.Spread[Double] = exacto+-errorProbabilidad

    "Jugadas y Apuestas" - {
        "Tirar una moneda" - {
            "Crear una jugada a duplicar si sale cara" in {
                val montoPorResultado = JugadaMoneda(CARA)(20, _)
                montoPorResultado(CARA) should be(40)
                montoPorResultado(CRUZ) should be(0)
            }

            "Combinar varias apuestas" - {
                val apuestaColor = ApuestaSimple(AColor(ROJO), 25)
                val apuestaDocena = ApuestaSimple(ADocena(2), 10)
                val apuestaNumero = ApuestaSimple(ANumero(23), 30)
                val apuestaCompuesta = apuestaColor.compuestaCon(apuestaDocena).compuestaCon(apuestaNumero)


                "combinadas si se cumple uno" in {
                    apuestaCompuesta(3) should be(50)
                }

                "combinadas si se cumplen dos de tres" in {
                    apuestaCompuesta(14) should be(80)
                }

                "combinadas si se cumplen todos" in {
                    apuestaCompuesta(23) should be(1160)
                }
            }
        }
    }

    "Resultados de los juegos" - {
        "Moneda comun tiene igual probabilidad de salir una u otra" in {
            MonedaComun.resultadosPosibles.probabilidades should contain only((CARA, 0.5), (CRUZ, 0.5))
        }

        "Moneda cargada solo para cara" in {
            val monedaCargada = MonedaCargada(Distribuciones.eventoSeguro(CARA))
            monedaCargada.distribucion.probabilidadDe(CARA) should be(1)
            monedaCargada.distribucion.probabilidadDe(CRUZ) should be(0)

            monedaCargada.resultadosPosibles.probabilidades should not contain(CRUZ)
        }

        "Distribuciones" - {
            "Ponderada" in {
                val (rdo1, rdo2) = (true, false)
                val sucesos: Map[Boolean, Double] = Map((rdo1, 2.0/3), (rdo2, 1.0/3))
                val ponderada = Distribuciones.ponderada(sucesos)

                ponderada.probabilidadDe(rdo1) should be_aprox(0.66)
                ponderada.probabilidadDe(rdo2) should be_aprox(0.33)
            }
        }
    }

    "Jugando un juego" - {
        "Ganancias por jugar con moneda comun" in {
            val apuesta = ApuestaSimple(JugadaMoneda(CARA), 30)
            MonedaComun.distribucionDeGananciasPor(apuesta).probabilidades should contain only((60, .5), (0, .5))
        }

        "Ganancias por jugar a ruleta" in {
            val apuesta = ApuestaSimple(ANumero(1), 10)
            val distribucion = Ruleta.distribucionDeGananciasPor(apuesta)

            distribucion.probabilidades.size should be(2)
            distribucion.probabilidadDe(360) should be_aprox(0.027) //1.0/37
            distribucion.probabilidadDe(0) should be_aprox(0.972) //36.0/37
        }
    }

    "Juegos sucesivos" - {
        import Simulaciones._

        "Moneda -> Ruleta" in {
            val combinacion = List(
                SimulacionSimple(MonedaComun, ApuestaSimple(JugadaMoneda(CARA), 10))
                , SimulacionSimple(Ruleta, ApuestaSimple(ANumero(0), 15))
            )

            val distribucion = simularJuegos(Jugador(15, null), combinacion).distribucionFinal

            distribucion.probabilidades.size should be(3)
            distribucion.probabilidadDe(550) should be_aprox(1.38/100)
            distribucion.probabilidadDe(10) should be_aprox(48.61/100)
            distribucion.probabilidadDe(5) should be(0.5)
        }
    }

    "Juegos sucesivos alt" - {

        "Moneda -> Ruleta" in {
            val combinacion = SimulacionCompuesta(List(
                SimulacionSimple(MonedaComun, ApuestaSimple(JugadaMoneda(CARA), 10))
                , SimulacionSimple(Ruleta, ApuestaSimple(ANumero(0), 15))
            ))

            val distribucion = combinacion.simular(15).map(_.saldo)

            println(distribucion.probabilidades)
            distribucion.probabilidades.size should be(3)
            distribucion.probabilidadDe(550) should be_aprox(1.38/100)
            distribucion.probabilidadDe(10) should be_aprox(48.61/100)
            distribucion.probabilidadDe(5) should be_aprox(0.5)
        }
    }


    import Dominio.SimulacionVacia

    "Eligiendo un plan de juego" - {

        val elegirEnBaseA: (Plata, List[Simulacion]) => CriterioJuego => Simulacion
            = (presup, combinaciones) => criterio=> Jugador(presup, criterio).elegirCombinacion(combinaciones)

        "Casos con una sola apuesta" - {
            val puntoMedio = SimulacionSimple(MonedaCargada(Distribuciones.ponderada(Map((CARA, 75), (CRUZ, 25)))), ApuestaSimple(JugadaMoneda(CARA), 15))
            val pocoProbableYMuyBeneficioso = SimulacionSimple(Ruleta, ApuestaSimple(ANumero(1), 50))
            val muyProbableYPocoBeneficioso = SimulacionSimple(MonedaCargada(Distribuciones.eventoSeguro(CARA)), ApuestaSimple(JugadaMoneda(CARA), 5))

            val combinaciones = List(
                puntoMedio
                , pocoProbableYMuyBeneficioso
                , muyProbableYPocoBeneficioso
            )

            val elegir = elegirEnBaseA(50, combinaciones)

            "Criterio arriesgado" in {
                elegir(Arriesgado) should be(pocoProbableYMuyBeneficioso)
            }

            "Criterio Cauto" in {
                elegir(Cauto) should be(muyProbableYPocoBeneficioso)
            }

            "Criterio racional" in {
                elegir(Racional) should be(puntoMedio)
            }
        }

        "Casos con mas de una apuesta" - {

            val impagable = SimulacionSimple(MonedaComun, ApuestaSimple(JugadaMoneda(CARA), 4000))

            val imposiblePeroBeneficiosa = SimulacionCompuesta(List(
                SimulacionSimple(MonedaCargada(eventoSeguro(CARA)), ApuestaSimple(JugadaMoneda(CRUZ), 60))
                , SimulacionSimple(Ruleta, ApuestaSimple(ANumero(0), 40))
                , impagable
            ))
            val muyProbablePeroPocoRedituable = SimulacionCompuesta(List(
                SimulacionSimple(MonedaCargada(ponderada(Map((CRUZ, 8), (CARA, 2)))), ApuestaSimple(JugadaMoneda(CRUZ), 5))
                , impagable
            ))

            val puntoMedio = SimulacionSimple(MonedaCargada(ponderada(Map((CRUZ, 7), (CARA, 3)))), ApuestaSimple(JugadaMoneda(CRUZ), 35))

            val combinacionesCompuestas = List(
                imposiblePeroBeneficiosa
                , impagable
                , muyProbablePeroPocoRedituable
                , puntoMedio
            )

            val elegir = elegirEnBaseA(110, combinacionesCompuestas)

            "Criterio arriesgado" in {
                elegir(Arriesgado) should be(imposiblePeroBeneficiosa)
            }

            "Criterio Cauto" in {
                elegir(Cauto) should be(muyProbablePeroPocoRedituable)
            }

            "Criterio racional" in {
                elegir(Racional) should be(puntoMedio)
            }
        }

        "Casos no felices" - {
            "Combinacion impagable" in {
                val assert: CriterioJuego=>Unit = criterio=>{
                    elegirEnBaseA(
                        2
                        , List(SimulacionSimple(Ruleta, ApuestaSimple(ANumero(3), 123456789)))
                    ).apply(criterio) should be(SimulacionVacia)
                }

                assert(Cauto)
                assert(Racional)
                assert(Arriesgado)
            }

            "Combinacion vacia" in {
                val assert: CriterioJuego=>Unit = criterio=>{
                    Jugador(15, criterio).elegirCombinacion(List.empty) should be(SimulacionVacia)
                }

                assert(Cauto)
                assert(Racional)
                assert(Arriesgado)
            }
        }
    }



}