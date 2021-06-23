package Dominio

import Utils.pesoTotal

object Distribuciones {
	type Distribucion[R] = Map[R, Float]

	def equiprobable[R](sucesos: List[R]): Distribucion[R] = {
		sucesos.map(s => (s, 1.toFloat / sucesos.length)).toMap
	}

	def eventoSeguro[R](suceso: R): Distribucion[R] = equiprobable[R](List(suceso))

	def ponderada[R](ponderacion: Map[R, Double]): Distribucion[R] = {
		val pTotal = pesoTotal(ponderacion)
		ponderacion.map { case (suc, peso) => (suc, (peso / pTotal).toFloat)}
	}
}


