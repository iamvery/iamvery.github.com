# Run this:
#
#    rspec fold.rb
#
def naive_foldl(operation, result, list)
  list.each do |item|
    result = operation.(result, item)
  end
  result
end

describe "folding" do
  let(:addition) { ->(a,b) { a+b } }

  it "returns the initial value when list is empty" do
    result = naive_foldl(addition, 0, [])
    expect(result).to eq(0)
  end

  it "sums list of numbers" do
    result = naive_foldl(addition, 0, [1,2,3])
    expect(result).to eq(6)
  end
end
