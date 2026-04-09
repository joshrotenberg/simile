defmodule Simile.Levenshtein do
  @moduledoc """
  Levenshtein distance -- minimum number of single-character edits
  (insertions, deletions, substitutions) to transform one string into another.

  ## Examples

      iex> Simile.Levenshtein.distance("kitten", "sitting")
      3

      iex> Simile.Levenshtein.normalized("kitten", "sitting")
      0.42857142857142855
  """

  @doc """
  Computes the Levenshtein distance between two strings.

  ## Examples

      iex> Simile.Levenshtein.distance("kitten", "sitting")
      3

      iex> Simile.Levenshtein.distance("saturday", "sunday")
      3

      iex> Simile.Levenshtein.distance("", "abc")
      3

      iex> Simile.Levenshtein.distance("abc", "abc")
      0
  """
  @spec distance(String.t(), String.t()) :: non_neg_integer()
  def distance(a, a), do: 0
  def distance("", b), do: String.length(b)
  def distance(a, ""), do: String.length(a)

  def distance(a, b) do
    a_codepoints = String.codepoints(a)
    b_codepoints = String.codepoints(b)
    b_len = length(b_codepoints)

    initial_row = Enum.to_list(0..b_len)

    a_codepoints
    |> Enum.reduce({0, initial_row}, fn a_char, {i, prev_row} ->
      i = i + 1
      new_row = compute_row(b_codepoints, a_char, prev_row, i)
      {i, new_row}
    end)
    |> elem(1)
    |> List.last()
  end

  defp compute_row(b_codepoints, a_char, prev_row, i) do
    {_, row} =
      Enum.reduce(b_codepoints, {0, [i]}, fn b_char, {j, row} ->
        j = j + 1
        cost = if a_char == b_char, do: 0, else: 1

        val =
          Enum.min([
            Enum.at(prev_row, j) + 1,
            List.last(row) + 1,
            Enum.at(prev_row, j - 1) + cost
          ])

        {j, row ++ [val]}
      end)

    row
  end

  @doc """
  Computes the normalized Levenshtein distance (0.0 to 1.0).

  Divides the raw distance by the length of the longer string.
  Returns 0.0 for two empty strings.

  ## Examples

      iex> Simile.Levenshtein.normalized("abc", "abc")
      0.0

      iex> Simile.Levenshtein.normalized("", "")
      0.0

      iex> Simile.Levenshtein.normalized("ab", "cd")
      1.0
  """
  @spec normalized(String.t(), String.t()) :: float()
  def normalized("", ""), do: 0.0

  def normalized(a, b) do
    max_len = max(String.length(a), String.length(b))
    distance(a, b) / max_len
  end
end
