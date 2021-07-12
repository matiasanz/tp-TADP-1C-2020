package Dominio

import Dominio.Distribuciones.Probabilidad
import Distribuciones.pesoTotal

case class Distribucion[R](_probabilidades: Map[R, Probabilidad]){
	require(pesoTotal(probabilidades) - 1 <= 0.00001 && probabilidades.values.forall(_>=0))

	def probabilidades = _probabilidades.filter(_._2>0)

	def probabilidadDe(rdo: R): Probabilidad = probabilidades.getOrElse(rdo, 0)

	def sucesos = probabilidades.keys

	def probabilidadDeCumplir(suceso: R=>Boolean) = mapSucesos(suceso).probabilidadDe(true)

	def toList = probabilidades.toList

	def mapSucesos[S]: (R=>S) => Distribucion[S]
		= (transform) => {
			val nueva = probabilidades.toList.map { case (rdo, proba) => transform(rdo) -> proba }
			Distribuciones.agrupar(nueva)
		}
}

object Distribuciones {
	type Probabilidad = Double

	def equiprobable[R](sucesos: List[R]): Distribucion[R] = {
		val mapEquiprobable = sucesos.map(_ -> 1.toDouble / sucesos.length).toMap
		Distribucion(mapEquiprobable)
	}

	def eventoSeguro[R](suceso: R): Distribucion[R] = equiprobable[R](List(suceso))

	def ponderada[R](ponderacion: Map[R, Double]): Distribucion[R] = {
		val pTotal = pesoTotal(ponderacion)
		val mapPonderada = ponderacion.map { case (suc, peso) => (suc, peso / pTotal)}
		Distribucion(mapPonderada)
	}

	def agrupar[R](distribucion: List[(R, Probabilidad)])
		= Distribucion(distribucion.groupMapReduce(_._1)(_._2)(_+_))

	def pesoTotal(sucesos: Map[_, Double]): Double = sucesos.values.sum
}


