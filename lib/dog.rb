require 'pry'

class Dog

    attr_accessor :name, :breed, :id

    def initialize(params)
        @name = params[:name]
        @breed = params[:breed]
        @id = params[:id]
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end

    def self.new_from_db(row)
        Dog.new({name: row[1], breed: row[2], id: row[0]})
    end

    def save
        if self.id
            self.update
        else
            sql = <<-SQL
                INSERT INTO dogs (name, breed)
                VALUES (?, ?)
            SQL
            DB[:conn].execute(sql,self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            self
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE dogs.name = ?
        SQL
        self.new_from_db(DB[:conn].execute(sql, name).first)
        # binding.pry
    end

    def self.create(params)
        self.new(params).save
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE dogs.id = ?
        SQL

        self.new_from_db(DB[:conn].execute(sql, id).first)
    end

    def update
        sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ?
            WHERE id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ? AND breed = ?
        SQL
        row = DB[:conn].execute(sql, name, breed)

        if row.empty?
            dog = self.create({:name => name, :breed => breed})
        else
            dog = Dog.new(row[0][1], row[0][2], row[0][0])
        end
        dog
    end
    # binding.pry
end #end Dog Class
# binding.pry