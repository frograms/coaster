ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string :type
    t.string :key
    t.string :name
    t.integer :age
    t.datetime :last_login
    t.text :data
    t.timestamps
  end

end
