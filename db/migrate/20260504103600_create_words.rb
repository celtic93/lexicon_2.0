class CreateWords < ActiveRecord::Migration[8.1]
  def change
    create_table :words, comment: "Keeps English words" do |t|
      t.text :text, null: false, comment: "The Word itself"
      t.jsonb :parsed_definitions, comment: "The definitions of Word parsed from dictionary"

      t.timestamps
    end
  end
end
