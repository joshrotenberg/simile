defmodule Simile.Hamming do
  @moduledoc """
  Hamming distance -- number of positions where corresponding characters differ.

  Only defined for strings of equal length. Returns a tagged tuple to
  distinguish success from length mismatch.

  ## Examples

      iex> Simile.Hamming.distance("karolin", "kathrin")
      {:ok, 3}

      iex> Simile.Hamming.distance("abc", "ab")
      {:error, :different_lengths}
  """

  @doc """
  Computes the Hamming distance between two equal-length strings.

  ## Examples

      iex> Simile.Hamming.distance("karolin", "kathrin")
      {:ok, 3}

      iex> Simile.Hamming.distance("1011101", "1001001")
      {:ok, 2}

      iex> Simile.Hamming.distance("abc", "abc")
      {:ok, 0}

      iex> Simile.Hamming.distance("", "")
      {:ok, 0}

      iex> Simile.Hamming.distance("abc", "ab")
      {:error, :different_lengths}
  """
  @spec distance(String.t(), String.t()) ::
          {:ok, non_neg_integer()} | {:error, :different_lengths}
  def distance(a, b) do
    a_chars = String.codepoints(a)
    b_chars = String.codepoints(b)

    if length(a_chars) != length(b_chars) do
      {:error, :different_lengths}
    else
      count =
        Enum.zip(a_chars, b_chars)
        |> Enum.count(fn {x, y} -> x != y end)

      {:ok, count}
    end
  end
end
