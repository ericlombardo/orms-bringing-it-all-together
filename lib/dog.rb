class Dog
  attr_accessor :name, :breed, :id

  def initialize(id: nil, name:, breed:)  # id defaults to nil for reassignment in db
    self.name = name
    self.breed = breed
    self.id = id
  end

  def self.create_table
    query = <<-DOC
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    DOC
    DB[:conn].execute(query)
  end

  def self.drop_table
    query = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(query)
  end

  def save 
    if self.id == nil   # if instance hasn't been saved to db, does so
      query = "INSERT INTO dogs (name, breed) VALUES (?,?)"
      DB[:conn].execute(query, self.name, self.breed)
      
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]   # assigns db id to @id
      self #=> instance
    else
      self.update   # if saved, updates info in db
    end
  end

  def update
    query = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(query, self.name, self.breed, self.id)
  end

  def self.create(name:, breed:)  # creates new instance, saves to db
    self.new(name: name, breed: breed).save
  end

  def self.new_from_db(dog) # brings in row of info, makes new instance, doesn't save
    self.new(id: dog[0], name: dog[1], breed: dog[2])
  end

  def self.find_by_id(id) # search db for id, #=> instance
    query = "SELECT * FROM dogs WHERE id = ?"
    dog_info = DB[:conn].execute(query, id)[0]
    
    self.new_from_db(dog_info)
  end

  def self.find_or_create_by(name:, breed:) # search for name AND breed match
    query = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    response = DB[:conn].execute(query, name, breed) 
    
    if response.empty?  # creates new instance & saves if no match
      self.new(name: name, breed: breed).save
    else
      self.new_from_db(response[0]) # creates instance using info from db
    end
  end

  def self.find_by_name(name) # search db for name, ret inst if match, if not 
    query = "SELECT * FROM dogs WHERE name = ?"
    response = DB[:conn].execute(query, name) # find match in db
    
    self.new_from_db(response[0]) # create instance to display
  end
end