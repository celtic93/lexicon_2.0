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
    insert_words_into_database

    result
  end

  private

  def downcase_words_texts
    words_texts.map!(&:downcase)
  end

  def insert_words_into_database
    words_texts.each do |text|
      word = Word.create(text:)
      result.words_messages << generate_word_message(word)
    end
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

  class Result
    attr_accessor :words_messages

    def initialize
      @words_messages = []
    end
  end
end
