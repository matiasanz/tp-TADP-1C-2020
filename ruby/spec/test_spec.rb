describe Prueba do

  describe 'tests punto 1-a' do

    it 'la definicion de has_one sobre un atributo persitible existente, lo reescribe' do
      class Grade
        include ORM
        has_one String, named: :value
        has_one Numeric, named: :value
      end

      expect(Grade.atributos_persistibles.size).to eq 1
      expect(Grade.atributos_persistibles[0].tipo_atributo).to eq Numeric
    end

    it 'Los atributos persistibles deben poder leerse y setearse de forma normal' do
      p = Person.new
      p.first_name = "raul"
      p.last_name = 8

      expect(p.first_name).to eq "raul"
      expect(p.last_name).to eq 8
    end

    it 'true y false son Boolean' do
      expect(true.is_a?(Boolean)).to eq true
      expect(false.is_a?(Boolean)).to eq true
    end
  end

  describe 'tests punto 1-b' do

    it 'los objetos persistibles entienden el mensaje save!()' do
      p = Person.new
      p.save!

      expect(Person.hash_atributos_persistidos(p.id).size).to eq 1
      expect(Person.hash_atributos_persistidos(p.id)[:id]).to eq p.id

      Person.borrar_tabla
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

      Person.borrar_tabla
    end

    it 'prueba aislada' do
      p = Person.new
      p.first_name = "raul"
      p.last_name = "porcheto"
      p.age = 24
      p.admin = false
      p.save!

      expect(Person.atributos_persistibles.size).to eq 4
      expect(Person.hash_atributos_persistidos(p.id).size).to eq 5
      expect(Person.hash_atributos_persistidos(p.id)[:id]).to eq p.id
      expect(Person.hash_atributos_persistidos(p.id)[:first_name]).to eq "raul"
      expect(Person.hash_atributos_persistidos(p.id)[:last_name]).to eq "porcheto"
      expect(Person.hash_atributos_persistidos(p.id)[:age]).to eq 24
      expect(Person.hash_atributos_persistidos(p.id)[:admin]).to eq false

      Person.borrar_tabla
    end
  end

  describe 'tests punto 1-c' do

    it 'los objetos persistibles entienden el mensaje refresh!()' do
      p = Person.new
      p.save!
      p.refresh!

      Person.borrar_tabla
    end

    it 'usar refresh! con un objeto que no fue persistido, genera una excepcion' do
      expect { Person.new.refresh! }.to raise_error(RefreshException)
    end

    it 'refresh!() debe actualizar el estado del objeto en base a lo que se haya guardado en la base' do
      p = Person.new
      p.first_name = "jose"
      p.save!

      p.first_name = "pepe"
      expect(p.first_name).to eq "pepe"

      p.refresh!
      expect(p.first_name).to eq "jose"

      Person.borrar_tabla
    end
  end

  describe 'tests punto 1-d' do
    it 'Una vez olvidado, el objeto debe desaparecer del registro en disco y ya no debe tener seteado el atributo id' do
      p = Person.new
      p.first_name = "arturo"
      p.last_name = "puig"
      p.save!
      id = p.id
      p.forget!

      expect(p.id).to eq nil
      expect(Person.hash_atributos_persistidos(id)).to eq nil

      Person.borrar_tabla
    end
  end

  describe 'test_punto_2 a' do
    it 'all_instances()' do
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

      expect(Point.all_instances).to be_a(Array)

      # Retorna [Point(2,5), Point(1,3)]
      expect(Point.all_instances[0].x).to eq 2
      expect(Point.all_instances[0].y).to eq 5
      expect(Point.all_instances[0].id).to eq p1.id
      expect(Point.all_instances[1].x).to eq 1
      expect(Point.all_instances[1].y).to eq 3
      expect(Point.all_instances[1].id).to eq p2.id
      expect(Point.all_instances[2]).to eq nil

      p4 = Point.all_instances.first
      p4.add(p2)
      p4.save!

      # Retorna [Point(3,8), Point(1,3)]    (invertido me da, supongo que esta ok)
      expect(Point.all_instances[0].x).to eq 1
      expect(Point.all_instances[0].y).to eq 3
      expect(Point.all_instances[0].id).to eq p2.id
      expect(Point.all_instances[1].x).to eq 3
      expect(Point.all_instances[1].y).to eq 8
      expect(Point.all_instances[1].id).to eq p1.id
      expect(Point.all_instances[2]).to eq nil

      p2.forget!

      # Retorna [Point(3,8)]
      expect(Point.all_instances[0].x).to eq 3
      expect(Point.all_instances[0].y).to eq 8
      expect(Point.all_instances[0].id).to eq p1.id
      expect(Point.all_instances[1]).to eq nil

      Point.borrar_tabla
    end
  end

  describe 'tests punto 2-b' do
    it 'find_by_what(valor)' do

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

      expect(Student.find_by_id("5")).to be_a(Array)

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
      expect { Student.find_by_has_last_name("puente") }.to raise_error(NoMethodError)
      expect { Student.by_has_last_name("algo") }.to raise_error(NoMethodError)

      expect(Student.respond_to?(:find_by_has_last_name, false)).to eq false
      expect(Student.respond_to?(:find_by_promoted, false)).to eq true
      expect(Student.respond_to?(:t_has_last_name, false)).to eq false

      Student.borrar_tabla
    end

  end

  describe 'tests punto 3' do
    it 'a - Composición con un único objeto' do

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
      s.save!

      g = s.grade # Retorna Grade(8)
      expect(g.value).to eq 8

      g.value = 5
      g.save!

      expect(s.refresh!.grade).to be_a(Grade) # Retorna Grade(5)
      expect(s.refresh!.grade.value).to eq 5

      Student.borrar_tabla
      Grade.borrar_tabla
    end

    it 'a - Composición con un único objeto a travez de varias clases' do

      class Grade
        include ORM
        has_one Numeric, named: :value
      end

      class Student
        include ORM
        has_one String, named: :full_name
        has_one Grade, named: :grade
      end

      class AssistantProfessor
        include ORM
        has_one Student, named: :estudiante
      end

      s2 = AssistantProfessor.new
      s2.estudiante = Student.new
      s2.estudiante.full_name = "agustin mateo"
      s2.estudiante.grade = Grade.new
      s2.estudiante.grade.value = 9
      s2.save!

      g = s2.estudiante.grade
      g.value = 2
      g.save!

      expect(s2.refresh!.estudiante.grade).to be_a(Grade) # Retorna Grade(5)
      expect(s2.refresh!.estudiante.grade.value).to eq 2

      Student.borrar_tabla
      Grade.borrar_tabla
      AssistantProfessor.borrar_tabla
    end

    it 'b - Composición con múltiples objetos' do

      class Grade
        include ORM
        has_one Numeric, named: :value
      end

      class Student2
        include ORM
        has_one String, named: :full_name
        has_many Grade, named: :grades

        def initialize # solo lo puse para probar que funciona por si lo quiere usar el usuario
          inicializar_atributos
          super
        end
      end

      s = Student2.new
      s.full_name = "leo sbaraglia"
      expect(s.grades).to eq [] # Retorna []
      s.grades.push(Grade.new)
      s.grades.last.value = 8
      expect(s.grades.last.value).to eq 8
      s.grades.push(Grade.new)
      s.grades.last.value = 5
      expect(s.grades.last.value).to eq 5
      expect(Student2.atributos_persistibles.size).to eq 2
      s.save! # Salva al estudiante Y sus notas

      expect(s.grades[0].value).to eq 8
      expect(s.grades[1].value).to eq 5
      expect(s.grades[2]).to eq nil
      s.refresh! # Retorna [Grade(8), Grade(5)]
      expect(s.grades[0].value).to eq 8
      expect(s.grades[1].value).to eq 5
      expect(s.grades[2]).to eq nil

      g = s.grades.last
      g.value = 6
      g.save!

      s.refresh! # Retorna [Grade(8), Grade(6)]
      expect(s.grades[0].value).to eq 8
      expect(s.grades[1].value).to eq 6
      expect(s.grades[2]).to eq nil

      Student2.borrar_tabla
      Grade.borrar_tabla
      TADB::DB.clear_all
    end

    it 'b - Composición con múltiples objetos de tipo basico' do

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
      expect(s.cadenas).to eq [] # Retorna []
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
      s.cadenas[2] = "te va"

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

      Student.borrar_tabla
      TADB::DB.clear_all
    end
  end

  describe 'tests punto 3-c' do
    it 'herencia entre tipos' do

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
        has_one String, named: :full_name
        has_many String, named: :cuadernos
      end

      # Hay una tabla para los Alumnos con los campos id, nombre y nota. y cuadernos y un dato
      class Student3
        include Persona
        has_one Grade, named: :grade
      end

      g = Grade.new
      g.value = 9
      e = Student3.new
      e.grade = g
      e.full_name = "javier sans"
      e.un_dato = "un dato"
      e.save!

      expect(Student3.atributos_persistibles_totales.size).to eq 4
      expect(Student3.hash_atributos_persistidos(e.id).size).to eq 4

      expect(Grade.ancestors.include?(InstanciaPersistible)).to eq true
      expect(Grade.ancestors.include?(ORM)).to eq true
      expect(Grade.singleton_class.ancestors.include?(AdministradorDeTabla)).to eq true
      expect(Grade.singleton_class.ancestors.include?(EntidadPersistible)).to eq true

      expect(Persona.ancestors.include?(DummyModule)).to eq true
      expect(Persona.ancestors.include?(ORM)).to eq true
      expect(Persona.singleton_class.ancestors.include?(AdministradorDeTabla)).to eq false
      expect(Persona.singleton_class.ancestors.include?(EntidadPersistible)).to eq true

      expect(Student3.ancestors.include?(InstanciaPersistible)).to eq true
      expect(Student3.ancestors.include?(Persona)).to eq true
      expect(Student3.singleton_class.ancestors.include?(AdministradorDeTabla)).to eq true
      expect(Student3.singleton_class.ancestors.include?(EntidadPersistible)).to eq true

      # Hay una tabla para los Ayudantes con id, nombre, nota y tipo y cuadernos y un dato y libretas (si los ingresa)
      class AssistantProfessor2 < Student3
        has_one String, named: :type
        has_many String, named: :libretas
      end

      g2 = Grade.new
      g2.value = 6
      a = AssistantProfessor2.new
      a.grade = g2
      a.full_name = "federico rioja"
      a.type = "un tipo"
      a.libretas.push("tadp")
      a.save!

      expect(AssistantProfessor2.atributos_persistibles_totales.size).to eq 6
      expect(AssistantProfessor2.hash_atributos_persistidos(a.id).size).to eq 5 # -2 por que no se setearon todos los datos
      a.refresh! # no genera problemas

      expect(Student3.ancestors.include?(InstanciaPersistible)).to eq true
      expect(Student3.ancestors.include?(Student3)).to eq true
      expect(Student3.singleton_class.ancestors.include?(AdministradorDeTabla)).to eq true
      expect(Student3.singleton_class.ancestors.include?(EntidadPersistible)).to eq true

      Grade.borrar_tabla
      Student3.borrar_tabla
      AssistantProfessor2.borrar_tabla
      TADB::DB.clear_all
    end

    it 'all_instances y find_by' do

      module Persona
        include ORM
        has_one String, named: :full_name
      end

      class Grade
        include ORM
        has_one Numeric, named: :value
      end

      class Student
        include Persona
        has_one Grade, named: :grade
      end

      class AssistantProfessor3 < Student
        has_one String, named: :type
      end

      g = Grade.new
      g.value = 9
      e = Student.new
      e.grade = g
      e.full_name = "javier sans"
      e.save!

      g2 = Grade.new
      g2.value = 6
      a = AssistantProfessor3.new
      a.grade = g2
      a.full_name = "federico rioja"
      a.type = "a"
      a.save!

      expect(Persona.all_instances.size).to eq 2 #Trae todos los Estudiantes y Ayudantes
      expect(Grade.all_instances.size).to eq 2
      expect(Student.all_instances.size).to eq 2
      expect(AssistantProfessor3.all_instances.size).to eq 1

      e.send(:id=, "5")
      a.send(:id=, "5")

      e.save!
      a.save!

      expect(Student.find_by_id("5").size).to eq 2 #Trae Estudiantes y Ayudantes con id "5"
      expect(Student.find_by_full_name("federico rioja").size).to eq 2
      # 2 pq recien setie el id en 5, y con eso cree otra entrada con los mismos datos pero distinto id

      expect { Student.find_by_type("a") }.to raise_error(NoMethodError) # Falla! No todos entienden type!

      Grade.borrar_tabla
      Student.borrar_tabla
      AssistantProfessor3.borrar_tabla
    end
  end

  describe 'tests punto 4-a' do

    it 'Validaciones y Defaults' do

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
      s.full_name = 5
      expect { s.save! }.to raise_error(TipoDeDatoException) # Falla! El nombre no es un String!

      s.full_name = "pepe botella"
      s.save! # Pasa: grade es nil, pero eso vale.

      s.grade = Grade.new
      s.grade.value = "pepe"
      expect { s.save! }.to raise_error(TipoDeDatoException) # Falla! grade.value no es un Number

      s.grade = "algo"
      expect { s.save! }.to raise_error(TipoDeDatoException)

      Student.borrar_tabla
    end

    it 'Validaciones y Defaults con has many' do
      class Grade
        include ORM
        has_one Numeric, named: :value
        has_many Boolean, named: :cosas
      end

      class Student
        include ORM
        has_one String, named: :full_name
        has_many Grade, named: :grades
        has_many String, named: :cuadernos
      end

      s = Student.new
      s.full_name = "pepe botella"
      s.grades.push(Grade.new)
      s.grades.last.value = 8
      g = Grade.new
      g.value = 9
      g.cosas.push(true, false, true)
      s.grades.push(g)
      s.cuadernos.push("tadp", "am2", "gdd")

      s = Student.new
      s.full_name = "pepe botella"
      s.grades.push(Grade.new)
      s.grades.last.value = 8
      g = Grade.new
      g.value = 9
      g.cosas.push(true, 3, true) #falla por esta linea
      s.grades.push(g)
      s.grades.push("algo") #falla por esta linea
      s.cuadernos.push("tadp", "am2", true) #falla por esta linea
      expect { s.save! }.to raise_error(TipoDeDatoException)
      TADB::DB.clear_all
    end

    it "Validaciones de contenido" do

      class Grade
        include ORM
        has_one Numeric, named: :value
      end

      class Student
        include ORM
        has_one String, named: :full_name, no_blank: true
        has_one Numeric, named: :age, from: 18, to: 100
        has_many Grade, named: :grades, validate: proc { value > 2 }
      end

      s = Student.new
      s.full_name = ""
      expect { s.save! }.to raise_error(NoBlankException) # Falla! El nombre está vacío!
      s.full_name = "emanuel ortega"
      s.age = 15
      expect { s.save! }.to raise_error(FromException) # Falla! La edad es menor a 18!
      s.age = 103
      expect { s.save! }.to raise_error(ToException) # Falla! La edad es mayor a 100!
      s.age = 22
      s.grades.push(Grade.new)
      s.grades.last.value = -1
      expect { s.save! }.to raise_error(BlockValidateException) # Falla! grade.value no es > 2!
      TADB::DB.clear_all
    end

    it "Valores por defecto" do

      class Grade
        include ORM
        has_one Numeric, named: :value
      end

      class Student4
        include ORM
        has_one String, named: :full_name, default: "natalia natalia"
        has_one Grade, named: :grade, default: Grade.new, no_blank: true
      end

      s = Student4.new
      expect(s.full_name).to eq "natalia natalia"
      s.full_name = nil
      s.save!
      s.refresh!
      expect(s.full_name).to eq "natalia natalia"

      Grade.borrar_tabla
      Student4.borrar_tabla
    end

  end

end

