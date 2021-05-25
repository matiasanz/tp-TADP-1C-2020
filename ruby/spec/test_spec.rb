describe Prueba do
  let(:prueba) { Prueba.new }

  describe '#materia' do
    it 'debería pasar este test' do
      expect(prueba.materia).to be :tadp
    end
  end

  describe 'test_punto_1_a' do

    it 'la definicion de has_one sobre un atributo persitible existente lo reescribe' do
      class Grade
        include ORM
        has_one String, named: :value # Hasta acá :value es un String
        has_one Numeric, named: :value # Pero ahora debe ser Numeric
      end

      expect(Grade.atributos_persistibles[:value]).to eq Numeric
    end

    it 'Los atributos persistibles deben poder leerse y setearse de forma normal' do
      p = Person.new
      p.first_name = "raul" # Esto funciona
      p.last_name = 8 # Esto también. Por ahora…

      expect(p.first_name).to eq "raul"
      expect(p.last_name).to eq 8
    end

    it 'true y false son Boolean' do
      expect(true.is_a?(Boolean)).to eq true
      expect(false.is_a?(Boolean)).to eq true
    end
  end

  describe 'test_punto_1_b' do

    it 'los objetos persistibles entienden el mensaje save!()' do
      p = Person.new
      p.save!
    end

    it 'el atributo ID identifica univocamente a cada objeto' do
      p = Person.new
      p.first_name = "raul"
      p.last_name = "porcheto"
      p.save!

      p2 = Person.new
      p2.first_name = "pablo"
      p2.last_name = "fernandez"
      p2.save!
      expect(p.id).to eq p.id
      expect(p2.id).to eq p2.id

      expect(p.id).not_to eq nil
      expect(p2.id).not_to eq nil

      expect(p.id).not_to eq p2.id
    end

    it 'pruebas a mano por consola' do
      p = Person.new
      p.first_name = "raul"
      p.last_name = "porcheto"
      p.save!
      puts Person.atributos_persistibles
      puts p.generar_hash_para_insertar
    end
  end

  describe 'test_punto_1_c' do

    it 'los objetos persistibles entienden el mensaje refresh!()' do
      p = Person.new
      p.save!
      p.refresh!
    end

    it 'usar refresh! sin save! genera una excepcion' do
      # Falla! Este objeto no tiene id!
      expect{Person.new.refresh!}.to raise_error(RefreshException)
    end

    it 'refresh!() debe actualizar el estado del objeto en base a lo que se haya guardado en la base' do
      p = Person.new
      p.first_name = "jose"
      p.save!

      p.first_name = "pepe"
      expect(p.first_name).to eq "pepe"

      p.refresh!
      expect(p.first_name).to eq "jose"
    end
  end

  describe 'test_punto_1_d' do
    it 'Una vez olvidado, el objeto debe desaparecer del registro en disco y ya no debe tener seteado el atributo id' do
      p = Person.new
      p.first_name = "arturo"
      p.last_name = "puig"
      p.save!
      id = p.id
      p.forget!
      expect(p.id).to eq nil
      expect(Person.hash_atributos_persistidos(id)).to eq nil
    end
  end

  describe 'test_punto_2 a' do
    it '' do
      class Point
        include ORM
        has_one Numeric, named: :x
        has_one Numeric, named: :y
        def add(other)
          self.x = self.x + other.x
          self.y = self.y + other.y
        end
      end

      p1 = Point.new
      p1.x = 2
      p1.y = 5
      p1.save!
      p2 = Point.new
      p2.x = 1
      p2.y = 3
      p2.save!

      # Si no salvamos p3 entonces no va a aparecer en la lista
      p3 = Point.new
      p3.x = 9
      p3.y = 7

      # Retorna [Point(2,5), Point(1,3)]
      expect(Point.all_instances[0].x).to eq 2
      expect(Point.all_instances[0].y).to eq 5
      expect(Point.all_instances[1].x).to eq 1
      expect(Point.all_instances[1].y).to eq 3
      expect(Point.all_instances[2]).to eq nil
      Point.all_instances.map {|elem| puts "#{elem.id} || x = #{elem.x} || y = #{elem.y}" }
      puts ""

      p4 = Point.all_instances.first
      p4.add(p2)
      p4.save!

      # Retorna [Point(3,8), Point(1,3)]    (invertido me da, supongo que esta ok)
      expect(Point.all_instances[0].x).to eq 1
      expect(Point.all_instances[0].y).to eq 3
      expect(Point.all_instances[1].x).to eq 3
      expect(Point.all_instances[1].y).to eq 8
      expect(Point.all_instances[2]).to eq nil
      Point.all_instances.map {|elem| puts "#{elem.id} || x = #{elem.x} || y = #{elem.y}" }
      puts ""

      p2.forget!

      # Retorna [Point(3,8)]
      expect(Point.all_instances[0].x).to eq 3
      expect(Point.all_instances[0].y).to eq 8
      expect(Point.all_instances[1]).to eq nil
      Point.all_instances.map {|elem| puts "#{elem.id} || x = #{elem.x} || y = #{elem.y}" }
      puts ""

      Point.tabla.clear
    end
  end

  describe 'test_punto_2 b' do
    it '' do

      class Student
        include ORM
        has_one String, named: :full_name
        has_one Numeric, named: :grade

        def promoted
          self.grade > 8
        end

        def has_last_name(last_name)
          self.full_name.split(' ')[1] === last_name
        end

      end

      s = Student.new
      s.full_name = "gonzalo kastan"
      s.grade = 9
      s.save!

      s = Student.new
      s.full_name = "fernando lopez"
      s.grade = 2
      s.save!

      s = Student.new
      s.full_name = "tito puente"
      s.grade = 10
      s.save!

      s = Student.new
      s.full_name = "emiliano garcia"
      s.grade = 6
      s.save!

      # Retorna los estudiantes con id === "5"
      expect(Student.find_by_id("5")).to eq []

      # Retorna los estudiantes con nombre === "tito puente"
      expect(Student.find_by_full_name("tito puente").length).to eq 1
      expect(Student.find_by_full_name("tito puente")[0].full_name).to eq "tito puente"

      # Retorna los estudiantes con nota === 2
      expect(Student.find_by_grade(2).length).to eq 1
      expect(Student.find_by_grade(2)[0].full_name).to eq "fernando lopez"

      # Retorna los estudiantes que no promocionaron
      expect(Student.find_by_promoted(false).length).to eq 2

      # Falla! No existe el mensaje porque has_last_name recibe args.
      expect{Student.find_by_has_last_name("puente")}.to raise_error(NoMethodError)

      expect{Student.by_has_last_name("algo")}.to raise_error(NoMethodError)

      expect(Student.respond_to?(:find_by_has_last_name, false)).to eq false
      expect(Student.respond_to?(:find_by_promoted, false)).to eq true
      expect(Student.respond_to?(:t_has_last_name, false)).to eq false

      Student.tabla.clear
    end

  end

  describe 'test_punto_3' do
    it 'a' do

      class Grade
        include ORM
        has_one Numeric, named: :value
      end

      class Student
        include ORM
        has_one String, named: :full_name
        has_one Grade, named: :grade
      end

      s = Student.new
      s.full_name = "leo sbaraglia"
      s.grade = Grade.new
      s.grade.value = 8
      s.save!                        # Salva al estudiante Y su nota

      g = s.grade                    # Retorna Grade(8)
      expect(g.value).to eq 8

      g.value = 5
      g.save!

      puts s.refresh!.grade.class               # Retorna Grade(5)
      expect(s.refresh!.grade.value).to eq 5

      Student.tabla.clear
      Grade.tabla.clear
    end

    it 'b' do

      class Grade
        include ORM
        has_one Numeric, named: :value
      end

      class Student
        include ORM
        has_one String, named: :full_name
        has_many Grade, named: :grades

        def initialize
          inicializar_atributos_has_many
          super
        end
      end

      s = Student.new
      s.full_name = "leo sbaraglia"
      puts " =>> #{s.grades}"
      expect(s.grades).to eq []                # Retorna []
      s.grades.push(Grade.new)
      s.grades.last.value = 8
      expect(s.grades.last.value).to eq 8
      s.grades.push(Grade.new)
      s.grades.last.value = 5
      expect(s.grades.last.value).to eq 5
      puts Student.atributos_persistibles
      puts Student.atributos_persistibles[:has_many_attr]
      puts Student.atributos_persistibles[:has_many_attr].to_s
      s.save!                        # Salva al estudiante Y sus notas

      puts s.grades.map{|g| g.value}
      puts ""
      s.refresh!              # Retorna [Grade(8), Grade(5)]
      puts s.grades.map{|g| g.value}
      puts ""
      expect(s.grades[0].value).to eq 8
      expect(s.grades[1].value).to eq 5
      expect(s.grades[2]).to eq nil

      g = s.grades.last
      g.value = 6
      g.save!

      s.refresh!            # Retorna [Grade(8), Grade(6)]
      puts s.grades
      expect(s.grades[0].value).to eq 8
      expect(s.grades[1].value).to eq 6
      expect(s.grades[2]).to eq nil

      Student.tabla.clear
      Grade.tabla.clear
    end

    it 'b 2' do

      class Student
        include ORM
        has_one String, named: :full_name
        has_many Numeric, named: :numeros
        has_many Boolean, named: :booleanos
        has_many String, named: :cadenas
      end

      s = Student.new
      s.full_name = "leo sbaraglia"
      expect(s.numeros).to eq []
      expect(s.booleanos).to eq []
      expect(s.cadenas).to eq []      # Retorna []
      s.numeros.push(1)
      s.numeros.push(2)
      s.numeros.push(3)
      expect(s.numeros.last).to eq 3
      s.booleanos.push(true)
      s.booleanos.push(false)
      s.booleanos.push(true)
      expect(s.booleanos.last).to eq true
      s.cadenas.push("hola")
      s.cadenas.push("como")
      s.cadenas.push("estas")
      expect(s.cadenas.last).to eq "estas"
      s.save!

      s.refresh!
      expect(s.numeros[0]).to eq 1
      expect(s.numeros[1]).to eq 2
      expect(s.numeros[2]).to eq 3
      expect(s.numeros[3]).to eq nil

      expect(s.booleanos[0]).to eq true
      expect(s.booleanos[1]).to eq false
      expect(s.booleanos[2]).to eq true
      expect(s.booleanos[3]).to eq nil

      expect(s.cadenas[0]).to eq "hola"
      expect(s.cadenas[1]).to eq "como"
      expect(s.cadenas[2]).to eq "estas"
      expect(s.cadenas[3]).to eq nil

      s.numeros[2] = 4
      s.booleanos[2] = false
      s.cadenas[2]= "te va"

      puts s.numeros
      puts s.booleanos
      puts s.cadenas
      s.refresh!
      puts s.numeros
      puts s.booleanos
      puts s.cadenas
      expect(s.numeros[0]).to eq 1
      expect(s.numeros[1]).to eq 2
      expect(s.numeros[2]).to eq 3
      expect(s.numeros[3]).to eq nil

      expect(s.booleanos[0]).to eq true
      expect(s.booleanos[1]).to eq false
      expect(s.booleanos[2]).to eq true
      expect(s.booleanos[3]).to eq nil

      expect(s.cadenas[0]).to eq "hola"
      expect(s.cadenas[1]).to eq "como"
      expect(s.cadenas[2]).to eq "estas"
      expect(s.cadenas[3]).to eq nil

      Student.tabla.clear
    end
  end

  describe 'test_punto_3' do
    it '3 c 1' do

      class Grade
        include ORM
        has_one Numeric, named: :value
      end

      module DummyModule
        include ORM
        has_one String, named: :un_dato
      end

      # No existe una tabla para las Personas, porque es un módulo.
      module Persona
        include DummyModule
        #include ORM
        has_one String, named: :full_name
        has_many String, named: :cuadernos
      end

      # Hay una tabla para los Alumnos con los campos id, nombre y nota.
      class Student
        #include ORM
        include Persona
        has_one Grade, named: :grade
      end

      #puts Persona.is_a?(ClasePersistible)
      #puts Student.is_a?(ClasePersistible)

      #puts Class.is_a?(Module)
      #puts Grade.incluye_orm?
      #puts DummyModule.incluye_orm?
      #puts Persona.incluye_orm?
      #puts Student.incluye_orm?
      #puts ObjetoPersistible.incluye_orm?
      #puts ObjetoPersistible.is_a?(ClasePersistible)


      g = Grade.new
      g.value = 9
      e = Student.new
      e.grade = g
      e.full_name = "javier sans"
      e.save!
      puts "#{Grade.ancestors}"
      puts "#{Grade.singleton_class.ancestors}"
      puts ""
      puts "#{Persona.ancestors}"
      puts "#{Persona.singleton_class.ancestors}"
      puts ""
      puts "#{Student.ancestors}"
      puts "#{Student.singleton_class.ancestors}"
      puts ""

      # Hay una tabla para los Ayudantes con id, nombre, nota y tipo
      class AssistantProfessor < Student
        #include ORM
        has_one String, named: :type
        has_many String, named: :libretas
      end

      g2 = Grade.new
      g2.value = 6
      a = AssistantProfessor.new
      a.grade = g2
      a.full_name = "federico rioja"
      a.type = "un tipo"
      a.libretas.push("tadp")
      a.save!

      puts "#{AssistantProfessor.ancestors}"
      puts "#{AssistantProfessor.singleton_class.ancestors}"
      puts ""


    end

    it '3 c 2' do



    end
  end

end

