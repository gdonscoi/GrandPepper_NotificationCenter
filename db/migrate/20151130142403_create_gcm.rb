class CreateGcm < ActiveRecord::Migration
  def up
    create_table :gcms do |t|
      t.column :registration, :text
    end
  end

  def down
    drop_table :gcms
  end
end
