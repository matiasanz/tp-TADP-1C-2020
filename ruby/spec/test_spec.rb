describe Prueba do
    let(:prueba) {Prueba.new.materia}
    let(:assert_persistibles) {proc{|persistibles|
        expect(persistibles).to be_an_has_key(:nombre)
        expect(persistibles).to be_an_has_key(:comicidad)
        expect(persistibles).to be_an_has_key(:enojon)
        expect(persistibles).not_to be_an_has_key(:atributoNoPersistible)
    }}

    describe 'Tests de utilidades' do
        it 'debería pasar este test' do
            expect(prueba).to be :tadp
        end

        it 'true es booleano' do
            expect(true).to be_a(Boolean)
        end

        it 'false es booleano' do
            expect(false).to be_a(Boolean)
        end

        it 'parametro' do
            expect(:@algo.param?).to be_truthy
            expect(:algo.to_param).to be(:@algo)
        end

        it 'Se especifica un tipo que no es una clase y falla' do
            expect {Class.has_one(:simbolo, named: :atributo) }.to raise_error(ClaseDesconocidaException)
        end
    end

    describe 'Persistencia de Clase simple' do
        let(:personaje) {Personaje.new("Flash", 2500)}

        it 'atributos persistibles de una clase simple' do
            persistibles = Personaje.atributos_persistibles
            assert_persistibles.call(persistibles)
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
            expect(Ladron).to be_a(ClasePersistible)
        end

        it 'atributos persistibles se heredan' do
            persistibles = Ladron.atributos_persistibles
            assert_persistibles.call(persistibles)
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
    end

    after(:each) do
        TADB::DB.clear_all
    end

end