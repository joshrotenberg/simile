defmodule Simile.DamerauLevenshtein do
  @moduledoc """
  Full Damerau-Levenshtein distance -- minimum edits (insert, delete, substitute,
  transpose) with no restriction on substrings being edited more than once.

  This is the unrestricted variant. For the restricted version (OSA), see
  `Simile.OSA`.

  ## Examples

      iex> Simile.DamerauLevenshtein.distance("abc", "bac")
      1

      iex> Simile.DamerauLevenshtein.distance("CA", "ABC")
      2
  """

  @doc """
  Computes the full Damerau-Levenshtein distance between two strings.

  ## Examples

      iex> Simile.DamerauLevenshtein.distance("abc", "bac")
      1

      iex> Simile.DamerauLevenshtein.distance("abcd", "badc")
      2

      iex> Simile.DamerauLevenshtein.distance("CA", "ABC")
      2

      iex> Simile.DamerauLevenshtein.distance("", "abc")
      3
  """
  @spec distance(String.t(), String.t()) :: non_neg_integer()
  def distance(a, a), do: 0
  def distance("", b), do: String.length(b)
  def distance(a, ""), do: String.length(a)

  def distance(a, b) do
    a_chars = String.codepoints(a)
    b_chars = String.codepoints(b)
    a_len = length(a_chars)
    b_len = length(b_chars)

    max_dist = a_len + b_len

    d = init_matrix(a_len, b_len, max_dist)

    {d, _da} =
      a_chars
      |> Enum.with_index(1)
      |> Enum.reduce({d, %{}}, fn {a_char, i}, {d, da} ->
        {d, _db} = fill_row(b_chars, a_char, i, d, da)
        {d, Map.put(da, a_char, i)}
      end)

    Map.fetch!(d, {a_len, b_len})
  end

  defp init_matrix(a_len, b_len, max_dist) do
    d =
      Map.new()
      |> Map.put({-1, -1}, max_dist)

    d =
      Enum.reduce(0..a_len, d, fn i, acc ->
        acc |> Map.put({i, -1}, max_dist) |> Map.put({i, 0}, i)
      end)

    Enum.reduce(0..b_len, d, fn j, acc ->
      acc |> Map.put({-1, j}, max_dist) |> Map.put({0, j}, j)
    end)
  end

  defp fill_row(b_chars, a_char, i, d, da) do
    b_chars
    |> Enum.with_index(1)
    |> Enum.reduce({d, 0}, fn {b_char, j}, {d, db} ->
      i1 = Map.get(da, b_char, 0)
      j1 = db

      cost = if a_char == b_char, do: 0, else: 1
      db = if a_char == b_char, do: j, else: db

      val =
        Enum.min([
          Map.fetch!(d, {i - 1, j - 1}) + cost,
          Map.fetch!(d, {i, j - 1}) + 1,
          Map.fetch!(d, {i - 1, j}) + 1,
          Map.fetch!(d, {i1 - 1, j1 - 1}) + (i - i1 - 1) + 1 + (j - j1 - 1)
        ])

      {Map.put(d, {i, j}, val), db}
    end)
  end
end
