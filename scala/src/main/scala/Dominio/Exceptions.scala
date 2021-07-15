package Dominio

import Dominio.Tipos._
import Juegos.Color

case class SaldoInsuficienteException(jugador: Jugador, monto: Plata)
	extends RuntimeException(s"Se intento extraer ${monto} siendo el saldo de ${jugador.saldo}")

case class ColorSinOpuestoException(color: Color)
	extends RuntimeException(s"El color ${color.getClass.toString} no tiene definido opuesto")

case class MarcadoresInvalidosException(marcadores: List[Marcador])
	extends RuntimeException("Los siguientes marcadores se dieron antes de empezar "+ marcadores.toString())