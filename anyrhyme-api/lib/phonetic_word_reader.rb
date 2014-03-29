class PhoneticWordReader
  def self.read_words filename
    words = []
    file = File.new(filename,"r")
    while (line = file.gets)
      line.downcase!
      next unless line[%r/^[a-z]/]
      line = line.chomp.split(" ")
      word = line[0].sub(%r/\((.*?)\)/,"")
      next if word[%r/[0-9]/]
      phonemes = line[1..-1]
      words << {:name => word, :phonemes => phonemes}
    end
    file.close
    words
  end
end
