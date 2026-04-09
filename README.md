# Simile

[![CI](https://github.com/joshrotenberg/simile/actions/workflows/ci.yml/badge.svg)](https://github.com/joshrotenberg/simile/actions/workflows/ci.yml)
[![Hex.pm](https://img.shields.io/hexpm/v/simile.svg)](https://hex.pm/packages/simile)
[![Hex Docs](https://img.shields.io/badge/hex-docs-blue.svg)](https://hexdocs.pm/simile)
[![License](https://img.shields.io/hexpm/l/simile.svg)](https://github.com/joshrotenberg/simile/blob/main/LICENSE)

String similarity and distance algorithms for Elixir.

## Algorithms

### Distance (lower = more similar)

- **Levenshtein** -- insert, delete, substitute
- **Damerau-Levenshtein** -- insert, delete, substitute, transpose (unrestricted)
- **Optimal String Alignment (OSA)** -- restricted edit distance with transpositions
- **Hamming** -- positional differences (equal-length strings only)
- **Indel** -- insert and delete only (no substitution)
- **LCS** -- longest common subsequence length
- **N-gram** -- configurable n-gram overlap distance

### Similarity (0.0 to 1.0, higher = more similar)

- **Jaro** -- matching characters and transpositions
- **Jaro-Winkler** -- Jaro with prefix bonus
- **Sorensen-Dice** -- bigram overlap coefficient

## Usage

```elixir
Simile.levenshtein("kitten", "sitting")        #=> 3
Simile.damerau_levenshtein("abc", "bac")       #=> 1
Simile.osa_distance("abc", "bac")              #=> 1
Simile.hamming("karolin", "kathrin")           #=> {:ok, 3}
Simile.indel("kitten", "sitting")              #=> 5
Simile.lcs("kitten", "sitting")                #=> 4
Simile.ngram_distance("night", "nacht", 2)     #=> 0.75

Simile.jaro("martha", "marhta")                #=> 0.944...
Simile.jaro_winkler("martha", "marhta")        #=> 0.961...
Simile.sorensen_dice("night", "nacht")         #=> 0.25

Simile.normalized_levenshtein("kitten", "sitting")  #=> 0.428...
Simile.normalized_indel("kitten", "sitting")         #=> 0.714...
Simile.indel_similarity("kitten", "sitting")         #=> 0.285...
```

### Matching

```elixir
Simile.best_match("elxir", ["elixir", "erlang", "elm"])
#=> [{"elixir", 0.94...}]

Simile.best_match("rb", ["ruby", "rust", "python"], top: 2)
#=> [{"ruby", ...}, {"rust", ...}]

Simile.filter("elxir", ["elixir", "erlang", "elm"], min_score: 0.8)
#=> [{"elixir", 0.94...}]
```

Both accept a `:by` option to use any scoring function:

```elixir
Simile.best_match("night", ["nacht", "nite", "day"],
  by: &Simile.sorensen_dice/2
)
```

## Installation

```elixir
def deps do
  [
    {:simile, "~> 0.1.0"}
  ]
end
```

Documentation: [hexdocs.pm/simile](https://hexdocs.pm/simile)

## License

MIT
