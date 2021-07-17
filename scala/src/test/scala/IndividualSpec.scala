import Dominio.ApuestaSimple
import Juegos._
import org.scalatest.freespec.AnyFreeSpec
import org.scalatest.matchers.should.Matchers.convertToAnyShouldWrapper
import org.scalatest.matchers.should.Matchers.be

class IndividualSpec extends AnyFreeSpec{
	"Piedra papel o tijera" - {
		"Ganar o perder" - {
			"Piedra" in {
				Piedra.jugarContra(Tijera) shouldBe Gana
				Piedra.jugarContra(Papel) shouldBe Pierde
			}

			/* TODO: No logro entender por que esto rompe, siendo que hay casos que hacen exactamente lo mismo y andan*/
			/*TODO: Hipotesis: Por cuestiones de scala, los case object se crean en orden y los val quedan en null porque aun no existen
			* pero pasan el analizador sintactico
			*/
			"Papel pierde" in {
				Papel.pierdeContra shouldBe Tijera
				Papel.jugarContra(Tijera) shouldBe Pierde
			}

			"Tijera pierde" in {
				Tijera.pierdeContra shouldBe Piedra
				Tijera.jugarContra(Piedra) shouldBe Pierde
			}

			"Papel gana" in {
				Papel.ganaContra shouldBe Piedra
				Papel.jugarContra(Piedra) shouldBe Gana
			}

			"Tijera gana" in {
				Tijera.jugarContra(Papel) shouldBe Gana
			}

			"Contra si mismo" in {
				val formas: List[FormaMano] = List(Piedra, Papel, Tijera)
				for(forma<-formas)
					forma.jugarContra(forma) shouldBe Empata
			}
		}

		"Chances" in {
			val apuesta = ApuestaSimple(AMano(Piedra), 10)
			val ganancias = PiedraPapelOTijera.gananciasPosiblesPor(apuesta)

			import ganancias.probabilidadDe
			probabilidadDe(20.0) shouldBe(0.4)
			probabilidadDe(10.0) shouldBe(0.35)
			probabilidadDe(0.0) shouldBe(0.25)
		}
	}
}
