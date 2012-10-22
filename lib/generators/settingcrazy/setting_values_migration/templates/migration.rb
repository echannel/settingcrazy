class CreateSettingsValues < ActiveRecord::Migration
  def self.up
    create_table :setting_values do |t|
      t.string :value
      t.string :key
      t.references :settable, :polymorphic => true
      t.timestamps
    end
  end

  def self.down
    drop_table :setting_values
  end
end
