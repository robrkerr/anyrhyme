class PhonemeLoader

  def self.get_phoneme_data
    phonemes.map { |name,type|
      {:name => name, :phoneme_type => type}
    }
  end

  def self.phonemes_hash
    Hash[phonemes]
  end

  private

  def self.phonemes
    [["aa", "vowel"],
      ["ae", "vowel"],
      ["ah", "vowel"],
      ["ao", "vowel"],
      ["aw", "vowel"],
      ["ay", "vowel"],
      ["b",  "stop"],
      ["ch", "affricate"],
      ["d",  "stop"],
      ["dh", "fricative"],
      ["eh", "vowel"],
      ["er", "vowel"],
      ["ey", "vowel"],
      ["f",  "fricative"],
      ["g",  "stop"],
      ["hh", "aspirate"],
      ["ih", "vowel"],
      ["iy", "vowel"],
      ["jh", "affricate"],
      ["k",  "stop"],
      ["l",  "liquid"],
      ["m",  "nasal"],
      ["n",  "nasal"],
      ["ng", "nasal"],
      ["ow", "vowel"],
      ["oy", "vowel"],
      ["p",  "stop"],
      ["r",  "liquid"],
      ["s",  "fricative"],
      ["sh", "fricative"],
      ["t",  "stop"],
      ["th", "fricative"],
      ["uh", "vowel"],
      ["uw", "vowel"],
      ["v",  "fricative"],
      ["w",  "semivowel"],
      ["y",  "semivowel"],
      ["z",  "fricative"],
      ["zh", "fricative"]]
    end
end