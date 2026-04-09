defmodule Simile.Ngram do
  @moduledoc """
  N-gram distance -- configurable n-gram overlap distance.

  Returns a value between 0.0 (identical n-gram sets) and 1.0 (no overlap).

  ## Examples

      iex> Simile.Ngram.distance("night", "night", 2)
      0.0

      iex> Simile.Ngram.distance("abc", "xyz", 2)
      1.0
  """

  @doc """
  Computes the n-gram distance between two strings.

  The `n` parameter controls the size of the n-grams.

  ## Examples

      iex> Simile.Ngram.distance("night", "night", 2)
      0.0

      iex> Simile.Ngram.distance("abc", "xyz", 2)
      1.0

      iex> Simile.Ngram.distance("", "", 2)
      0.0

      iex> Simile.Ngram.distance("abc", "", 2)
      1.0

      iex> Simile.Ngram.distance("abcde", "abcdf", 3)
      0.5
  """
  @spec distance(String.t(), String.t(), pos_integer()) :: float()
  def distance("", "", _n), do: 0.0
  def distance("", _b, _n), do: 1.0
  def distance(_a, "", _n), do: 1.0

  def distance(a, b, n) when n >= 1 do
    a_ngrams = ngrams(a, n)
    b_ngrams = ngrams(b, n)

    intersection =
      Enum.reduce(a_ngrams, 0, fn {ngram, count}, acc ->
        acc + min(count, Map.get(b_ngrams, ngram, 0))
      end)

    a_total = a_ngrams |> Map.values() |> Enum.sum()
    b_total = b_ngrams |> Map.values() |> Enum.sum()
    total = a_total + b_total

    if total == 0 do
      0.0
    else
      1.0 - 2.0 * intersection / total
    end
  end

  defp ngrams(str, n) do
    str
    |> String.codepoints()
    |> Enum.chunk_every(n, 1, :discard)
    |> Enum.map(&Enum.join/1)
    |> Enum.frequencies()
  end
end
