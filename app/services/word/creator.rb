class Word::Creator
  ERROR_STATUS = :error
  SUCCESS_STATUS = :success

  attr_accessor :words_texts, :result

  def initialize(words_params:)
    @result = Result.new
    @words_texts = words_params[:words_texts].split("\r\n")
  end

  def create_words
    downcase_words_texts
    words_texts.each do |text|
      word = insert_word_into_database(text)
      result.words_messages << generate_word_message(word)
      create_meanings(word) if word.persisted?
    end

    result
  end

  private

  def downcase_words_texts
    words_texts.map!(&:downcase)
  end

  def insert_word_into_database(text)
      word = Word.create(text:)

      word
  end

  def generate_word_message(word)
    if word.persisted?
      {
        text: "#{word.text} - Successfully created",
        status: SUCCESS_STATUS
      }
    else
      {
        text: "#{word.text} - #{word.errors.full_messages.join(', ')}",
        status: ERROR_STATUS
      }
    end
  end

  def create_meanings(word)
    Meaning::Parser.new(word:).parse_meanings
  end

  class Result
    attr_accessor :words_messages

    def initialize
      @words_messages = []
    end
  end
end
