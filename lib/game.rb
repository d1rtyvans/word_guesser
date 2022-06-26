class Game
  attr_reader :client, :turn

  def initialize(client)
    @client = client
  end

  def start
    p @turn = client.start
  end

  def new_guess(letter)
    puts "Guess: #{letter}"
    p @turn = client.new_guess(letter)
  end

  def word_status
    @turn.word_status
  end

  def over?
    @turn.game_over
  end

  def winner?
    !word_status.include?('_')
  end
end
