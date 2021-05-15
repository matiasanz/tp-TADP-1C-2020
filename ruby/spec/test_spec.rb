describe Prueba do
  let(:prueba) { Prueba.new }

  describe '#materia' do
    it 'debería pasar este test' do
      expect(prueba.materia).to be :tadp
    end
  end

  describe 'test_punto_1' do

    it 'la definicion de has_one sobre un atributo persitible existente lo reescribe' do
      class Grade
        has_one String, named: :value # Hasta acá :value es un String
        has_one Numeric, named: :value # Pero ahora debe ser Numeric
      end

      expect(Grade.tipo_de(:value)).to eq Numeric
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
end

