describe Prueba do

    describe 'Tests de utilidades' do
        it 'debería pasar este test' do
            expect(Prueba.new.materia).to be :tadp
        end

        it 'true es booleano' do
            expect(true).to be_a(Boolean)
        end

        it 'false es booleano' do
            expect(false).to be_a(Boolean)
        end

        it 'Se especifica un tipo que no es una clase y falla' do
            expect {ClaseSimple.has_one(:simbolo, named: :atributo) }.to raise_error(ORM::ClaseDesconocidaException)
        end

        it 'Las subclases de una clase persistible se obtienen correctamente' do
            expect(ClaseSimple.instance_variable_get(:@submodulos_inmediatos)).to include(SubclaseSimple)
        end
    end

    describe 'Persistencia de Clase simple' do
        let(:personaje) {ClaseSimple.new("Flash", 2500)}

        it 'atributos persistibles de una clase simple' do
            persistibles = ClaseSimple.atributos_persistibles.keys
            expect(persistibles).to match_array([:comicidad, :enojon, :nombre, :id])
        end

        it 'persistir una clase simple' do
            expect(personaje.id).to be_nil
            personaje.save!
            expect(personaje.id).to_not be_nil
        end

        it 'persistir una clase con atributos nulos' do
            p = ClaseSimple.new(nil, nil)
            p.enojon=nil
            p.save!
            expect(p.id).to_not be_nil
            expect([p.nombre, p.comicidad, p.enojon]).to all be_nil
        end

        it 'objeto persistido se olvida y no esta mas en db'do
            personaje.save!
            id=personaje.id
            personaje.forget!

            expect(personaje.id).to be_nil
            expect(ClaseSimple.find_by_id(id)).to match_array []
        end

        it 'Objeto salvado por segunda vez se actualiza en lugar de volver a insertarse' do
            personaje.save!
            id = personaje.id

            expect(id).not_to be_nil

            personaje.save!

            expect(personaje.id).to be(id)
            expect(ClaseSimple.find_by_id(id).length).to be(1)
        end

        it 'Se intenta persistir un atributo que no es de la clase especificada y falla' do
            personaje.enojon = "Fideos con tuco"
            expect{ personaje.save! }.to raise_error(ORM::TipoErroneoException)
        end

        it 'un objeto que fue persistido se actualiza correctamente de la base de datos'do
            personaje.save!
            personaje.comicidad=10
            expect(personaje.comicidad).to be(10)
            expect(personaje.refresh!.comicidad).to be(2500)
        end

        it 'Personaje que no fue persistido no se actualiza' do
            expect{ personaje.refresh! }.to raise_error(ORM::ObjetoNoPersistidoException)
        end

        it 'Atributos no persistibles no se persisten' do
            personaje.atributoNoPersistible="Si me persisto"
            personaje.save!
            resultado = ClaseSimple.find_by_id(personaje.id).first
            expect(resultado.atributoNoPersistible).to match("¡No se rian! podrian tener un hijo igual")
        end
    end

    describe 'Persistencia de subclases' do
        it 'Una subclase puede ser a su vez clase persistible' do
            expect(SubclaseSimple).to be_a(ORM::ModuloPersistible)
        end

        it 'atributos persistibles se heredan' do
            persistibles = SubclaseSimple.atributos_persistibles.keys
            expect(persistibles).to include(:comicidad, :enojon, :nombre, :id)
            expect(persistibles).to include(:sigilo)
        end

        it 'la subclase se persiste correctamente' do
            ladron = SubclaseSimple.new("Nik", 15, 85)

            expect(ladron.id).to be_nil
            ladron.save!
            expect(ladron.id).to_not be_nil
            expect(SubclaseSimple.find_by_id(ladron.id)).to match_array [ladron]
        end

        it 'subclase sin atributos y con constructor vacio se persiste y se recupera correctamente'do
            ladron = SubSubclaseVacia.new
            ladron.save!

            id = ladron.id
            expect(id).not_to be_nil

            ladron.refresh!
            expect(ladron.id).to match(id)
        end
    end

    describe 'Busqueda por atributo' do
        before(:each) do
            @ladri1 = SubclaseSimple.new("lucho", 35, 90)
            @ladri2 = SubclaseSimple.new("El gato", 35, 90)
            @ladri3 = SubclaseSimple.new("El gato", 325, 67)

            @ladri2.enojon=false

            @ladri1.save!
            @ladri2.save!
            @ladri3.save!
        end

        it 'Al buscar todas las instancias se obtienen efectivamente instancias' do
            instancias = SubclaseSimple.all_instances

            expect(instancias).to all be_instance_of SubclaseSimple
            expect(instancias.length).to be(3)
        end

        it 'Al buscar todas las instancias de una superclase, se obtienen todas juntas' do
            personaje = ClaseSimple.new("H. Power", 479)
            personaje.save!

            resultado = ClaseSimple.all_instances
            expect(resultado).to include(personaje)
            expect(resultado.length).to be(4)
        end

        it 'encontrar por id devuelve una unica instancia y es correcta' do
            resultados = SubclaseSimple.find_by_id(@ladri1.id)
            expect(resultados.length).to be(1)
            resultado = resultados.first
            expect(resultado.id).to eq(@ladri1.id)
            expect(resultado).to eq(@ladri1)
        end

        it 'encontrar por un string' do
            resultados = SubclaseSimple.find_by_nombre("El gato")
            expect(resultados.length).to be(2)
            expect(resultados).to match_array [@ladri2, @ladri3]
        end

        it 'encontrar por un booleano' do
            enojones = SubclaseSimple.find_by_enojon(true)
            expect(enojones).to match_array [@ladri1, @ladri3]

            noEnojones = SubclaseSimple.find_by_enojon(false)
            expect(noEnojones).to match_array(@ladri2)
        end
    end

    describe 'Composicion' do
        before(:each) do
            @duenio = ClaseSimple.new('hagrid', 670)
            @mascota = ClaseCompuesta.new('fang', @duenio, true)
            @mascota.save!
        end

        it 'un objeto esta compuesto por otra clase que no hereda de nada y se persiste' do
           expect(@mascota.id).to_not be_nil
        end

        it 'un objeto compuesto se recupera de la base de datos' do
            recuperado = ClaseCompuesta.find_by_id(@mascota.id).first
            expect(recuperado.id).to_not be_nil
            expect(recuperado.duenio.id).to_not be_nil
        end

        it 'un objeto compuesto se busca por un atributo idem y se encuentra' do
            encontrados = ClaseCompuesta.find_by_duenio(@duenio)
            expect(encontrados.length).to be(1)

            encontrado = encontrados.first
            expect(encontrado.id).to match(@mascota.id)
            expect(encontrado.duenio.id).to match(@duenio.id)
        end

        it 'compuesta de compuesta' do

            claseMuyCompuesta = ClaseMuyCompuesta.new(@mascota, nil)

            otroDuenio = ClaseSimple.new("Dave el Barvaro", 3600)
            otraMascota = ClaseCompuesta.new("Fafy", otroDuenio, true)

            claseTodaviaMasCompuesta = ClaseMuyCompuesta.new(otraMascota, claseMuyCompuesta)

            claseTodaviaMasCompuesta.save!

            resultado = ClaseMuyCompuesta.find_by_id(claseTodaviaMasCompuesta.id).first

            expect(resultado).to eq(claseTodaviaMasCompuesta)
            expect(resultado.instance_variables).to match(claseTodaviaMasCompuesta.instance_variables)
        end

        describe 'has many' do

            it 'clase con multiples atributos primitivos' do
                q = ClaseCompuestaDeMultiplesSimples.new.conResultado(5).conResultado(3).save!
                expect(q.id).to_not be_nil
                leidos = ClaseCompuestaDeMultiplesSimples.find_by_id(q.id)
                expect(leidos.length).to be(1)

                expect(leidos.first.resultados).to include(5,3)
            end

            it 'clase con multiples atributos compuestos' do
                pers1 = ClaseSimple.new("Goku", 670)
                pers2 = ClaseSimple.new("Mr Satan", 45000)

                dbz = ClaseCompuestaDeMultiplesCompuestas.new
                dbz.agregarPersonaje(pers1)
                dbz.agregarPersonaje(pers2)
                dbz.save!
                expect(dbz.id).not_to be_nil

                resultados = ClaseCompuestaDeMultiplesCompuestas.find_by_id(dbz.id)

                expect(resultados.length).to be(1)
                resultado = resultados.first
                expect(resultado.personajes).to include(pers1, pers2)
            end
        end
    end

    describe 'Default' do
        it 'Valor default se respeta para atributo primitivo y no altera los demas' do
            personaje = ClaseSimple.new("Buckethead", 500)
            objetoDefault = ClaseDefault.new(nil, personaje)
            objetoDefault.save!
            expect(objetoDefault.nombre).to match "Anonimo"
            expect(objetoDefault.personaje).to eq(personaje)
        end

        it 'Valor default se respeta para atributo compuesto y no altera los demas' do
            objetoDefault = ClaseDefault.new("juan carlos", nil)
            objetoDefault.save!
            expect(objetoDefault.nombre).to match "juan carlos"
            expect(objetoDefault.personaje).to eq(ClaseSimple.new("Arbol", 0))
        end
    end

    describe 'Validador' do
        describe 'Generalidades' do
            it 'From/to en atributo no numerico' do
                expect{ORM::ValidadorDeAtributos.as_validadores(String, from:2, to: 4)}.to raise_error(ORM::ValidacionNoAdmitidaException)
            end

            it 'Argumentos opcionales' do
                expect { ORM::ValidadorDeAtributos.as_validadores(ClaseSimple, {})}.to_not raise_error
                expect { ORM::ValidadorDeAtributos.as_validadores(ClaseSimple, no_blank: true, validate: ->{true})}.to_not raise_error
                expect { ORM::ValidadorDeAtributos.as_validadores(Numeric, from: 1)}.to_not raise_error
            end
        end

        describe 'Numeros' do
            let(:args) do
                {no_blank: true, from: 0, to: 4, validate: lambda{|x| x<3}}
            end
            let(:tipo) {Numeric}
            let (:atributoNumerico) do
                ORM::AtributoHelper.as_simple_attribute(:atributo, tipo, ORM::ValidadorDeAtributos.as_validadores(Numeric, args))
            end

            it 'Validar dato numerico correcto' do
                dato=0
                expect{ORM::ValidadorNoBlank.new(tipo, args).validar(atributoNumerico, dato)}.to_not raise_error
                expect{ORM::ValidadorFrom.new(tipo, args).validar(atributoNumerico, dato)}.to_not raise_error
                expect{ORM::ValidadorValidate.new(tipo, args).validar(atributoNumerico, dato)}.to_not raise_error
                expect{atributoNumerico.validar_instancia(dato)}.to_not raise_error
            end

            it 'Validar dato numerico correcto' do
                expect{ORM::ValidadorNoBlank.new(tipo, args).validar(atributoNumerico, nil)}.to raise_error ORM::BlankException
                expect{ORM::ValidadorFrom.new(tipo, args).validar(atributoNumerico, -1)}.to raise_error ORM::AtributoPersistibleException
                expect{ORM::ValidadorTo.new(tipo, args).validar(atributoNumerico, 5)}.to raise_error ORM::AtributoPersistibleException
                expect{ORM::ValidadorValidate.new(tipo, args).validar(atributoNumerico, 4)}.to raise_error ORM::ValidateException
                expect{atributoNumerico.validar_instancia(4)}.to raise_error(ORM::ValidateException)
            end

            it 'Instanciar validadores con args erroneos' do
                excepcion = ORM::CampoIncorrectoException
                expect{ORM::ValidadorTo.new(Numeric,to:Class)}.to raise_error(excepcion)
                expect{ORM::ValidadorFrom.new(Numeric, from: "Saraza")}.to raise_error(excepcion)
                expect{ORM::ValidadorValidate.new(Object,validate: 4)}.to raise_error(excepcion)
                expect{ORM::ValidadorNoBlank.new(SubSubclaseVacia, no_blank: SubSubclaseVacia.new)}.to raise_error(excepcion)
            end
        end
    end

    describe 'mixines persistibles' do

        it 'son persistibles' do
            expect(SubClaseConMixin.atributos_persistibles.keys).to include(:id, :nombre, :comicidad, :enojon, :danio)
        end

        it 'clase que incluye mixin persistible se persiste correctamente' do
            misil = Misil.new(7000).save!
            expect(misil.id).to_not be_nil
            expect(misil.refresh!.danio).to be(7000)
            expect(Misil.find_by_id(misil.id).first.danio).to be(7000)
        end

        describe 'metodos del Modulo' do
            before(:each) do
                @goku = SubClaseConMixin.new("goku", 2000, 20).save!
                @vegeta = SubClaseConMixin.new("vegeta", 400, 25).save!
            end

            it 'all instances desde un mixin' do
                expect(MixinPersistible.all_instances).to include(@goku, @vegeta)
            end

            it 'fails on unknown message' do
              expect{ String.pajarito }.to raise_error(NoMethodError)
              expect{ MixinPersistible.pajarito }.to raise_error(NoMethodError)
            end

            it 'find by desde un mixin' do
                expect(MixinPersistible.find_by_danio(25)).to match_array(@vegeta)
            end

            it 'mixin que incluye mixin persistible se persiste correctamente' do
                module PadrePadre
                    include MixinPersistible
                end

                module Intermediario
                    include PadrePadre
                    has_one String, named: :telefono
                end

                class Alguien
                    include Intermediario
                    has_one String, named: :algo

                    def initialize(algo, telefono)
                        @algo = algo
                        @telefono = telefono
                        super()
                    end
                end

                class Aaaaaa
                    include ORM::ObjetoPersistible
                    has_one Float, named: :pepe
                end

                a = Alguien.new("salame", "123").save!

                atacantes = MixinPersistible.all_instances
                expect(atacantes.size).to be(3)
                expect(atacantes.map{|at| at.id}).to include(a.id)
                expect(MixinPersistible.find_by_id(a.id).first.algo).to match "salame"
                expect(MixinPersistible.find_by_id(a.id).first.telefono).to match "123"
                expect(MixinPersistible.find_by_id(a.id).first.danio).to match nil

                expect(Intermediario.all_instances.map{|a| a.class}).to match_array([Alguien])
            end
        end
    end

    after(:each) do
        TADB::DB.clear_all
    end

end