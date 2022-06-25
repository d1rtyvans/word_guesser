require 'httparty'
require 'ruby-dictionary'
require 'pry'


require_relative 'word_index'

class GameClient
  def self.start_game
    response = HTTParty.post('http://wordguess-interview.herokuapp.com/games')
    JSON.parse(response.body)
  end

  def self.new_guess(id, letter)
    response = HTTParty.put(
      'http://wordguess-interview.herokuapp.com/games',
      body: {
        id: id,
        new_guess: letter
      }
    )

    JSON.parse(response.body)
  end
end

class Game
  attr_reader :client, :game_id, :last_response

  def initialize(client)
    @client = client
  end

  def start
    response = client.start_game
    @game_id = response['id']
    puts "Game ##{game_id} started."
    @last_response = response
  end

  def new_guess(letter)
    puts "Guess: #{letter}"
    response = client.new_guess(game_id, letter)
    puts response
    @last_response = response
  end

  def game_over?
    last_response['game_over']
  end

  def won?
    !last_response['word_status'].include?('_')
  end

  def word_status
    last_response['word_status']
  end

  def last_response
    @last_response || {}
  end
end


class Player
  attr_reader :game, :strategy

  def initialize(game, strategy)
    @strategy = strategy
    @game = game
  end

  def play_game
    game.start

    until game.game_over?
      next_letter = strategy.next_letter!(game.word_status)
      game.new_guess(next_letter)
    end

    if game.won?
      puts 'Congrats'
    else
      puts 'Srry'
    end
  end
end

class BaseStrategy
  attr_reader :vowels, :consonants

  def initialize(indexer: nil)
    @vowels = %w[a e i o u]
    @consonants = ('a'..'z').to_a - @vowels
    @indexer = indexer
  end

  def next_letter!(word_status)
    letter_set = choose_letter_set(word_status)
    letter_set.delete_at(rand(letter_set.length))
  end

  def choose_letter_set(_word_status)
    raise 'Must implement `choose_letter_set`'
  end
end

class VowelsFirstStrategy < BaseStrategy
  def choose_letter_set(_word_status)
    if vowels.any?
      return vowels
    end

    consonants
  end
end

class LimitedVowelsFirstStrategy < BaseStrategy
  VOWEL_LIMIT = 2

  def choose_letter_set(_word_status)
    @used_vowel_count ||= 0

    if @used_vowel_count >= VOWEL_LIMIT
      return vowels + consonants
    end

    if vowels.any?
      @used_vowel_count += 1
      return vowels
    end

    consonants
  end
end

class WordIndexStrategy
  VOWEL_LIMIT = 2

  attr_reader :vowels, :consonants, :word_index

  def initialize(word_index:)
    @vowels = %w[a e i o u]
    @consonants = ('a'..'z').to_a - @vowels
    @used_vowel_count = 0
    @used_letters = Set.new
    @word_index = word_index
  end

  def next_letter!(word_status)
    letter_set = choose_letter_set(word_status)
    unused_letters = letter_set - @used_letters.to_a

    letter = unused_letters[rand(unused_letters.length)]
    @used_letters.add(letter)

    letter
  end

  def choose_letter_set(word_status)
    if use_word_index?(word_status)
      return word_index.letter_set(word_status)
    end

    # TODO: Make this strategy smarter. Mix the set once you get a single vowel
    # CHECK MATCHED VOWEL INSTEAD OF USED
    if @used_vowel_count >= VOWEL_LIMIT
      return vowels + consonants
    end

    if vowels.any?
      @used_vowel_count += 1
      return vowels
    end

    consonants
  end

  def use_word_index?(word_status)
    @use_word_index ||= word_status.count('_') < word_status.length
  end
end

# TODO: LETTER SCORE

game = Game.new(GameClient)

# word_index = WordIndex.new('words_alpha.txt.gz')
word_index = WordIndex.new('scrabble_words_2019.txt.gz')
strategy = WordIndexStrategy.new(word_index: word_index)

# strategy.choose_letter_set("ac_uain_ance")
player = Player.new(game, strategy)
player.play_game
