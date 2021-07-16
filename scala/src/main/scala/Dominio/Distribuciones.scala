package Dominio

import Dominio.Distribuciones.Probabilidad
import Distribuciones.pesoTotal

case class Distribucion[S](asMap: Map[S, Probabilidad]){
	require((pesoTotal(asMap) - 1).abs <= 0.00001 && asMap.values.forall(_>=0))

	def listar = asMap.toList

	def getSucesos = asMap.keys

	def probabilidadDe(suceso: S): Probabilidad = asMap.getOrElse(suceso, 0)

	def probabilidadDe: (S=>Boolean)=>Probabilidad = mapSucesos(_).probabilidadDe(true)

	def promedioPonderado[T](deQue: S=>Double): Double
		= mapToList((suc, proba) => deQue(suc)*proba).sum

	def mapSucesos[T]: (S=>T) => Distribucion[T]
		= (transform) => {
			val nueva = mapToList((rdo, proba) => transform(rdo) -> proba  )
			Distribuciones.agrupar(nueva)
		}

	def mapToList[T]: ((S, Probabilidad)=>T) => List[T]
		= transform => listar.map(transform.tupled)
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


