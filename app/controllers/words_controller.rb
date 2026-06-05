class WordsController < ApplicationController
  add_flash_types :words_messages

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
