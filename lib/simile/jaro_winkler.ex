defmodule Simile.JaroWinkler do
  @moduledoc """
  Jaro-Winkler similarity -- Jaro with a prefix bonus for strings that
  match from the beginning. Good for short strings and typo detection.

  The prefix bonus uses up to 4 characters and a default weight of 0.1.

  ## Examples

      iex> Simile.JaroWinkler.similarity("martha", "marhta")
      0.9611111111111111

      iex> Simile.JaroWinkler.similarity("DWAYNE", "DUANE")
      0.84
  """

  @default_prefix_weight 0.1

  @doc """
  Computes the Jaro-Winkler similarity between two strings.

  An optional third argument sets the prefix weight (default 0.1).
  The prefix bonus considers up to 4 matching prefix characters.

  ## Examples

      iex> Simile.JaroWinkler.similarity("martha", "marhta")
      0.9611111111111111

      iex> Simile.JaroWinkler.similarity("DWAYNE", "DUANE")
      0.84

      iex> Simile.JaroWinkler.similarity("abc", "abc")
      1.0

      iex> Simile.JaroWinkler.similarity("abc", "xyz")
      0.0
  """
  @spec similarity(String.t(), String.t(), float()) :: float()
  def similarity(a, b, prefix_weight \\ @default_prefix_weight) do
    jaro = Simile.Jaro.similarity(a, b)

    prefix_len =
      Enum.zip(String.graphemes(a), String.graphemes(b))
      |> Enum.take_while(fn {x, y} -> x == y end)
      |> length()
      |> min(4)

    jaro + prefix_len * prefix_weight * (1.0 - jaro)
  end
end
