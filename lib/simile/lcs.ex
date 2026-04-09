defmodule Simile.LCS do
  @moduledoc """
  Longest Common Subsequence -- length of the longest subsequence
  common to both strings (not necessarily contiguous).

  ## Examples

      iex> Simile.LCS.length("kitten", "sitting")
      4

      iex> Simile.LCS.length("abcdef", "acbcf")
      4
  """

  @doc """
  Computes the length of the longest common subsequence of two strings.

  ## Examples

      iex> Simile.LCS.length("kitten", "sitting")
      4

      iex> Simile.LCS.length("abcdef", "acbcf")
      4

      iex> Simile.LCS.length("abc", "abc")
      3

      iex> Simile.LCS.length("abc", "xyz")
      0

      iex> Simile.LCS.length("", "abc")
      0
  """
  @spec length(String.t(), String.t()) :: non_neg_integer()
  def length(a, a), do: String.length(a)
  def length("", _), do: 0
  def length(_, ""), do: 0

  def length(a, b) do
    a_chars = String.codepoints(a)
    b_chars = String.codepoints(b)
    b_len = Kernel.length(b_chars)

    initial_row = List.duplicate(0, b_len + 1)

    a_chars
    |> Enum.reduce(initial_row, fn a_char, prev_row ->
      compute_row(b_chars, a_char, prev_row)
    end)
    |> List.last()
  end

  defp compute_row(b_chars, a_char, prev_row) do
    {_, row} =
      b_chars
      |> Enum.with_index(1)
      |> Enum.reduce({prev_row, [0]}, fn {b_char, j}, {prev, row} ->
        val =
          if a_char == b_char do
            Enum.at(prev, j - 1) + 1
          else
            max(Enum.at(prev, j), List.last(row))
          end

        {prev, row ++ [val]}
      end)

    row
  end
end
