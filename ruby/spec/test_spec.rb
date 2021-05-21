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
        include ObjetoPersistible
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
      puts Person.atributos_persistibles
      puts p.obtener_hash_para_insertar
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
      p.forget!
      expect(p.atributos_persistidos).to eq nil
      expect(p.id).to eq nil
    end
  end

end

