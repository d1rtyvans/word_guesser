require 'pry'

require_relative 'game'
require_relative 'player'
require_relative 'local/game_client'
require_relative 'http/game_client'

require_relative 'word_sources/gzipped_txt'
require_relative 'strategies/word_index'


client = Http::GameClient.new
# client = Local::GameClient.new('frazzle')
game = Game.new(client)

# source_path = 'word_sources/words_alpha.txt.gz'
source_path = 'word_sources/scrabble_words_2019.txt.gz'
word_source = WordSources::GzippedTxt.new(source_path)

strategy = Strategies::WordIndex.new(word_source)
player = Player.new(game, strategy)

player.play_game
