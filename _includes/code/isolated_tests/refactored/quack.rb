class Quack
  attr_reader :io

  def initialize(io: STDOUT)
    @io = io
  end

  def utter
    io.puts "*quack*"
  end
end

require "stringio"

describe Quack do
  it "quacks" do
    io = StringIO.new
    quack = Quack.new(io: io)
    quack.utter
    expect(io.string.chomp).to eq("*quack*")
  end
end
