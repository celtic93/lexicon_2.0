require "open-uri"

class Meaning::Parser
  BASE_URL = "https://dictionary.cambridge.org".freeze
  DICTIONARY_URL = "https://dictionary.cambridge.org/dictionary/english-russian/".freeze

  attr_accessor :meanings_array, :word, :result

  def initialize(word:)
    @result = Result.new
    @word = word
    @meanings_array = []
  end

  def parse_meanings
    parse_word_page
    add_meanings_array_to_word
    create_meanings

    result.meanings_count = meanings_array.count
    result
  end

  private

  def parse_word_page
    url_page = word.text.split(" ").join("-")
    html = URI.open(DICTIONARY_URL + url_page).read
    doc = Nokogiri::HTML(html)

    # 1. Ищем все определения на странице
    doc.css(".def").each do |def_tag|
      meaning_text = def_tag.text.strip

      # Находим родительский блок .dsense
      sense_block = def_tag.ancestors.find { |node| node["class"]&.include?("dsense") }
      sense_block ||= def_tag.parent

      # 2. Умный поиск контейнера части речи
      pos_container = def_tag.parent
      while pos_container && pos_container.name != "body"
        if pos_container.at_css(".pos")
          break
        end
        pos_container = pos_container.parent
      end

      # 3. Извлекаем Часть речи
      part_of_speech = nil
      if pos_container
        pos_node = pos_container.at_css(".pos") || pos_container.at_css(".dpos")
        part_of_speech = pos_node&.text&.strip
      end

      # 4. Извлекаем Аудио и формируем полную ссылку
      audio_url = nil

      if pos_container
        audio_node = pos_container.at_css(".uk .daud source")
        if audio_node
          relative_url = audio_node["src"] || audio_node["data-src-mp3"]
          audio_url = relative_url&.start_with?("/") ? "#{BASE_URL}#{relative_url}" : relative_url
        else
          # Фолбэк на глобальное аудио
          audio_node = doc.at_css(".uk .daud source")
          if audio_node
            relative_url = audio_node["src"] || audio_node["data-src-mp3"]
            audio_url = relative_url&.start_with?("/") ? "#{BASE_URL}#{relative_url}" : relative_url
          end
        end
      end

      # 5. Примеры
      examples = sense_block ? sense_block.css(".examp").map { |ex| ex.text.strip.gsub(/\s+/, " ") } : []

      # 6. Перевод
      translation = sense_block&.at_css(".trans")&.text&.strip

      # 7. Извлекаем Слово или Фразу (Headword/Phrase)
      word_text = nil

      # Сначала ищем специфическую фразу внутри текущего блока определения (.dsense)
      # Добавляем классы .dphrase-title и .phrase-title
      if sense_block
        phrase_node = sense_block.at_css(".dphrase-title") || sense_block.at_css(".phrase-title")
        word_text = phrase_node&.text&.strip
      end

      # Если фраза внутри .dsense не найдена (значит это обычное определение), ищем глобальное слово
      if word_text.nil?
        # Ищем ближайшего предка, который содержит класс .headword
        parent_with_headword = sense_block.ancestors.find { |node| node.at_css(".headword") }

        if parent_with_headword
          word_text = parent_with_headword.at_css(".headword")&.text&.strip
        end
      end

      # 8. Уровень слова (Level)
      level = nil
      level_node = sense_block&.at_css(".epp-xref") || sense_block&.at_css(".dxref")

      if level_node
        level = level_node.at_css(".cc")&.text&.strip || level_node.text.strip
      end

      if level.nil? && pos_container
        level_node = pos_container.at_css(".epp-xref") || pos_container.at_css(".dxref")
        level = level_node&.text&.strip
      end

      meanings_array << {
        text: word_text.downcase,
        meaning: meaning_text,
        translation: translation,
        audio_url: audio_url,
        examples: examples,
        part_of_speech: part_of_speech,
        level: level
      }
    end
  end

  def add_meanings_array_to_word
    Word.update(parsed_meanings: meanings_array)
  end

  def create_meanings
    meanings_array.each do |meaning_hash|
      Meaning::Creator.new(meaning_hash:, word_id: word.id).create_meaning
    end
  end

  class Result
    attr_accessor :meanings_count

    def initialize
      @meanings_count = nil
    end
  end
end
