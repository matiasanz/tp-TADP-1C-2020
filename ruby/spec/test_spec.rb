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
      puts p.save!
      puts p.last_name
      puts Person.table
      puts Person.id
      puts Person.att
      puts Person.obtener_hash_para_insertar

      class Grade
        attr_accessor :value
        has_one String, named: :value # Hasta acá :value es un String
        has_one Numeric, named: :value # Pero ahora debe ser Numeric
      end
      p = Grade.new
      p.value = 2
      p.save!
      puts Grade.obtener_hash_para_insertar

      Person.name
    end
  end
end

