require 'httparty'

module Http
  class GameClient
    Turn = Struct.new(:word_status, :game_over, :guesses_remaining)

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
      new_turn(payload)
    end

    private

    def new_turn(payload)
      turn = Turn.new
      turn.word_status = payload['word_status']
      turn.game_over = payload['game_over']
      turn.guesses_remaining = payload['guesses_remaining']

      turn
    end

    private

    attr_reader :game_id
  end
end
