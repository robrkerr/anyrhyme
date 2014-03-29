class WordLexemeReader
  def self.read_lexemes filename
    id = 0
    word_lexemes = Hash.new { |h,k| h[k] = [] }
    full_types = self.load_full_types
    file = File.new(filename,"r")
    while (line = file.gets("\n"))
      next if line[%r/^\s/]
      split_line = line.split(" ")
      type = full_types[split_line[1].to_i]
      words = (0..(split_line[3].to_i - 1)).to_a.map { |i|
        split_line[4+2*i].gsub("_"," ")
      }
      gloss = line.split("|").last.strip
      words.each { |w| 
        if !w[/[^a-z]/]
          word_lexemes[w] << {:entry_id => id, :word_class => type[0], :gloss => gloss}
        end
      }
      id += 1
    end
    file.close
    word_lexemes
  end

  def self.read_word_relations filename
    word_relations = Hash.new { |h,k| h[k] = [] }
    file = File.new(filename,"r")
    while (line = file.gets("\n"))
      split_line = line.split(" ")
      related_word = split_line[0]
      word = split_line[1]
      next if related_word == word
      next if related_word[/[^a-z]/] || word[/[^a-z]/]
      word_relations[word] << related_word
    end
    file.close
    return word_relations
  end

  private

  def self.load_full_types
    full_types = []
    full_types << ["adj", "all", "all adjective clusters"]
    full_types << ["adj", "pert", "relational adjectives (pertainyms)"]
    full_types << ["adv", "all", "all adverbs"]
    full_types << ["noun", "Tops", "unique beginner for nouns"]
    full_types << ["noun", "act", "nouns denoting acts or actions"]
    full_types << ["noun", "animal", "nouns denoting animals"]
    full_types << ["noun", "artifact", "nouns denoting man-made objects"]
    full_types << ["noun", "attribute", "nouns denoting attributes of people and objects"]
    full_types << ["noun", "body", "nouns denoting body parts"]
    full_types << ["noun", "cognition", "nouns denoting cognitive processes and contents"]
    full_types << ["noun", "communication", "nouns denoting communicative processes and contents"]
    full_types << ["noun", "event", "nouns denoting natural events"]
    full_types << ["noun", "feeling", "nouns denoting feelings and emotions"]
    full_types << ["noun", "food", "nouns denoting foods and drinks"]
    full_types << ["noun", "group", "nouns denoting groupings of people or objects"]
    full_types << ["noun", "location", "nouns denoting spatial position"]
    full_types << ["noun", "motive", "nouns denoting goals"]
    full_types << ["noun", "object", "nouns denoting natural objects (not man-made)"]
    full_types << ["noun", "person", "nouns denoting people"]
    full_types << ["noun", "phenomenon", "nouns denoting natural phenomena"]
    full_types << ["noun", "plant", "nouns denoting plants"]
    full_types << ["noun", "possession", "nouns denoting possession and transfer of possession"]
    full_types << ["noun", "process", "nouns denoting natural processes"]
    full_types << ["noun", "quantity", "nouns denoting quantities and units of measure"]
    full_types << ["noun", "relation", "nouns denoting relations between people or things or ideas"]
    full_types << ["noun", "shape", "nouns denoting two and three dimensional shapes"]
    full_types << ["noun", "state", "nouns denoting stable states of affairs"]
    full_types << ["noun", "substance", "nouns denoting substances"]
    full_types << ["noun", "time", "nouns denoting time and temporal relations"]
    full_types << ["verb", "body", "verbs of grooming, dressing and bodily care"]
    full_types << ["verb", "change", "verbs of size, temperature change, intensifying, etc."]
    full_types << ["verb", "cognition", "verbs of thinking, judging, analyzing, doubting"]
    full_types << ["verb", "communication", "verbs of telling, asking, ordering, singing"]
    full_types << ["verb", "competition", "verbs of fighting, athletic activities"]
    full_types << ["verb", "consumption", "verbs of eating and drinking"]
    full_types << ["verb", "contact", "verbs of touching, hitting, tying, digging"]
    full_types << ["verb", "creation", "verbs of sewing, baking, painting, performing"]
    full_types << ["verb", "emotion", "verbs of feeling"]
    full_types << ["verb", "motion", "verbs of walking, flying, swimming"]
    full_types << ["verb", "perception", "verbs of seeing, hearing, feeling"]
    full_types << ["verb", "possession", "verbs of buying, selling, owning"]
    full_types << ["verb", "social", "verbs of political and social activities and events"]
    full_types << ["verb", "stative", "verbs of being, having, spatial relations"]
    full_types << ["verb", "weather", "verbs of raining, snowing, thawing, thundering"]
    full_types << ["adj", "ppl", "participial adjectives"]
    return full_types
  end
end
