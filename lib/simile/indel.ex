defmodule Simile.Indel do
  @moduledoc """
  Indel distance -- minimum number of insertions and deletions (no substitutions)
  to transform one string into another.

  Calculated as `len(a) + len(b) - 2 * lcs(a, b)`.

  ## Examples

      iex> Simile.Indel.distance("kitten", "sitting")
      5

      iex> Simile.Indel.similarity("abc", "abc")
      1.0
  """

  @doc """
  Computes the indel distance between two strings.

  ## Examples

      iex> Simile.Indel.distance("kitten", "sitting")
      5

      iex> Simile.Indel.distance("abc", "abc")
      0

      iex> Simile.Indel.distance("abc", "")
      3

      iex> Simile.Indel.distance("", "abc")
      3
  """
  @spec distance(String.t(), String.t()) :: non_neg_integer()
  def distance(a, a), do: 0
  def distance("", b), do: String.length(b)
  def distance(a, ""), do: String.length(a)

  def distance(a, b) do
    String.length(a) + String.length(b) - 2 * Simile.LCS.length(a, b)
  end

  @doc """
  Computes the normalized indel distance (0.0 to 1.0).

  Divides the raw distance by the length of the longer string.
  Returns 0.0 for two empty strings.

  ## Examples

      iex> Simile.Indel.normalized("abc", "abc")
      0.0

      iex> Simile.Indel.normalized("", "")
      0.0
  """
  @spec normalized(String.t(), String.t()) :: float()
  def normalized("", ""), do: 0.0

  def normalized(a, b) do
    max_len = max(String.length(a), String.length(b))
    distance(a, b) / max_len
  end

  @doc """
  Computes the indel similarity (0.0 to 1.0).

  This is `1.0 - normalized(a, b)`. Higher values mean more similar.

  ## Examples

      iex> Simile.Indel.similarity("abc", "abc")
      1.0

      iex> Simile.Indel.similarity("abc", "xyz")
      0.0
  """
  @spec similarity(String.t(), String.t()) :: float()
  def similarity(a, b), do: 1.0 - normalized(a, b)
end
