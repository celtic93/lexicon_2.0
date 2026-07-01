class MeaningsController < ApplicationController
  def update
    @meaning = Meaning.find(params[:id])
    @meaning.update(meaning_params)

    redirect_to word_path(@meaning.word_id), notice: "Meaning status was updated."
  end

  private

  def meaning_params
    params.require(:meaning).permit(:status)
  end
end
