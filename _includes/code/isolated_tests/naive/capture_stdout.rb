describe Duck do
  require "stringio"
  def capture_stdout
    stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = stdout
  end

  it "speaks" do
    output = capture_stdout { Duck.new.speak }
    expect(output.chomp).to eq("*quack*")
  end
end
