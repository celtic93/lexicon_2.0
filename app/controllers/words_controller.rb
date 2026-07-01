class WordsController < ApplicationController
  add_flash_types :words_messages

  def index
    @words = Word.all

    if params[:meaning_status] == "pending"
      @words = @words.with_pending_meanings
    end
  end

  def new; end

  def create
    @result = Word::Creator.new(words_params:).create_words

    redirect_to new_word_path, words_messages: @result.words_messages
  end

  private

  def words_params
    params.fetch(:words, {}).permit(:words_texts)
  end
end
