class CreateLevels < ActiveRecord::Migration[7.2]
  def change
    create_table :levels do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :xp
      t.integer :level

      t.timestamps
    end
  end
end
