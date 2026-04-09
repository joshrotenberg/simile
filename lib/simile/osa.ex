defmodule Simile.OSA do
  @moduledoc """
  Optimal String Alignment distance (restricted edit distance).

  Like Damerau-Levenshtein but no substring may be edited more than once.
  Simpler and faster than the full Damerau-Levenshtein, but may overcount
  in some cases. For the unrestricted variant, see `Simile.DamerauLevenshtein`.

  ## Examples

      iex> Simile.OSA.distance("abc", "bac")
      1

      iex> Simile.OSA.distance("CA", "ABC")
      3
  """

  @doc """
  Computes the Optimal String Alignment distance between two strings.

  ## Examples

      iex> Simile.OSA.distance("abc", "bac")
      1

      iex> Simile.OSA.distance("CA", "ABC")
      3

      iex> Simile.OSA.distance("abc", "abc")
      0

      iex> Simile.OSA.distance("abc", "")
      3
  """
  @spec distance(String.t(), String.t()) :: non_neg_integer()
  def distance(a, a), do: 0
  def distance("", b), do: String.length(b)
  def distance(a, ""), do: String.length(a)

  def distance(a, b) do
    a_chars = String.codepoints(a)
    b_chars = String.codepoints(b)
    b_len = length(b_chars)

    initial_row = Enum.to_list(0..b_len)

    {_, _, result} =
      a_chars
      |> Enum.with_index(1)
      |> Enum.reduce({nil, initial_row, initial_row}, fn {a_char, i},
                                                         {prev_prev_row, prev_row, _} ->
        new_row = compute_row(b_chars, a_chars, a_char, i, prev_row, prev_prev_row)
        {prev_row, new_row, new_row}
      end)

    List.last(result)
  end

  defp compute_row(b_chars, a_chars, a_char, i, prev_row, prev_prev_row) do
    {_, row} =
      b_chars
      |> Enum.with_index(1)
      |> Enum.reduce({a_char, [i]}, fn {b_char, j}, {a_ch, row} ->
        cost = if a_ch == b_char, do: 0, else: 1

        val =
          Enum.min([
            Enum.at(prev_row, j) + 1,
            List.last(row) + 1,
            Enum.at(prev_row, j - 1) + cost
          ])

        val =
          if i > 1 and j > 1 and a_ch == Enum.at(b_chars, j - 2) and
               Enum.at(a_chars, i - 2) == b_char do
            min(val, Enum.at(prev_prev_row, j - 2) + cost)
          else
            val
          end

        {a_ch, row ++ [val]}
      end)

    row
  end
end
