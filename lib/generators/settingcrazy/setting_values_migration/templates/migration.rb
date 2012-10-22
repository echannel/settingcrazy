class CreateSettingsValues < ActiveRecord::Migration
  def change
    create_table :setting_values do |t|
      t.string :value
      t.string :key
      t.references :settable, :polymorphic => true
      t.timestamps
    end
  end
end
