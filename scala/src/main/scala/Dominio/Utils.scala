package Dominio
import scala.util.Try

object Tipos{
	type Plata = BigDecimal
}

object Utils{
	def pesoTotal(sucesos: Map[_, Double]): Double = sucesos.values.sum
}