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

  # return true if an incorrect guess has been made
  def miss?
    return false if @turn.hit.nil?

    !@turn.hit
  end

  def over?
    @turn.game_over
  end

  def winner?
    !word_status.include?('_')
  end
end
