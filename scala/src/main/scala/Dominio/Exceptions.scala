package Dominio

import Dominio.Tipos._
import Juegos.{Color, FormaMano}

case class SaldoInsuficienteException(jugador: Jugador, monto: Plata)
	extends RuntimeException(s"Se intento extraer ${monto} siendo el saldo de ${jugador.saldo}")

case class ColorSinOpuestoException(color: Color)
	extends RuntimeException(s"El color ${color.getClass.toString} no tiene definido opuesto")

case class MarcadoresInvalidosException(marcadores: List[Marcador])
	extends RuntimeException("Los siguientes marcadores se dieron antes de empezar "+ marcadores.toString())

case class FormaManoInesperadaException(jugada: FormaMano, encontrada: FormaMano)
	extends RuntimeException("Se jugo "+jugada.toString + " y no estaba preparada para "+encontrada.toString)