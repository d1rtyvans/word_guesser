require 'faker'

# TODO:
module Local
  class GameClient
    Turn = Struct.new(:word_status, :game_over, :guesses_remaining, :hit)

    GUESS_LIMIT = 15

    attr_reader :word, :word_status, :guesses_remaining, :previous_turn

    def initialize(word)
      @word = word
      @word_status = word.gsub(/./, '_')
      @guesses_remaining = GUESS_LIMIT.dup
    end

    def start
      new_turn
    end

    def new_guess(letter)
      letter = letter.downcase
      @guesses_remaining -= 1

      char_indexes = char_index_map[letter]
      if char_indexes.nil?
        return new_turn
      end

      char_indexes.each do |char_index|
        word_status[char_index] = letter
      end

      new_turn
    end

    private

    def char_index_map
      return @char_index_map if @char_index_map

      @char_index_map = {}
      word.chars.each_with_index do |char, i|
        @char_index_map[char] ||= []
        @char_index_map[char] << i
      end

      @char_index_map
    end

    def new_turn
      turn = Turn.new
      turn.word_status = word_status.dup
      turn.game_over = game_over?
      turn.guesses_remaining = guesses_remaining
      turn.hit = (previous_turn && previous_turn.word_status != word_status)

      @previous_turn = turn
    end

    def game_over?
      guesses_remaining < 1 || !word_status.include?('_')
    end
  end
end
