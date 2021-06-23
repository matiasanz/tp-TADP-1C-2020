package Dominio

import Dominio.Utils.pesoTotal

case class Distribucion[R](probabilidades: Map[R, Float]){
	require(pesoTotal(probabilidades)-1 <= 0.00001)

	def probabilidadDe(suceso: R): Float = probabilidades.getOrElse(suceso, 0)
	def sucesosPosibles: Map[R, Float] = probabilidades.filter(_._2>0)
}

object Distribuciones {
	def equiprobable[R](sucesos: List[R]): Distribucion[R] = {
		Distribucion(sucesos.map(s => (s, 1.toFloat / sucesos.length)).toMap)
	}

	def eventoSeguro[R](suceso: R): Distribucion[R] = equiprobable[R](List(suceso))

	def ponderada[R](ponderacion: Map[R, Int]): Distribucion[R] = Distribucion({
		val pTotal = pesoTotal(ponderacion)
		ponderacion.map { case (suc, peso) => (suc, (peso.toDouble / pTotal).toFloat)}
	})
}


