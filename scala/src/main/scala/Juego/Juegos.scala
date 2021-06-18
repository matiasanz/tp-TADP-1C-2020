import Apuestas.Jugada
import Utils.Resultado

package object Juegos {
	trait Juego {
		def resultado: Resultado
	}
}
