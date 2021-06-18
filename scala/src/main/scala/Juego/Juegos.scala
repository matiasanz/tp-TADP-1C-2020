import Apuestas.Jugada
import Utils.Resultado

package object Juegos {
	trait Juego {
		def jugadasPosibles: List[Jugada]
		def resultado: Resultado
	}

}
