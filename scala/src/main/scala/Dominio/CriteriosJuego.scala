package Dominio
import Dominio.Distribuciones.Probabilidad
import Dominio.Tipos.Plata
import Marcadores._

trait CriterioJuego{

	def criterio: ((Simulacion, Distribucion[List[Marcador]]))=>Double

	def elegirEntre(presupuesto: Plata, combinaciones: List[Simulacion]): Option[Simulacion]
		= combinaciones.map(combinacion => (combinacion, combinacion.simular(presupuesto))  )
			.filter(_._2.probabilidadDeCumplir(seJugo) > 0) //Prescindible
			.maxByOption(criterio) //Maximo opcional
			.map(_._1) //Me quedo con la simulacion
}

case object Racional extends CriterioJuego {
	val criterio = _._2.probabilidades.map(puntaje.tupled).sum

	val puntaje: (List[Marcador], Probabilidad)=>Double
		= (marcadores, proba) => diferenciaSaldo(marcadores)*proba
}

case object Arriesgado extends CriterioJuego {
	val criterio = _._2.sucesos.map(diferenciaSaldo).max
}

case object Cauto extends CriterioJuego {
	val criterio = _._2.probabilidadDeCumplir(diferenciaSaldo(_)>=0)
}

//Criterio extra
case object Miedoso extends CriterioJuego {
	val criterio = _._2.sucesos.map(perdida).min

	private def perdida(marcadores: List[Marcador]): Plata
		= diferenciaSaldo(marcadores).min(0.0)
}