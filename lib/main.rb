require 'pry'

require_relative 'game'
require_relative 'player'
require_relative 'local/game_client'
require_relative 'http/game_client'
require_relative 'strategies/word_index'


client = Http::GameClient.new
# client = Local::GameClient.new('abs')
game = Game.new(client)

# word_source = 'word_sources/words_alpha.txt.gz'
word_source = 'word_sources/scrabble_words_2019.txt.gz'

strategy = Strategies::WordIndex.new(word_source)
player = Player.new(game, strategy)

player.play_game
