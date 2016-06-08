defmodule Folds do
  def foldl([], result, _operation), do: result
  def foldl([head|tail], initial, operation) do
    foldl(tail, operation.(initial, head), operation)
  end
end

ExUnit.start

defmodule FoldTest do
  use ExUnit.Case
  import Folds

  def map_double(l, n), do: l ++ [n*2]

  test "fold left of empty list" do
    assert foldl([], [], &map_double/2) == []
  end

  test "fold left doubling elements" do
    assert foldl([1,2,3], [], &map_double/2) == [2,4,6]
  end
end
