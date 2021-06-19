import AlternativasAle._
import org.scalatest.freespec.AnyFreeSpec
import org.scalatest.matchers.must.Matchers.be
import org.scalatest.matchers.should.Matchers.convertToAnyShouldWrapper

class PruebaFuncional extends AnyFreeSpec{
  val jugadas: List[Ruleta] = List(Ruleta(25, AlRojo()), Ruleta(10, ADocena(2)), Ruleta(30, AlNumero(23)))

  "Primera parte" - {
    "Apuestas" - {
      "primer caso" in {
        jugadas.map(ruleta => ruleta.apply(3)).sum should be(50)
      }

      "segundo caso" in {
        jugadas.map(ruleta => ruleta.apply(14)).sum should be(80)
      }

      "tercer caso" in {
        jugadas.map(ruleta => ruleta.apply(23)).sum should be(1160)
      }

    }
  }
}





