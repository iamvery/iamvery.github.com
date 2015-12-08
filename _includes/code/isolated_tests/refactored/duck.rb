class Duck
  attr_reader :voice

  def initialize(voice: Quack.new)
    @voice = voice
  end

  def speak
    voice.utter
  end
end

describe Duck do
  it "speaks" do
    quack = double
    duck = Duck.new(voice: quack)
    expect(quack).to receive(:utter)
    duck.speak
  end
end
