describe Duck do
  it "speaks" do
    expect($stdout).to receive(:puts) { "*quack*" }
    Duck.new.speak
  end
end
