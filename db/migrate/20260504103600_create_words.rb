class CreateWords < ActiveRecord::Migration[8.1]
  def change
    create_table :words, comment: "Keeps English Words" do |t|
      t.text :text, null: false, comment: "The Word itself"
      t.jsonb :parsed_meanings, comment: "The meanings of Word parsed from dictionary"

      t.timestamps
    end
  end
end
