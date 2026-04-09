defmodule Simile.Match do
  @moduledoc """
  Higher-level matching utilities for finding and filtering similar strings.

  Both `best_match/3` and `filter/3` accept a `:by` option to swap the
  scoring function. Any `(String.t, String.t -> number)` works.

  ## Examples

      iex> [{match, _}] = Simile.Match.best_match("elxir", ["elixir", "erlang", "elm"])
      iex> match
      "elixir"

      iex> results = Simile.Match.filter("elxir", ["elixir", "erlang"], min_score: 0.8)
      iex> Enum.map(results, &elem(&1, 0))
      ["elixir"]
  """

  @type score_fn :: (String.t(), String.t() -> number())

  @doc """
  Returns the best matching candidate(s) from a list.

  ## Options

    * `:by` - scoring function, defaults to `&Simile.jaro_winkler/2`
    * `:top` - number of results to return, defaults to 1
    * `:min_score` - minimum score threshold, defaults to 0.0

  Returns a list of `{candidate, score}` tuples sorted by score descending.

  ## Examples

      iex> [{match, _}] = Simile.Match.best_match("elxir", ["elixir", "erlang", "elm"])
      iex> match
      "elixir"

      iex> results = Simile.Match.best_match("rb", ["ruby", "rust", "python"], top: 2)
      iex> length(results)
      2

      iex> Simile.Match.best_match("zzz", ["abc", "def"], min_score: 0.9)
      []
  """
  @spec best_match(String.t(), [String.t()], keyword()) :: [{String.t(), float()}]
  def best_match(query, candidates, opts \\ []) do
    score_fn = Keyword.get(opts, :by, &Simile.jaro_winkler/2)
    top = Keyword.get(opts, :top, 1)
    min_score = Keyword.get(opts, :min_score, 0.0)

    candidates
    |> Enum.map(fn candidate -> {candidate, score_fn.(query, candidate)} end)
    |> Enum.filter(fn {_, score} -> score >= min_score end)
    |> Enum.sort_by(fn {_, score} -> score end, :desc)
    |> Enum.take(top)
  end

  @doc """
  Filters candidates that meet a similarity threshold.

  ## Options

    * `:by` - scoring function, defaults to `&Simile.jaro_winkler/2`
    * `:min_score` - minimum score threshold, defaults to 0.6

  Returns a list of `{candidate, score}` tuples sorted by score descending.

  ## Examples

      iex> results = Simile.Match.filter("elxir", ["elixir", "erlang"], min_score: 0.8)
      iex> Enum.map(results, &elem(&1, 0))
      ["elixir"]

      iex> Simile.Match.filter("zzz", ["abc", "def"], min_score: 0.9)
      []
  """
  @spec filter(String.t(), [String.t()], keyword()) :: [{String.t(), float()}]
  def filter(query, candidates, opts \\ []) do
    score_fn = Keyword.get(opts, :by, &Simile.jaro_winkler/2)
    min_score = Keyword.get(opts, :min_score, 0.6)

    candidates
    |> Enum.map(fn candidate -> {candidate, score_fn.(query, candidate)} end)
    |> Enum.filter(fn {_, score} -> score >= min_score end)
    |> Enum.sort_by(fn {_, score} -> score end, :desc)
  end
end
