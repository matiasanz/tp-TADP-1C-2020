package Dominio

import Dominio.Distribuciones.Probabilidad
import Distribuciones.pesoTotal

case class Distribucion[S](asMap: Map[S, Probabilidad]){
	require(pesoTotal(asMap) - 1 <= 0.00001 && asMap.values.forall(_>=0))

	def probabilidadDe(rdo: S): Probabilidad = asMap.getOrElse(rdo, 0)

	def sucesos = asMap.keys

	def probabilidadDeCumplir(suceso: S=>Boolean) = mapSucesos(suceso).probabilidadDe(true)

	def listar = asMap.toList

	def mapSucesos[T]: (S=>T) => Distribucion[T]
		= (transform) => {
			val nueva = asMap.toList.map { case (rdo, proba) => transform(rdo) -> proba }
			Distribuciones.agrupar(nueva)
		}
}

object Distribuciones {
	type Probabilidad = Double

	def equiprobable[S](sucesos: List[S]): Distribucion[S] = {
		val mapEquiprobable = sucesos.map(_ -> 1.toDouble / sucesos.length).toMap
		Distribucion(mapEquiprobable)
	}

	def eventoSeguro[S](suceso: S): Distribucion[S] = equiprobable[S](List(suceso))

	def ponderada[S](ponderacion: Map[S, Double]): Distribucion[S] = {
		val pTotal = pesoTotal(ponderacion)
		val mapPonderada = ponderacion.map { case (suc, peso) => (suc, peso / pTotal)}
		Distribucion(mapPonderada)
	}

	def agrupar[S](distribucion: List[(S, Probabilidad)])
		= Distribucion(distribucion.groupMapReduce(_._1)(_._2)(_+_))

	def pesoTotal(sucesos: Map[_, Double]): Double = sucesos.values.sum
}


