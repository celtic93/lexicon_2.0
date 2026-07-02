class AnkiCard::Creator
  ANKI_ACTION = "addNote".freeze
  ANKI_BACK_FIELD = "Back".freeze
  ANKI_DECK_NAME = "Lexicon#{"_dev" if ENV["DB"].nil?}".freeze
  ANKI_MODEL_NAME = "Basic".freeze
  ANKI_URL = "http://localhost:8765/".freeze

  attr_accessor :meaning, :parsed_meaning, :response, :result

  def initialize(meaning_id:)
    @result = Result.new
    @meaning = Meaning.find(meaning_id)
    result.meaning = meaning
    @parsed_meaning = meaning.parsed_meaning
  end

  def create_card
    add_card_to_anki
    update_meaning
    generate_result_message

    result
  end

  private

  def add_card_to_anki
    tags = [ parsed_meaning["part_of_speech"], parsed_meaning["level"] ]
              .compact
              .map { |t| t.gsub(" ", "::") } # Anki separates multiword tags

    payload = {
      action: ANKI_ACTION,
      version: 6,
      params: {
        note: {
          deckName: ANKI_DECK_NAME,
          modelName: ANKI_MODEL_NAME,
          fields: {
            Front: generate_front,
            Back: generate_back
          },
          tags:
        }
      }
    }

    if parsed_meaning["audio_url"].present?
      filename = parsed_meaning["audio_url"].split("/").last
      payload[:params][:note][:audio] = [
        {
          url: parsed_meaning["audio_url"],
          filename:,
          fields: [ ANKI_BACK_FIELD ]
        }
      ]
    end

    @response = HTTParty.post(
      ANKI_URL,
      body: payload.to_json,
      headers: { "Content-Type" => "application/json" }
    )
  end

  def generate_front
    front_parts = []
    # meaning
    front_parts << "<b>#{parsed_meaning["meaning"]}</b>"

    if parsed_meaning["examples"].any?
      front_parts << "<br>"
    end

    # examples of usage, the word is replaced by three dots
    parsed_meaning["examples"].each do |example|
      front_parts << "<br>"
      front_parts << "<i>#{example.gsub(parsed_meaning["text"], "...")}</i>"
    end

    front_parts.join
  end

  def generate_back
    back_parts = []

    # examples of usage
    parsed_meaning["examples"].each do |example|
      back_parts << "<i>#{example}</i>"
      back_parts << "<br>"
    end

    if parsed_meaning["examples"].any?
      back_parts << "<br>"
    end

    # word
    back_parts << "<b>#{parsed_meaning["text"]}</b>"

    back_parts.join
  end

  def update_meaning
    meaning.update(
      anki_response: response,
      status: response_successful? ? :successful : :erroneous
    )
  end

  def response_successful?
    response["error"].nil?
  end

  def generate_result_message
    if response_successful?
      result.message = "Anki Card for \"#{meaning.text}\" created successfully"
    else
      result.message = "Anki Card for \"#{meaning.text}\" wasn't created. Error: #{response["error"]}"
    end
  end

  class Result
    attr_accessor :meaning, :message

    def initialize
      @message = nil
      @meaning = nil
    end

    def status
      meaning&.status
    end
  end
end
