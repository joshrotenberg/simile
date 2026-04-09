defmodule Simile.Jaro do
  @moduledoc """
  Jaro similarity -- accounts for matching characters and transpositions.

  Returns a value between 0.0 (no similarity) and 1.0 (identical).
  Uses grapheme clusters for Unicode correctness.

  Note: Elixir's standard library provides `String.jaro_distance/2` which
  produces identical results. This module exists so that Simile offers a
  complete set of algorithms under one API, and as the foundation for
  `Simile.JaroWinkler`.

  ## Examples

      iex> Simile.Jaro.similarity("martha", "marhta")
      0.9444444444444445

      iex> Simile.Jaro.similarity("abc", "xyz")
      0.0
  """

  @doc """
  Computes the Jaro similarity between two strings.

  ## Examples

      iex> Simile.Jaro.similarity("martha", "marhta")
      0.9444444444444445

      iex> Simile.Jaro.similarity("DWAYNE", "DUANE")
      0.8222222222222223

      iex> Simile.Jaro.similarity("abc", "abc")
      1.0

      iex> Simile.Jaro.similarity("", "")
      1.0

      iex> Simile.Jaro.similarity("abc", "")
      0.0
  """
  @spec similarity(String.t(), String.t()) :: float()
  def similarity(a, a), do: 1.0
  def similarity("", _), do: 0.0
  def similarity(_, ""), do: 0.0

  def similarity(a, b) do
    a_chars = String.graphemes(a)
    b_chars = String.graphemes(b)
    a_len = length(a_chars)
    b_len = length(b_chars)

    match_window = max(div(max(a_len, b_len), 2) - 1, 0)

    {a_matches, b_matched} = find_matches(a_chars, b_chars, b_len, match_window)

    m = length(a_matches)

    if m == 0 do
      0.0
    else
      b_matches =
        b_matched
        |> Enum.sort()
        |> Enum.map(fn idx -> Enum.at(b_chars, idx) end)

      t =
        Enum.zip(a_matches, b_matches)
        |> Enum.count(fn {x, y} -> x != y end)
        |> div(2)

      (m / a_len + m / b_len + (m - t) / m) / 3.0
    end
  end

  defp find_matches(a_chars, b_chars, b_len, window) do
    a_chars
    |> Enum.with_index()
    |> Enum.reduce({[], []}, fn {a_char, i}, {a_matches, b_matched} ->
      low = max(0, i - window)
      high = min(b_len - 1, i + window)

      case find_first_match(b_chars, a_char, low, high, b_matched) do
        nil ->
          {a_matches, b_matched}

        j ->
          {a_matches ++ [a_char], b_matched ++ [j]}
      end
    end)
  end

  defp find_first_match(_b_chars, _a_char, low, high, _b_matched) when low > high, do: nil

  defp find_first_match(b_chars, a_char, low, high, b_matched) do
    low..high//1
    |> Enum.find(fn j ->
      Enum.at(b_chars, j) == a_char and j not in b_matched
    end)
  end
end
