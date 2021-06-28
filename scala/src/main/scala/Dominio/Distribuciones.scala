package Dominio

import Dominio.Distribuciones.Probabilidad
import Utils.pesoTotal

object Distribuciones {
	type Distribucion[R] = Map[R, Probabilidad]
	type Probabilidad = Double

	def equiprobable[R](sucesos: List[R]): Distribucion[R] = {
		sucesos.map(_ -> 1.toDouble / sucesos.length).toMap
	}

	def eventoSeguro[R](suceso: R): Distribucion[R] = equiprobable[R](List(suceso))

	def ponderada[R](ponderacion: Map[R, Double]): Distribucion[R] = {
		val pTotal = pesoTotal(ponderacion)
		ponderacion.map { case (suc, peso) => (suc, peso / pTotal)}
	}

	def map[R, S]: (Distribucion[R], R=>S) => Distribucion[S]
		= (distribucion, transform) => {
			val nueva = distribucion.toList.map { case (rdo, proba) => transform(rdo) -> proba }
			agrupar(nueva)
		}

	def agrupar[R](distribucion: List[(R, Probabilidad)])
		= distribucion.groupMapReduce(_._1)(_._2)(_+_)
}


