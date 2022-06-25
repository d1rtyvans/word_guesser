require 'pry'
require 'set'
require 'zlib'

# NOTE: word sources
#
# Scrabble words
# https://boardgames.stackexchange.com/questions/38366/latest-collins-scrabble-words-list-in-text-file
#
# All English words
# https://github.com/dwyl/english-words

# Requires gzipped txt file with single word per line as input
class Indexer
  attr_reader :dictionary_filepath, :word_index

  def initialize(dictionary_filepath)
    @dictionary_filepath = dictionary_filepath
    @word_index = {}
  end

  # 15 seconds
  def build(word_length:)
    started = Time.now

    # TODO: Benchmark without gzip
    file = File.open(dictionary_filepath)
    reader = Zlib::GzipReader.new(file)

    puts "Building index from '#{dictionary_filepath}'"
    reader.each_line do |line|
      word = line.chomp.downcase!
      next if word.length != word_length

      word.chars.each_with_index do |char, index|
        word_index[index] ||= {}
        word_index[index][char] ||= {}

        word_index[index][char][word] = true
      end

    end

    puts "Index built in: #{Time.now - started} seconds."
    word_index
  end
end

indexer = Indexer.new('scrabble_words_2019.txt.gz')
result = indexer.build(word_length: 6)

# binding.pry

# puts 'hi'
