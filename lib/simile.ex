defmodule Simile do
  @moduledoc """
  Pure Elixir string similarity and distance algorithms.

  Zero dependencies, zero NIFs. All functions accept UTF-8 binaries.

  ## Distance functions (lower = more similar)

      iex> Simile.levenshtein("kitten", "sitting")
      3

      iex> Simile.damerau_levenshtein("abc", "bac")
      1

      iex> Simile.osa_distance("abc", "bac")
      1

      iex> Simile.hamming("karolin", "kathrin")
      {:ok, 3}

      iex> Simile.indel("kitten", "sitting")
      5

      iex> Simile.lcs("kitten", "sitting")
      4

  ## Normalized distance (0.0 = identical, 1.0 = completely different)

      iex> Simile.normalized_levenshtein("abc", "abc")
      0.0

      iex> Simile.normalized_indel("abc", "abc")
      0.0

  ## Similarity functions (higher = more similar, 0.0 to 1.0)

      iex> Simile.jaro("martha", "marhta")
      0.9444444444444445

      iex> Simile.jaro_winkler("martha", "marhta")
      0.9611111111111111

      iex> Simile.sorensen_dice("night", "nacht")
      0.25

      iex> Simile.indel_similarity("abc", "abc")
      1.0

  ## Matching utilities

      iex> [{match, _score}] = Simile.best_match("elxir", ["elixir", "erlang", "elm"])
      iex> match
      "elixir"

      iex> results = Simile.filter("elxir", ["elixir", "erlang", "elm"], min_score: 0.8)
      iex> Enum.map(results, &elem(&1, 0))
      ["elixir"]
  """

  @doc """
  Computes the Levenshtein distance between two strings.

  Counts the minimum number of single-character edits (insertions, deletions,
  or substitutions) needed to transform one string into the other.

  ## Examples

      iex> Simile.levenshtein("kitten", "sitting")
      3

      iex> Simile.levenshtein("", "abc")
      3

      iex> Simile.levenshtein("abc", "abc")
      0

      iex> Simile.levenshtein("cafe", "caff")
      1
  """
  @spec levenshtein(String.t(), String.t()) :: non_neg_integer()
  defdelegate levenshtein(a, b), to: Simile.Levenshtein, as: :distance

  @doc """
  Computes the normalized Levenshtein distance as a float between 0.0 and 1.0.

  Divides the Levenshtein distance by the length of the longer string.
  Returns 0.0 for two empty strings.

  ## Examples

      iex> Simile.normalized_levenshtein("abc", "abc")
      0.0

      iex> Simile.normalized_levenshtein("", "")
      0.0

      iex> Simile.normalized_levenshtein("ab", "cd")
      1.0
  """
  @spec normalized_levenshtein(String.t(), String.t()) :: float()
  defdelegate normalized_levenshtein(a, b), to: Simile.Levenshtein, as: :normalized

  @doc """
  Computes the full Damerau-Levenshtein distance between two strings.

  Like Levenshtein but also counts transpositions of adjacent characters as
  single edits. Unlike OSA, substrings may be edited more than once, which
  can yield shorter edit paths.

  ## Examples

      iex> Simile.damerau_levenshtein("abc", "bac")
      1

      iex> Simile.damerau_levenshtein("CA", "ABC")
      2

      iex> Simile.damerau_levenshtein("abcd", "badc")
      2
  """
  @spec damerau_levenshtein(String.t(), String.t()) :: non_neg_integer()
  defdelegate damerau_levenshtein(a, b), to: Simile.DamerauLevenshtein, as: :distance

  @doc """
  Computes the Optimal String Alignment (OSA) distance between two strings.

  A restricted edit distance that allows transpositions, but no substring may
  be edited more than once. This makes it simpler and faster than full
  Damerau-Levenshtein, but it may overcount in some cases.

  ## Examples

      iex> Simile.osa_distance("abc", "bac")
      1

      iex> Simile.osa_distance("CA", "ABC")
      3

  Note the difference from full Damerau-Levenshtein on "CA" -> "ABC":
  OSA returns 3, while `damerau_levenshtein/2` returns 2.
  """
  @spec osa_distance(String.t(), String.t()) :: non_neg_integer()
  defdelegate osa_distance(a, b), to: Simile.OSA, as: :distance

  @doc """
  Computes the Hamming distance between two equal-length strings.

  Counts the number of positions where the corresponding characters differ.
  Returns `{:error, :different_lengths}` if the strings have different lengths.

  ## Examples

      iex> Simile.hamming("karolin", "kathrin")
      {:ok, 3}

      iex> Simile.hamming("abc", "abc")
      {:ok, 0}

      iex> Simile.hamming("abc", "ab")
      {:error, :different_lengths}
  """
  @spec hamming(String.t(), String.t()) :: {:ok, non_neg_integer()} | {:error, :different_lengths}
  defdelegate hamming(a, b), to: Simile.Hamming, as: :distance

  @doc """
  Computes the Jaro similarity between two strings.

  Returns a float between 0.0 (completely different) and 1.0 (identical).
  Accounts for matching characters within a window and transpositions.
  Uses grapheme clusters for Unicode correctness.

  ## Examples

      iex> Simile.jaro("martha", "marhta")
      0.9444444444444445

      iex> Simile.jaro("abc", "abc")
      1.0

      iex> Simile.jaro("abc", "xyz")
      0.0
  """
  @spec jaro(String.t(), String.t()) :: float()
  defdelegate jaro(a, b), to: Simile.Jaro, as: :similarity

  @doc """
  Computes the Jaro-Winkler similarity between two strings.

  Builds on Jaro similarity with a prefix bonus -- strings that match from
  the beginning get a higher score. Particularly good for short strings,
  names, and typo detection.

  ## Examples

      iex> Simile.jaro_winkler("martha", "marhta")
      0.9611111111111111

      iex> Simile.jaro_winkler("DWAYNE", "DUANE")
      0.84

      iex> Simile.jaro_winkler("abc", "abc")
      1.0
  """
  @spec jaro_winkler(String.t(), String.t()) :: float()
  defdelegate jaro_winkler(a, b), to: Simile.JaroWinkler, as: :similarity

  @doc """
  Computes the Sorensen-Dice coefficient between two strings.

  Measures bigram overlap, returning a float between 0.0 (no shared bigrams)
  and 1.0 (identical bigram sets). Strings shorter than 2 characters always
  return 0.0.

  ## Examples

      iex> Simile.sorensen_dice("night", "nacht")
      0.25

      iex> Simile.sorensen_dice("night", "night")
      1.0

      iex> Simile.sorensen_dice("a", "b")
      0.0
  """
  @spec sorensen_dice(String.t(), String.t()) :: float()
  defdelegate sorensen_dice(a, b), to: Simile.SorensenDice, as: :coefficient

  @doc """
  Computes the n-gram distance between two strings.

  Returns a float between 0.0 (identical n-gram sets) and 1.0 (no overlap).
  The `n` parameter controls n-gram size (default 2 for bigrams).

  ## Examples

      iex> Simile.ngram_distance("night", "night", 2)
      0.0

      iex> Simile.ngram_distance("abc", "xyz", 2)
      1.0

      iex> Simile.ngram_distance("", "")
      0.0
  """
  @spec ngram_distance(String.t(), String.t(), pos_integer()) :: float()
  def ngram_distance(a, b, n \\ 2) do
    Simile.Ngram.distance(a, b, n)
  end

  @doc """
  Computes the length of the longest common subsequence (LCS).

  The LCS is the longest sequence of characters that appears in both strings
  in the same order, but not necessarily contiguously.

  ## Examples

      iex> Simile.lcs("kitten", "sitting")
      4

      iex> Simile.lcs("abcdef", "acbcf")
      4

      iex> Simile.lcs("abc", "abc")
      3

      iex> Simile.lcs("abc", "xyz")
      0
  """
  @spec lcs(String.t(), String.t()) :: non_neg_integer()
  defdelegate lcs(a, b), to: Simile.LCS, as: :length

  @doc """
  Computes the indel (insertion/deletion) distance between two strings.

  Counts the minimum number of insertions and deletions (no substitutions)
  needed to transform one string into the other. Calculated as
  `len(a) + len(b) - 2 * lcs(a, b)`.

  ## Examples

      iex> Simile.indel("kitten", "sitting")
      5

      iex> Simile.indel("abc", "abc")
      0

      iex> Simile.indel("abc", "")
      3
  """
  @spec indel(String.t(), String.t()) :: non_neg_integer()
  defdelegate indel(a, b), to: Simile.Indel, as: :distance

  @doc """
  Computes the normalized indel distance as a float between 0.0 and 1.0.

  Divides the indel distance by the length of the longer string.
  Returns 0.0 for two empty strings.

  ## Examples

      iex> Simile.normalized_indel("abc", "abc")
      0.0

      iex> Simile.normalized_indel("", "")
      0.0
  """
  @spec normalized_indel(String.t(), String.t()) :: float()
  defdelegate normalized_indel(a, b), to: Simile.Indel, as: :normalized

  @doc """
  Computes the indel similarity as a float between 0.0 and 1.0.

  This is `1.0 - normalized_indel(a, b)`. Higher values mean more similar.

  ## Examples

      iex> Simile.indel_similarity("abc", "abc")
      1.0

      iex> Simile.indel_similarity("abc", "xyz")
      0.0
  """
  @spec indel_similarity(String.t(), String.t()) :: float()
  defdelegate indel_similarity(a, b), to: Simile.Indel, as: :similarity

  @doc """
  Finds the best matching candidate(s) from a list.

  ## Options

    * `:by` - scoring function `(String.t, String.t -> number)`,
      defaults to `&Simile.jaro_winkler/2`
    * `:top` - number of results to return, defaults to 1
    * `:min_score` - minimum score threshold, defaults to 0.0

  Returns a list of `{candidate, score}` tuples sorted by score descending.

  ## Examples

      iex> [{match, _score}] = Simile.best_match("elxir", ["elixir", "erlang", "elm"])
      iex> match
      "elixir"

      iex> results = Simile.best_match("rb", ["ruby", "rust", "python"], top: 2)
      iex> length(results)
      2

      iex> Simile.best_match("zzz", ["abc", "def"], min_score: 0.9)
      []

  Using a custom scoring function:

      iex> [{match, _}] = Simile.best_match("night", ["nacht", "nite", "day"], by: &Simile.sorensen_dice/2)
      iex> match
      "nacht"
  """
  @spec best_match(String.t(), [String.t()], keyword()) :: [{String.t(), float()}]
  defdelegate best_match(query, candidates, opts \\ []), to: Simile.Match

  @doc """
  Filters candidates that meet a similarity threshold.

  ## Options

    * `:by` - scoring function `(String.t, String.t -> number)`,
      defaults to `&Simile.jaro_winkler/2`
    * `:min_score` - minimum score threshold, defaults to 0.6

  Returns a list of `{candidate, score}` tuples sorted by score descending.

  ## Examples

      iex> results = Simile.filter("elxir", ["elixir", "erlang", "elm", "python"])
      iex> Enum.map(results, &elem(&1, 0))
      ["elixir", "elm", "erlang"]

      iex> Simile.filter("zzz", ["abc", "def"], min_score: 0.9)
      []
  """
  @spec filter(String.t(), [String.t()], keyword()) :: [{String.t(), float()}]
  defdelegate filter(query, candidates, opts \\ []), to: Simile.Match
end
