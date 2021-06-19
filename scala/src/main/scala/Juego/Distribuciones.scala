import Utils.Resultado

package object Distribuciones {
	type Suceso = Resultado

	class Distribucion(sucesos: Map[Suceso, Float]) {
		require(pesoTotal(sucesos) == 1)

		def sucesosPosibles: List[Suceso] = sucesos.filter(_._2 > 0).keys.toList
		def probabilidadDe(suceso: Suceso): Float = sucesos.getOrElse(suceso, 0)
	}

	class Equiprobable(sucesos: List[Suceso])
		extends Distribucion(sucesos.map(s => (s, 1.toFloat / sucesos.length)).toMap)

	class EventoSeguro(evento: Suceso)
		extends Equiprobable(List(evento))
		/*TODO Duda: Por esta herencia no puedo usar case class
		 * es importante? hay alguna alternativa ademas de armar el map con (suceso, 1)?
		 */

	class Ponderada(sucesos: Map[Suceso, Int])
		extends Distribucion({
			val pTotal = pesoTotal(sucesos)
			sucesos.map { case (suc, peso) => (suc, (peso.toDouble / pTotal).toFloat)}
		})

	def pesoTotal[T](sucesos: Map[Suceso, T])(implicit num: Numeric[T])  = sucesos.values.sum
}
