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
            expect {Personaje.has_one(:simbolo, named: :atributo) }.to raise_error(ClaseDesconocidaException)
        end

        it 'Las subclases de una clase persistible se obtienen correctamente' do
            expect(Personaje.instance_variable_get(:@submodulos)).to include(Ladron)
        end
    end

    describe 'Persistencia de Clase simple' do
        let(:personaje) {Personaje.new("Flash", 2500)}

        it 'atributos persistibles de una clase simple' do
            persistibles = Personaje.atributos_persistibles.keys
            expect(persistibles).to match_array([:comicidad, :enojon, :nombre, :id])
        end

        it 'persistir una clase simple' do
            expect(personaje.id).to be_nil
            personaje.save!
            expect(personaje.id).to_not be_nil
        end

        it 'persistir una clase con atributos nulos' do
            p = Personaje.new(nil, nil)
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
            expect(Personaje.find_by_id(id)).to match_array []
        end

        it 'Objeto salvado por segunda vez se actualiza en lugar de volver a insertarse' do
            personaje.save!
            id = personaje.id

            expect(id).not_to be_nil

            personaje.save!

            expect(personaje.id).to be(id)
            expect(Personaje.find_by_id(id).length).to be(1)
        end

        it 'Se intenta persistir un atributo que no es de la clase especificada y falla' do
            personaje.enojon = "Fideos con tuco"
            expect{ personaje.save! }.to raise_error(TipoErroneoException)
        end

        it 'un objeto que fue persistido se actualiza correctamente de la base de datos'do
            personaje.save!
            personaje.comicidad=10
            expect(personaje.comicidad).to be(10)
            expect(personaje.refresh!.comicidad).to be(2500)
        end

        it 'Personaje que no fue persistido no se actualiza' do
            expect{ personaje.refresh! }.to raise_error(ObjetoNoPersistidoException)
        end

        it 'Atributos no persistibles no se persisten' do
            personaje.atributoNoPersistible="Si me persisto"
            personaje.save!
            resultado = Personaje.find_by_id(personaje.id).first
            expect(resultado.atributoNoPersistible).to match("¡No se rian! podrian tener un hijo igual")
        end
    end

    describe 'Persistencia de subclases' do
        it 'Una subclase puede ser a su vez clase persistible' do
            expect(Ladron).to be_a(ModuloPersistible)
        end

        it 'atributos persistibles se heredan' do
            persistibles = Ladron.atributos_persistibles.keys
            expect(persistibles).to include(:comicidad, :enojon, :nombre, :id)
            expect(persistibles).to include(:sigilo)
        end

        it 'la subclase se persiste correctamente' do
            ladron = Ladron.new("Nik", 15, 85)

            expect(ladron.id).to be_nil
            ladron.save!
            expect(ladron.id).to_not be_nil
            expect(Ladron.find_by_id(ladron.id)).to match_array [ladron]
        end

        it 'subclase sin atributos y con constructor vacio se persiste y se recupera correctamente'do
            ladron = LadronDeSonrisas.new
            ladron.save!

            id = ladron.id
            expect(id).not_to be_nil

            ladron.refresh!
            expect(ladron.id).to match(id)
        end
    end

    describe 'Busqueda por atributo' do
        before(:each) do
            @ladri1 = Ladron.new("lucho", 35, 90)
            @ladri2 = Ladron.new("El gato", 35, 90)
            @ladri3 = Ladron.new("El gato", 325, 67)

            @ladri2.enojon=false

            @ladri1.save!
            @ladri2.save!
            @ladri3.save!
        end

        it 'Al buscar todas las instancias se obtienen efectivamente instancias' do
            instancias = Ladron.all_instances

            expect(instancias).to all be_instance_of Ladron
            expect(instancias.length).to be(3)
        end

        it 'Al buscar todas las instancias de una superclase, se obtienen todas juntas' do
            personaje = Personaje.new("H. Power", 479)
            personaje.save!

            resultado = Personaje.all_instances
            expect(resultado).to include(personaje)
            expect(resultado.length).to be(4)
        end

        it 'encontrar por id devuelve una unica instancia y es correcta' do
            resultados = Ladron.find_by_id(@ladri1.id)
            expect(resultados.length).to be(1)
            resultado = resultados.first
            expect(resultado.id).to eq(@ladri1.id)
            expect(resultado).to eq(@ladri1)
        end

        it 'encontrar por un string' do
            resultados = Ladron.find_by_nombre("El gato")
            expect(resultados.length).to be(2)
            expect(resultados).to match_array [@ladri2, @ladri3]
        end

        it 'encontrar por un booleano' do
            enojones = Ladron.find_by_enojon(true)
            expect(enojones).to match_array [@ladri1, @ladri3]

            noEnojones = Ladron.find_by_enojon(false)
            expect(noEnojones).to match_array(@ladri2)
        end
    end

    describe 'Composicion' do
        before(:each) do
            @duenio = Personaje.new('hagrid', 670)
            @mascota = Mascota.new('fang', @duenio, true)
            @mascota.save!
        end

        it 'un objeto esta compuesto por otra clase que no hereda de nada y se persiste' do
           expect(@mascota.id).to_not be_nil
        end

        it 'un objeto compuesto se recupera de la base de datos' do
            recuperado = Mascota.find_by_id(@mascota.id).first
            expect(recuperado.id).to_not be_nil
            expect(recuperado.duenio.id).to_not be_nil
        end

        it 'un objeto compuesto se busca por un atributo idem y se encuentra' do
            encontrados = Mascota.find_by_duenio(@duenio)
            expect(encontrados.length).to be(1)

            encontrado = encontrados.first
            expect(encontrado.id).to match(@mascota.id)
            expect(encontrado.duenio.id).to match(@duenio.id)
        end

        it 'compuesta de compuesta' do

            claseMuyCompuesta = ClaseMuyCompuesta.new(@mascota, nil)

            otroDuenio = Personaje.new("Dave el Barvaro", 3600)
            otraMascota = Mascota.new("Fafy", otroDuenio, true)

            claseTodaviaMasCompuesta = ClaseMuyCompuesta.new(otraMascota, claseMuyCompuesta)

            claseTodaviaMasCompuesta.save!

            resultado = ClaseMuyCompuesta.find_by_id(claseTodaviaMasCompuesta.id).first

            expect(resultado).to eq(claseTodaviaMasCompuesta)
            expect(resultado.instance_variables).to match(claseTodaviaMasCompuesta.instance_variables)
        end

        describe 'has many' do

            it 'clase con multiples atributos primitivos' do
                q = Quiniela.new.conResultado(5).conResultado(3).save!
                expect(q.id).to_not be_nil
                leidos = Quiniela.find_by_id(q.id)
                expect(leidos.length).to be(1)

                expect(leidos.first.resultados).to include(5,3)
            end

            it 'clase con multiples atributos compuestos' do
                pers1 = Personaje.new("Goku", 670)
                pers2 = Personaje.new("Mr Satan", 45000)

                dbz = Pelicula.new
                dbz.agregarPersonaje(pers1)
                dbz.agregarPersonaje(pers2)
                dbz.save!
                expect(dbz.id).not_to be_nil

                resultados = Pelicula.find_by_id(dbz.id)

                expect(resultados.length).to be(1)
                resultado = resultados.first
                expect(resultado.personajes).to include(pers1, pers2)
            end
        end
    end

    describe 'Default' do
        it 'Valor default se respeta para atributo primitivo y no altera los demas' do
            personaje = Personaje.new("Buckethead",500)
            objetoDefault = ClaseDefault.new(nil, personaje)
            objetoDefault.save!
            expect(objetoDefault.nombre).to match "Anonimo"
            expect(objetoDefault.personaje).to eq(personaje)
        end

        it 'Valor default se respeta para atributo compuesto y no altera los demas' do
            objetoDefault = ClaseDefault.new("juan carlos", nil)
            objetoDefault.save!
            expect(objetoDefault.nombre).to match "juan carlos"
            expect(objetoDefault.personaje).to eq(Personaje.new("Arbol", 0))
        end
    end

    describe 'Validador' do
        describe 'Generalidades' do
            it 'From/to en atributo no numerico' do
                expect{ValidadorDeAtributo.new(String, from:2, to: 4)}.to raise_error(ValidacionNoAdmitidaException)
            end

            it 'Argumentos opcionales' do
                expect { ValidadorDeAtributo.new(Personaje, {})}.to_not raise_error
                expect { ValidadorDeAtributo.new(Personaje, no_blank: true, validate: ->{true})}.to_not raise_error
                expect { ValidadorDeAtributo.new(Numeric, from: 1)}.to_not raise_error
            end
        end

        describe 'Numeros' do
            let(:validadorNumerico) do
                ValidadorDeAtributo.new(Numeric, no_blank: true, from: 0, to: 4, validate: lambda{|x| x<3})
            end
            let (:atributoNumerico) do
                AtributoHelper.as_simple_attribute(:atributo, Numeric, validadorNumerico)
            end

            it 'Validar dato numerico correcto' do
                dato = 2
                expect(validadorNumerico.cumple_no_blank?(dato)).to be_truthy
                expect(validadorNumerico.cumple_rango?(dato)).to be_truthy
                expect(validadorNumerico.cumple_validate?(dato)).to be_truthy
                expect{validadorNumerico.validar(atributoNumerico, dato)}.to_not raise_exception
            end

            it 'Validar dato numerico correcto' do
                expect(validadorNumerico.cumple_no_blank?(nil)).to be_falsey
                expect(validadorNumerico.cumple_rango?(-1)).to be_falsey
                expect(validadorNumerico.cumple_validate?(4)).to be_falsey
                expect{validadorNumerico.validar(atributoNumerico, 4)}.to raise_error(ValidateException)
            end
        end
    end

    describe 'mixines persistibles' do

        it 'son persistibles' do
            expect(Guerrero.atributos_persistibles.keys).to include(:id, :nombre, :comicidad, :enojon, :danio)
        end

        it 'clase que incluye mixin persistible se persiste correctamente' do
            misil = Misil.new(7000).save!
            expect(misil.id).to_not be_nil
            expect(misil.refresh!.danio).to be(7000)
            expect(Misil.find_by_id(misil.id).first.danio).to be(7000)
        end

        describe 'metodos del Modulo' do
            before(:each) do
                @goku = Guerrero.new("goku", 2000, 20).save!
                @vegeta = Guerrero.new("vegeta", 400, 25).save!
            end

            it 'all instances desde un mixin' do
                expect(Atacante.all_instances).to include(@goku, @vegeta)
            end

            it 'find by desde un mixin' do
                expect(Atacante.find_by_danio(25)).to match_array(@vegeta)
            end

        end
    end

    after(:each) do
        TADB::DB.clear_all
    end

end