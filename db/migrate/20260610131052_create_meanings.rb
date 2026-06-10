class CreateMeanings < ActiveRecord::Migration[8.1]
  def change
    create_table :meanings, comment: "Keeps the Meanings of corresponding Words" do |t|
      t.text :text, null: false, comment: "The Meaning itself"
      t.jsonb :parsed_meaning, comment: "The meaning of Word parsed from dictionary"
      t.jsonb :anki_response, comment: "The Anki Response"
      t.text :status, null: false, comment: "Status of creating of Anki card"
      t.references :word, null: false, foreign_key: true, comment: "Belongs to Word"

      t.timestamps
    end
  end
end
