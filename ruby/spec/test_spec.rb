describe Prueba do
    let(:prueba) {Prueba.new.materia}
    let(:assert_persistibles) {proc{|persistibles|
        expect(persistibles).to be_an_has_key(:nombre)
        expect(persistibles).to be_an_has_key(:velocidad)
        expect(persistibles).not_to be_an_has_key(:atributoNoPersistible)
    }}

    describe '#Test de consuelo' do
        it 'debería pasar este test' do
          expect(prueba).to be :tadp
        end
    end

    describe 'Clase simple' do
        it 'atributos de una clase simple' do
            persistibles = Personaje.atributos_persistibles
            assert_persistibles.call(persistibles)
        end

        it 'persistir una clase simple' do
            personaje = Personaje.new("Flash", 2500)

            expect(personaje.id).to be_nil
            personaje.save!
            expect(personaje.id).to_not be_nil
        end

        it 'atributos de una clase que hereda de otra' do
            persistibles = Ladron.atributos_persistibles
            assert_persistibles.call(persistibles)
            expect(persistibles).to include(:sigilo)
        end

        it 'persistir una clase que hereda de otra' do
            ladron = Ladron.new("Nik", 200, 85)

            expect(ladron.id).to be_nil
            ladron.save!
            expect(ladron.id).to_not be_nil
        end
    end

    describe 'encontrar por atributo' do
        it 'encontrar un ladron por su nombre' do
            nombre = "el gato"
            Ladron.new(nombre, 175, 90).save!
            resultado = Ladron.find_by_nombre(nombre).first
            expect(resultado.instance_variable_get(:@nombre)).to eq(nombre)
            expect(resultado.instance_variable_get(:@velocidad)).to eq(175)
            expect(resultado.instance_variable_get(:@sigilo)).to eq(90)
        end

        it 'encontrar por id' do
            ladri = Ladron.new("lucho", 175, 90)
            ladri.save!

            resultados = Ladron.find_by_id(ladri.id)
            expect(resultados.length).to be(1)

            resultado = resultados.first
            expect(resultado.id).to eq(ladri.id)
            expect(resultado.equal?(ladri)).to be true
        end
    end

    describe 'all instances' do
        it 'todas las instancias son efectivamente instancias' do
            Ladron.new("juan carlos chorro", 325, 67).save!
            Ladron.new("Motochorro", 900, 4).save!

            expect(Ladron.all_instances).to all be_instance_of Ladron
        end
    end


end