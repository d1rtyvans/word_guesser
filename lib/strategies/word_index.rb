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
module Strategies
  class WordIndex
    attr_reader :word_source_path, :word_index, :all_words

    def initialize(word_source_path)
      @word_source_path = word_source_path
      @all_words = Set.new
    end

    def letter_set(word_status)
      @word_index ||= build_word_index(word_status.length)

      if word_status.chars.all?('_')
        words = all_words
      else
        word_sets = words_matching_char_positions(word_status)
        words = words_present_in_every_set(word_sets)
      end

      # TODO: Cache this, or just keep calculating it?
      # TODO: HOW TO BE GREEDY OR USE DYNAMIC PROGRAMMING?
      # Get diff of chars from word_status
      unordered_chars = all_possible_chars(words, word_status)
      sorted_set = frequency_sorted_char_set(unordered_chars).uniq

      sorted_set
    end

    def words_matching_char_positions(word_status)
      word_sets = []

      word_status.chars.each_with_index do |char, i|
        next if char == '_'

        word_sets << word_index[i][char]
      end

      word_sets
    end

    def words_present_in_every_set(word_sets)
      # Count occurences of words in each char index subarray
      counts_by_word = {}
      word_sets.each do |word_set|
        word_set.keys.each do |word|
          counts_by_word[word] ||= 0
          counts_by_word[word] += 1
        end
      end

      # Select words with counts == word_sets length (meaning they matched at every char index)
      words = []
      counts_by_word.each do |word, count|
        next unless count == word_sets.length

        words << word
      end

      words
    end

    def all_possible_chars(words, word_status)
      words.map(&:chars).flatten - word_status.tr('_', '').chars
    end

    private

    def frequency_sorted_char_set(chars)
      counts = chars.inject(Hash.new(0)) do |counter, char|
        counter[char] += 1
        counter
      end

      counts.to_a.sort { |a, b| b[1] <=> a[1] }.map(&:first)
    end

    # ~0.4 seconds
    def build_word_index(word_length)
      started = Time.now

      index = {}
      # TODO: Benchmark without gzip
      file = File.open(word_source_path)
      reader = Zlib::GzipReader.new(file)

      puts "Building index from '#{word_source_path}'"
      reader.each_line do |line|
        word = line.chomp
        word.downcase!

        next if word.length != word_length

        all_words.add(word)
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
end
