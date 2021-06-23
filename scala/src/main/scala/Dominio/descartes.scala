package Dominio

/*/*
		def simularJuegosSucesivos[R](juegos: List[(Juego[R], Apuesta[R])]): List[ArbolEscenarios]
			= juegos match {
				case (juego, apuesta)::juegos => ArbolEscenarios(simularJuego(juego, apuesta)),
						.map(esc => esc.conSubescenarios(simularJuegosSucesivos(esc.resultado, juegos)))
				case Nil =>
		}*/
		/*
		def escenariosPosiblesPara[R](juego: Juego[R], apuesta: Apuesta[R])
			= juego.distribucion.sucesosPosibles
				.groupBy[Boolean]((sucesos) => apuesta.cumple(sucesos._1))
				.map(x => (x._1, x._2.values.sum))

		def jugar[R](juego: Juego[R], apuestas: List[Apuesta[R]]): Unit ={

			type Escenario = (Try[Jugador], Float, List[_])
			val escenarioInicial: Escenario = (Try(this), 1.toFloat, List.empty)

			apuestas.foldLeft(List(escenarioInicial))(
				(escenariosPosibles: List[Escenario], siguienteApuesta: Apuesta[R]) => {

					for{
						(intentoAnterior, proba, subarboles) <- escenariosPosibles

						if(intentoAnterior.isSuccess){
							val siguienteIntento = intentoAnterior.get.intentarApostar(siguienteApuesta)

							if(siguienteIntento.isSuccess){
								juego.distribucion.sucesosPosibles.groupBy[Boolean]((sucesos) => siguienteApuesta.jugada.cumple(sucesos._1)).map(
									x => (x._1, x._2.values.sum) //TODO Sumar las probabilidades de casos exitosos/fallidos
								)

							}
						}
					}.yield subarboles
				}
			)
		}*/


//		def elegirCombinacion()*/