class Player
  attr_reader :game, :strategy, :used_letters

  def initialize(game, strategy)
    @strategy = strategy
    @game = game
    @used_letters = Set.new
  end

  def play_game
    game.start

    until game.over?
      game.new_guess(next_letter)
    end

    print_result(game.winner?)
  end

  private

  def print_result(winner)
    puts
    puts '-------------'

    if winner
      puts 'You won!'
    else
      puts 'Better luck next time.'
    end

    puts '-------------'
  end

  def next_letter
    first_unused_letter(
      strategy.letter_set(game.word_status)
    )
  end

  def first_unused_letter(letter_set)
    letter_set.each do |letter|
      next if used_letters.include?(letter)

      @used_letters.add(letter)
      return letter
    end
  end
end
