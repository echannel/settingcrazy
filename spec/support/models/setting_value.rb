
ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS 'setting_values'")
ActiveRecord::Base.connection.create_table(:setting_values) do |t|
  t.string :key
  t.string :value
  t.references :settable, :polymorphic => true
end
