class AnkiCardsController < ApplicationController
  def create
    @result = AnkiCard::Creator.new(meaning_id: params[:meaning_id]).create_card

    redirect_to word_path(@result.meaning.word_id), flash_message(@result)
  end

  private

  def flash_message(result)
    if result.status == :successful
      { notice: result.message }
    else
      { alert: result.message }
    end
  end
end
