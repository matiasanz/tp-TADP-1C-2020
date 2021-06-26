package Dominio
import scala.util.Try

object Tipos{
	type Plata = BigDecimal
}

object Utils{ //TODO no hace mas falta
	def pesoTotal[T](sucesos: Map[_, T])(implicit num: Numeric[T]): T = sucesos.values.sum
}