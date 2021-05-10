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

        it 'objeto persistido se olvida correctametne'do
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

        it 'un objeto se recupera correctamente de la base de datos'do
            personaje.save!
            personaje.instance_variable_set(:@comicidad, 10)
            expect(personaje.instance_variable_get(:@comicidad)).to be(10)
            personaje.refresh!
            expect(personaje.instance_variable_get(:@comicidad)).to be(2500)
        end
    end

    describe 'Persistencia de subclases' do
        it 'atributos persistibles se heredan' do
            persistibles = Ladron.atributos_persistibles
            assert_persistibles.call(persistibles)
            expect(persistibles).to include(:sigilo)
        end

        it 'la subclase se persiste correctamente' do
            ladron = Ladron.new("Nik", 200, 85)

            expect(ladron.id).to be_nil
            ladron.save!
            expect(ladron.id).to_not be_nil
        end

        it 'subclase sin atributos y con constructor vacio se persiste y se recupera correctamente'do
            ladron = LadronDeSonrisas.new
            ladron.save!

            id = ladron.id
            expect(id).not_to be_nil

            puts ("id: #{ladron.id}")

            ladron.refresh!
            expect(ladron.id).to match(id)
        end
    end

    describe 'Busqueda por atributo' do
        it 'encontrar por id devuelve una unica instancia y es correcta' do
            ladri = Ladron.new("lucho", 175, 90)
            ladri.save!

            resultados = Ladron.find_by_id(ladri.id)
            expect(resultados.length).to be(1)

            resultado = resultados.first
            expect(resultado.id).to eq(ladri.id)
            expect(resultado.equal?(ladri)).to be_truthy
        end

        it 'encontrar por un string' do
            nombre = "el gato"
            ladron = Ladron.new(nombre, 175, 90)
            ladron.save!
            resultado = Ladron.find_by_nombre(nombre).first
            expect(resultado.equal?(ladron)).to be_truthy

            Ladron.new(nombre, 200, 25).save!

            expect(Ladron.find_by_nombre(nombre).length).to be(2)
        end

        it 'encontrar por un booleano' do
            Ladron.new("manuel", 20, 10).save!
            Ladron.new("sebastian", 45, 20).save!
            d = Ladron.new("diego", 5, 15)
            d.enojon = false
            d.save!


            enojones = Ladron.find_by_enojon(true)
            expect(enojones.map{|e|e.nombre}).to match_array ["manuel", "sebastian"]

            noEnojones = Ladron.find_by_enojon(false)
            expect(noEnojones.map{|n|n.nombre}).to match_array(["diego"])
        end
    end

    describe 'all instances' do
        it 'todas las instancias son efectivamente instancias' do
            Ladron.new("juan carlos chorro", 325, 67).save!
            Ladron.new("ladron de hamburguesas", 900, 4).save!

            instancias = Ladron.all_instances

            expect(instancias).to all be_instance_of Ladron
            expect(instancias.length).to be(2)
        end
    end

    describe 'Composicion'
    it '' do
        duenio = Personaje.new('hagrid', 670)
       mascota = Mascota.new('fang', duenio, true)
       mascota.save!
       expect(mascota.id).to_not be_nil
   end

    after(:each) do
       TADB::DB.clear_all
    end
end