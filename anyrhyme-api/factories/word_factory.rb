FactoryGirl.define {
  sequence(:numbered_words) { |n| "word#{n}" }
  factory(:word) {
    name {FactoryGirl.generate(:numbered_words) }
  }
}
