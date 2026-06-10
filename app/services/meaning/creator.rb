class Meaning::Creator
  ANKI_ACTION = "addNote".freeze
  ANKI_BACK_FIELD = "Back".freeze
  ANKI_DECK_NAME = "Lexicon".freeze
  ANKI_MODEL_NAME = "Basic".freeze
  ANKI_URL = "http://localhost:8765/".freeze

  attr_accessor :meaning, :meaning_hash, :response, :result, :word_id

  def initialize(meaning_hash:, word_id:)
    @result = Result.new
    @meaning = nil
    @meaning_hash = meaning_hash
    @word_id = word_id
  end

  def create_meaning
    create_anki_card
    insert_meaning_into_database

    result.status = @meaning.status
    result
  end

  private

  def create_anki_card
    tags = [ meaning_hash[:part_of_speech], meaning_hash[:level] ]
              .compact
              .map { |t| t.gsub(" ", "::") } # Anki separates multiword tags
    filename = meaning_hash[:audio_url].split("/").last

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
          tags:,
          audio: [
            {
              url: meaning_hash[:audio_url],
              filename:,
              fields: [ ANKI_BACK_FIELD ]
            }
          ]
        }
      }
    }

    @response = HTTParty.post(
      ANKI_URL,
      body: payload.to_json,
      headers: { "Content-Type" => "application/json" }
    )
  end

  def generate_front
    front_parts = []
    # meaning
    front_parts << "<b>#{meaning_hash[:meaning]}</b>"

    if meaning_hash[:examples].any?
      front_parts << "<br>"
    end

    # examples of usage, the word is replaced by three dots
    meaning_hash[:examples].each do |example|
      front_parts << "<br>"
      front_parts << "<i>#{example.sub(meaning_hash[:text], "...")}</i>"
    end

    front_parts.join
  end

  def generate_back
    back_parts = []

    # examples of usage
    meaning_hash[:examples].each do |example|
      back_parts << "<i>#{example}</i>"
      back_parts << "<br>"
    end

    if meaning_hash[:examples].any?
      back_parts << "<br>"
    end

    # translation
    back_parts << "<p>#{meaning_hash[:translation]}</p>"

    # word
    back_parts << "<b>#{meaning_hash[:text]}</b>"

    back_parts.join
  end

  def insert_meaning_into_database
    @meaning = Meaning.create(
      text: meaning_hash[:meaning],
      word_id:,
      parsed_meaning: meaning_hash,
      anki_response: response,
      status: response_successful? ? :successful : :erroneous
    )

    pp @meaning.errors.full_messages
    log_status
  end

  def response_successful?
    response["error"].nil?
  end

  def log_status
    if response_successful?
      Rails.logger.info("\e[32mMeaning id: #{@meaning.id}\e[0m")
    else
      Rails.logger.info("\e[31mMeaning id: #{@meaning.id}, error: #{response["error"]}\e[0m")
    end
  end

  class Result
    attr_accessor :status

    def initialize
      @status = nil
    end
  end
end
