import Dominio.Distribuciones.Probabilidad
import Dominio.Tipos.Plata
import Dominio.{ApuestaCompuesta, ApuestaSimple, Arriesgado, Cauto, CriterioJuego, Distribuciones, Jugador, Jugue, Marcadores, Pesimista, Racional, Saltee, Simulacion, SimulacionCompuesta, SimulacionSimple, SimulacionVacia}
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
                val montoPorResultado = ACara(CARA)(20, _)
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
            MonedaComun.resultadosPosibles.asMap should contain only((CARA, 0.5), (CRUZ, 0.5))
        }

        "Moneda cargada solo para cara" in {
            val monedaCargada = MonedaCargada(Distribuciones.eventoSeguro(CARA))
            monedaCargada.distribucion.probabilidadDe(CARA) should be(1)
            monedaCargada.distribucion.probabilidadDe(CRUZ) should be(0)

            monedaCargada.resultadosPosibles.asMap should not contain(CRUZ)
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
            val apuesta = ApuestaSimple(ACara(CARA), 30)
            MonedaComun.gananciasPosiblesPor(apuesta).asMap should contain only((60, .5), (0, .5))
        }

        "Ganancias por jugar a ruleta" in {
            val apuesta = ApuestaSimple(ANumero(1), 10)
            val distribucion = Ruleta.gananciasPosiblesPor(apuesta)

            distribucion.asMap.size should be(2)
            distribucion.probabilidadDe(360) should be_aprox(0.027) //1.0/37
            distribucion.probabilidadDe(0) should be_aprox(0.972) //36.0/37
        }
    }

    "Juegos sucesivos" - {

        "Moneda -> Ruleta" in {
            val combinacion = SimulacionCompuesta(List(
                SimulacionSimple(MonedaComun, ApuestaSimple(ACara(CARA), 10))
                , SimulacionSimple(Ruleta, ApuestaSimple(ANumero(0), 15))
            ))

            val distribucion = combinacion.simular(15.0).mapSucesos(Marcadores.saldoFinal)

            println(distribucion.asMap.toString)

            distribucion.asMap.size should be(3)
            distribucion.probabilidadDe(550) should be_aprox(1.38/100)
            distribucion.probabilidadDe(10) should be_aprox(48.61/100)
            distribucion.probabilidadDe(5) should be_aprox(0.5)
        }
    }

    "Eligiendo un plan de juego" - {

        val elegirEnBaseA: (Plata, List[Simulacion]) => CriterioJuego => Option[Simulacion]
            = (presup, combinaciones) => criterio=> Jugador(presup, criterio).elegirCombinacion(combinaciones)

        "Casos con una sola apuesta" - {
            val puntoMedio = SimulacionSimple(MonedaCargada(Distribuciones.ponderada(Map((CARA, 75), (CRUZ, 25)))), ApuestaSimple(ACara(CARA), 15))
            val pocoProbableYMuyBeneficioso = SimulacionSimple(Ruleta, ApuestaSimple(ANumero(1), 50))
            val muyProbableYPocoBeneficioso = SimulacionSimple(MonedaCargada(Distribuciones.eventoSeguro(CARA)), ApuestaSimple(ACara(CARA), 5))

            val combinaciones = List(
                puntoMedio
                , pocoProbableYMuyBeneficioso
                , muyProbableYPocoBeneficioso
            )

            val elegir = elegirEnBaseA(50, combinaciones)

            "Criterio arriesgado" in {
                elegir(Arriesgado) shouldBe Some(pocoProbableYMuyBeneficioso)
            }

            "Criterio Cauto" in {
                elegir(Cauto) shouldBe Some(muyProbableYPocoBeneficioso)
            }

            "Criterio racional" in {
                elegir(Racional) shouldBe Some(puntoMedio)
            }
        }

        "Casos con mas de una apuesta" - {

            val impagable = SimulacionSimple(MonedaComun, ApuestaSimple(ACara(CARA), 4000))

            val noGanoNadaPeroTampocoPierdo = SimulacionSimple(MonedaComun, ApuestaSimple(ACara(CARA), 1))

            val imposiblePeroBeneficiosa = SimulacionCompuesta(List(
                SimulacionSimple(MonedaCargada(eventoSeguro(CARA)), ApuestaSimple(ACara(CRUZ), 60))
                , SimulacionSimple(Ruleta, ApuestaSimple(ANumero(0), 40))
                , impagable
            ))
            val muyProbablePeroPocoRedituable = SimulacionCompuesta(List(
                SimulacionSimple(MonedaCargada(ponderada(Map((CRUZ, 8), (CARA, 2)))), ApuestaSimple(ACara(CRUZ), 5))
                , impagable
            ))

            val puntoMedio = SimulacionSimple(MonedaCargada(ponderada(Map((CRUZ, 7), (CARA, 3)))), ApuestaSimple(ACara(CRUZ), 35))

            val combinacionesCompuestas = List(
                imposiblePeroBeneficiosa
                , impagable
                , muyProbablePeroPocoRedituable
                , puntoMedio
                , noGanoNadaPeroTampocoPierdo
            )

            val elegir = elegirEnBaseA(110, combinacionesCompuestas)

            "Criterio arriesgado" in {
                elegir(Arriesgado) shouldBe Some(imposiblePeroBeneficiosa)
            }

            "Criterio Cauto" in {
                elegir(Cauto) shouldBe Some(muyProbablePeroPocoRedituable)
            }

            "Criterio racional" in {
                elegir(Racional) shouldBe Some(puntoMedio)
            }

            "Criterio miedoso" in {
                elegir(Pesimista) shouldBe Some(noGanoNadaPeroTampocoPierdo)
            }
        }

        "Casos no felices" - {

            "Combinacion impagable" in {
                val assert: CriterioJuego=>Unit = criterio=>{
                    elegirEnBaseA(
                        2
                        , List(SimulacionSimple(Ruleta, ApuestaSimple(ANumero(3), 123456789)))
                    ).apply(criterio) shouldBe None
                }

                assert(Cauto)
                assert(Racional)
                assert(Arriesgado)
            }

            "Combinacion vacia" in {
                val assert: CriterioJuego=>Unit = criterio=>{
                    Jugador(15, criterio).elegirCombinacion(List.empty) shouldBe None
                }

                assert(Cauto)
                assert(Racional)
                assert(Arriesgado)
            }
        }
    }
}