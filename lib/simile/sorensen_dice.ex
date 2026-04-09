defmodule Simile.SorensenDice do
  @moduledoc """
  Sorensen-Dice coefficient -- bigram overlap similarity, 0.0 to 1.0.

  Measures how many bigrams the two strings share. Strings shorter than
  2 characters always return 0.0 since no bigrams can be formed.

  ## Examples

      iex> Simile.SorensenDice.coefficient("night", "nacht")
      0.25

      iex> Simile.SorensenDice.coefficient("night", "night")
      1.0
  """

  @doc """
  Computes the Sorensen-Dice coefficient between two strings.

  ## Examples

      iex> Simile.SorensenDice.coefficient("night", "nacht")
      0.25

      iex> Simile.SorensenDice.coefficient("night", "night")
      1.0

      iex> Simile.SorensenDice.coefficient("a", "b")
      0.0

      iex> Simile.SorensenDice.coefficient("abc", "xyz")
      0.0

      iex> Simile.SorensenDice.coefficient("healed", "sealed")
      0.8
  """
  @spec coefficient(String.t(), String.t()) :: float()
  def coefficient(a, a) when byte_size(a) > 0, do: 1.0
  def coefficient(a, _) when byte_size(a) < 2, do: 0.0
  def coefficient(_, b) when byte_size(b) < 2, do: 0.0

  def coefficient(a, b) do
    a_bigrams = bigrams(a)
    b_bigrams = bigrams(b)

    intersection = count_intersection(a_bigrams, b_bigrams)

    a_total = a_bigrams |> Map.values() |> Enum.sum()
    b_total = b_bigrams |> Map.values() |> Enum.sum()

    2.0 * intersection / (a_total + b_total)
  end

  defp bigrams(str) do
    str
    |> String.codepoints()
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(&Enum.join/1)
    |> Enum.frequencies()
  end

  defp count_intersection(a, b) do
    Enum.reduce(a, 0, fn {bigram, count}, acc ->
      acc + min(count, Map.get(b, bigram, 0))
    end)
  end
end
