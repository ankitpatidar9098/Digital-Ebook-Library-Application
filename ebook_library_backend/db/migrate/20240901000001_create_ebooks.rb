class CreateEbooks < ActiveRecord::Migration[7.2]
  def change
    create_table :ebooks do |t|
      t.string  :title,         null: false
      t.string  :author
      t.string  :file_format,   null: false
      t.integer :file_size,     null: false, default: 0
      t.datetime :last_read_at
      t.integer  :read_position, default: 0
      t.string  :description

      t.timestamps
    end

    add_index :ebooks, :title
    add_index :ebooks, :author
    add_index :ebooks, :file_format
    add_index :ebooks, :created_at
  end
end
