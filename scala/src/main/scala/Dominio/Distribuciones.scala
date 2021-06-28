package Dominio

import Dominio.Distribuciones.Probabilidad
import Utils.pesoTotal

case class Distribucion[R](_probabilidades: Map[R, Probabilidad]){
	require(pesoTotal(probabilidades) - 1 <= 0.00001)

	def probabilidades = _probabilidades.filter(_._2>0)
	def sucesos = probabilidades.keys

	def probabilidadDe(rdo: R): Probabilidad = probabilidades.getOrElse(rdo, 0)

	def probabilidadDeExito(suceso: R=>Boolean) = map(suceso).probabilidadDe(true)

	def toList = probabilidades.toList

	def map[S]: (R=>S) => Distribucion[S]
		= (transform) => {
			val nueva = probabilidades.toList.map { case (rdo, proba) => transform(rdo) -> proba }
			Distribuciones.agrupar(nueva)
		}


}

object Distribuciones {
	type Probabilidad = Double

	def equiprobable[R](sucesos: List[R]): Distribucion[R] = {
		val d = sucesos.map(_ -> 1.toDouble / sucesos.length).toMap
		Distribucion(d)
	}

	def eventoSeguro[R](suceso: R): Distribucion[R] = equiprobable[R](List(suceso))

	def ponderada[R](ponderacion: Map[R, Double]): Distribucion[R] = {
		val pTotal = pesoTotal(ponderacion)
		val d = ponderacion.map { case (suc, peso) => (suc, peso / pTotal)}
		Distribucion(d)
	}

	def agrupar[R](distribucion: List[(R, Probabilidad)])
		= Distribucion(distribucion.groupMapReduce(_._1)(_._2)(_+_))
}


