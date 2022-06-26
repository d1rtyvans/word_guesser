require 'zlib'

module WordSources
  class GzippedTxt
    attr_reader :filepath

    def initialize(filepath)
      @filepath = filepath
    end

    def each
      file = File.open(filepath)
      reader = Zlib::GzipReader.new(file)

      reader.each_line do |line|
        word = line.chomp
        word.downcase!

        yield word
      end
    end
  end
end
