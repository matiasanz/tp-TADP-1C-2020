package Dominio

import Dominio.Tipos._

case class SaldoInsuficienteException(jugador: Jugador, monto: Plata)
	extends RuntimeException(s"Se intento extraer ${monto} siendo el saldo de ${jugador.saldo}")

case class ApuestaIncompatibleException(apuesta: AnyApuesta, juego: AnyJuego)
	extends RuntimeException(s"Se intento jugar una apuesta de tipo ${apuesta.getClass.toString} en un juego de tipo ${juego.getClass.toString}")
