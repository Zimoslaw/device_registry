class CreateUserDevices < ActiveRecord::Migration[7.1]
  def change
    create_table :user_devices do |t|
      t.integer :user_id
      t.string :device_serial_number
      t.boolean :active

      t.timestamps
    end

    add_index :user_devices, [:user_id, :device_serial_number], unique: true
  end
end
