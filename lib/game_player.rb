require 'httparty'
require 'ruby-dictionary'
require 'pry'


require_relative 'word_index'

# TODO: Pretty print turn
class Turn
  attr_reader :word_status, :guesses_remaining

  def initialize(game_over, word_status, guesses_remaining)
    @game_over = game_over
    @word_status = word_status
    @guesses_remaining = guesses_remaining
  end

  def game_over?
    @game_over
  end

  def won?
    !@word_status.include?('_')
  end
end

class HttpGameClient
  def start
    response = HTTParty.post('http://wordguess-interview.herokuapp.com/games')
    payload = JSON.parse(response.body)
    @game_id = payload['id']

    new_turn(payload)
  end

  def new_guess(letter)
    response = HTTParty.put(
      'http://wordguess-interview.herokuapp.com/games',
      body: {
        id: game_id,
        new_guess: letter
      }
    )

    payload = JSON.parse(response.body)
    puts "Guess: #{letter}"
    puts payload
    new_turn(JSON.parse(response.body))
  end

  private

  def new_turn(payload)
    Turn.new(
      payload['game_over'],
      payload['word_status'],
      payload['guesses_remaining']
    )
  end

  attr_reader :game_id, :last_response
end


class Player
  attr_reader :game, :strategy

  def initialize(game, strategy)
    @strategy = strategy
    @game = game
  end

  def play_game
    turn = game.start

    until turn.game_over?
      next_letter = strategy.next_letter!(turn.word_status)
      turn = game.new_guess(next_letter)
    end

    if turn.won?
      puts 'Congrats'
    else
      puts 'Srry'
    end
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

game = HttpGameClient.new

# word_index = WordIndex.new('words_alpha.txt.gz')
word_index = WordIndex.new('scrabble_words_2019.txt.gz')
strategy = WordIndexStrategy.new(word_index: word_index)

# strategy.choose_letter_set("ac_uain_ance")
player = Player.new(game, strategy)
player.play_game
