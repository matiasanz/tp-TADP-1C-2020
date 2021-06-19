/*package Juego

case object Jugada extends (Int => Apuesta) { //TODO, esta definicion esta bien? (Int => Apuesta)
  override def apply(monto: Int): Apuesta = Apuesta(monto)
}

case class Apuesta(monto: Int) extends (Juego => Int) {
  override def apply(juego: Juego): Int = juego.apply(monto)
}

trait Juego extends (Int => Int)


// CARA CRUZ <<-----------------

case class CaraCruz(valorElegido: ValorCaraCruz, valorObtenido: ValorCaraCruz) extends Juego {
  override def apply(monto: Int): Int = if (valorElegido == valorObtenido) monto * 2 else 0
}

trait ValorCaraCruz
case object Cara extends ValorCaraCruz
case object Cruz extends ValorCaraCruz


// RULETA <<-----------------

case class Ruleta(seJugoA: JugadaRuleta, numeroObtenido: Int) extends Juego {
  // TODO, deberia limitar el numero de 0 a 36? como se tira excepcion en constructor?
  override def apply(monto: Int): Int = seJugoA match {
    case AlRojo() => if (Rojo.contiene(numeroObtenido)) monto * 2 else 0
    case AlNegro() => if (Negro.contiene(numeroObtenido)) monto * 2 else 0
    case AlNumero(numeroElegido) => if (numeroElegido == numeroObtenido) monto * 36 else 0
    case APar() => if (numeroObtenido % 2 == 0) monto * 2 else 0 //TODO EXCEPTION, el 0 no cuenta como par ni impar
    case AImpar() => if (numeroObtenido % 2 != 0) monto * 2 else 0 //TODO EXCEPTION
    case ADocena(docenaElegida) => if (esDocena(docenaElegida)) monto * 3 else 0
  }

  private def esDocena(docenaElegida: Int): Boolean = {
    if (docenaElegida == 1 && numeroObtenido >= 1 && numeroObtenido <= 12) return true
    if (docenaElegida == 2 && numeroObtenido >= 13 && numeroObtenido <= 24) return true
    if (docenaElegida == 3 && numeroObtenido >= 25 && numeroObtenido <= 36) return true
    false
  }
}

trait JugadaRuleta
case class AlRojo() extends JugadaRuleta
case class AlNegro() extends JugadaRuleta
case class AlNumero(numeroElegido: Int) extends JugadaRuleta
case class APar() extends JugadaRuleta
case class AImpar() extends JugadaRuleta
case class ADocena(docenaElegida: Int) extends JugadaRuleta

trait Color {
  def contiene(num: Int): Boolean
}
case object Rojo extends Color {
  val valores: List[Int] = List(1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36)
  override def contiene(num: Int): Boolean = valores.contains(num)
}
case object Negro extends Color {
  val valores: List[Int] = List(2, 4, 6, 8, 10, 11, 13, 15, 17, 20, 22, 24, 26, 28, 29, 31, 33, 35)
  override def contiene(num: Int): Boolean = valores.contains(num)
}
case object SinColor extends Color { //TODO, no lo uso, almenos no todavia...
  val valores: List[Int] = List(0)
  override def contiene(num: Int): Boolean = valores.contains(num)
}
*/
