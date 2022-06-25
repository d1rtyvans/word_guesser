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
class WordIndex
  attr_reader :dictionary_filepath, :word_index

  def initialize(dictionary_filepath)
    @dictionary_filepath = dictionary_filepath
  end

  # TODO: Handle when no words or letters found. Fall back on old strategy
  def letter_set(word_status)
    @word_index ||= build_word_index(word_status.length)

    # TODO: Benchmark
    # FIXME: This algo is gross can prob be cleaned up

    word_sets = words_matching_char_positions(word_status)
    words = words_matching_all_chars_at_every_position(word_sets)

    # TODO: Cache this, or just keep calculating it?
    # TODO: HOW TO BE GREEDY OR USE DYNAMIC PROGRAMMING?
    # Get diff of chars from word_status
    build_letter_set(words, word_status)
  end

  def words_matching_char_positions(word_status)
    word_sets = []

    word_status.chars.each_with_index do |char, i|
      next if char == '_'

      begin
        word_sets << word_index[i][char]
      rescue => e
        puts char
        puts i
        # TODO: Handle
      end
    end

    word_sets
  end

  def words_matching_all_chars_at_every_position(word_sets)
    # Count occurences of words matchin a letter at a given index
    counts_by_word = {}
    word_sets.each do |word_set|
      word_set.keys.each do |word|
        counts_by_word[word] ||= 0
        counts_by_word[word] += 1
      end
    end

    # Select words with counts == word_sets length (meaning they matched at every char index)
    # TODO: Weight the characters based on frequency
    words = []
    counts_by_word.each do |word, count|
      next unless count == word_sets.length

      words << word
    end

    words
  end

  def build_letter_set(words, word_status)
    words.map(&:chars).flatten - word_status.tr('_', '').chars
  end

  private

  # ~0.4 seconds
  def build_word_index(word_length)
    started = Time.now

    index = {}
    # TODO: Benchmark without gzip
    file = File.open(dictionary_filepath)
    reader = Zlib::GzipReader.new(file)

    puts "Building index from '#{dictionary_filepath}'"
    reader.each_line do |line|
      word = line.chomp
      word.downcase!

      next if word.length != word_length

      word.chars.each_with_index do |char, i|
        index[i] ||= {}
        index[i][char] ||= {}

        index[i][char][word] = true
      end

    end

    puts "Index built in: #{Time.now - started} seconds."
    index
  end
end

# indexer = Indexer.new('scrabble_words_2019.txt.gz')
# result = indexer.letter_set('f_n_____c')
