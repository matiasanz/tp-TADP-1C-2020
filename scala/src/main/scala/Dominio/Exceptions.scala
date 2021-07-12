package Dominio

import Dominio.Tipos._

case class SaldoInsuficienteException(jugador: Jugador, monto: Plata)
	extends RuntimeException(s"Se intento extraer ${monto} siendo el saldo de ${jugador.saldo}")
