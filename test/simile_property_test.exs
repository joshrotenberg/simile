defmodule SimilePropertyTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  # Keep generated strings short to avoid slow tests
  defp short_string, do: StreamData.string(:alphanumeric, min_length: 0, max_length: 20)

  describe "levenshtein properties" do
    property "distance is always non-negative" do
      check all(a <- short_string(), b <- short_string()) do
        assert Simile.levenshtein(a, b) >= 0
      end
    end

    property "distance(a, a) == 0" do
      check all(a <- short_string()) do
        assert Simile.levenshtein(a, a) == 0
      end
    end

    property "symmetric: distance(a, b) == distance(b, a)" do
      check all(a <- short_string(), b <- short_string()) do
        assert Simile.levenshtein(a, b) == Simile.levenshtein(b, a)
      end
    end

    property "triangle inequality" do
      check all(a <- short_string(), b <- short_string(), c <- short_string()) do
        assert Simile.levenshtein(a, c) <= Simile.levenshtein(a, b) + Simile.levenshtein(b, c)
      end
    end

    property "distance <= max(len(a), len(b))" do
      check all(a <- short_string(), b <- short_string()) do
        assert Simile.levenshtein(a, b) <= max(String.length(a), String.length(b))
      end
    end

    property "normalized distance is between 0.0 and 1.0" do
      check all(a <- short_string(), b <- short_string()) do
        val = Simile.normalized_levenshtein(a, b)
        assert val >= 0.0 and val <= 1.0
      end
    end
  end

  describe "damerau-levenshtein properties" do
    property "distance is always non-negative" do
      check all(a <- short_string(), b <- short_string()) do
        assert Simile.damerau_levenshtein(a, b) >= 0
      end
    end

    property "distance(a, a) == 0" do
      check all(a <- short_string()) do
        assert Simile.damerau_levenshtein(a, a) == 0
      end
    end

    property "symmetric" do
      check all(a <- short_string(), b <- short_string()) do
        assert Simile.damerau_levenshtein(a, b) == Simile.damerau_levenshtein(b, a)
      end
    end

    property "damerau-levenshtein <= levenshtein (transpositions can only help)" do
      check all(a <- short_string(), b <- short_string()) do
        assert Simile.damerau_levenshtein(a, b) <= Simile.levenshtein(a, b)
      end
    end
  end

  describe "osa properties" do
    property "distance is always non-negative" do
      check all(a <- short_string(), b <- short_string()) do
        assert Simile.osa_distance(a, b) >= 0
      end
    end

    property "distance(a, a) == 0" do
      check all(a <- short_string()) do
        assert Simile.osa_distance(a, a) == 0
      end
    end

    property "symmetric" do
      check all(a <- short_string(), b <- short_string()) do
        assert Simile.osa_distance(a, b) == Simile.osa_distance(b, a)
      end
    end

    property "osa >= damerau-levenshtein (restricted can only be equal or worse)" do
      check all(a <- short_string(), b <- short_string()) do
        assert Simile.osa_distance(a, b) >= Simile.damerau_levenshtein(a, b)
      end
    end
  end

  describe "hamming properties" do
    property "distance(a, a) == 0 for all strings" do
      check all(a <- short_string()) do
        assert Simile.hamming(a, a) == {:ok, 0}
      end
    end

    property "distance is symmetric for equal-length strings" do
      check all(
              len <- StreamData.integer(0..20),
              a <- StreamData.string(:alphanumeric, length: len),
              b <- StreamData.string(:alphanumeric, length: len)
            ) do
        assert Simile.hamming(a, b) == Simile.hamming(b, a)
      end
    end

    property "returns error for different-length strings" do
      check all(
              a <- StreamData.string(:alphanumeric, length: 3),
              b <- StreamData.string(:alphanumeric, length: 5)
            ) do
        assert Simile.hamming(a, b) == {:error, :different_lengths}
      end
    end
  end

  describe "jaro properties" do
    property "similarity is between 0.0 and 1.0" do
      check all(a <- short_string(), b <- short_string()) do
        sim = Simile.jaro(a, b)
        assert sim >= 0.0 and sim <= 1.0
      end
    end

    property "similarity(a, a) == 1.0 for non-empty strings" do
      check all(a <- StreamData.string(:alphanumeric, min_length: 1, max_length: 20)) do
        assert Simile.jaro(a, a) == 1.0
      end
    end

    property "symmetric" do
      check all(a <- short_string(), b <- short_string()) do
        assert Simile.jaro(a, b) == Simile.jaro(b, a)
      end
    end
  end

  describe "jaro-winkler properties" do
    property "similarity is between 0.0 and 1.0" do
      check all(a <- short_string(), b <- short_string()) do
        sim = Simile.jaro_winkler(a, b)
        assert sim >= 0.0 and sim <= 1.0
      end
    end

    property "jaro-winkler >= jaro (prefix bonus can only help)" do
      check all(a <- short_string(), b <- short_string()) do
        assert Simile.jaro_winkler(a, b) >= Simile.jaro(a, b) - 1.0e-10
      end
    end
  end

  describe "sorensen-dice properties" do
    property "coefficient is between 0.0 and 1.0" do
      check all(
              a <- StreamData.string(:alphanumeric, min_length: 2, max_length: 20),
              b <- StreamData.string(:alphanumeric, min_length: 2, max_length: 20)
            ) do
        coeff = Simile.sorensen_dice(a, b)
        assert coeff >= 0.0 and coeff <= 1.0
      end
    end

    property "coefficient(a, a) == 1.0 for strings with bigrams" do
      check all(a <- StreamData.string(:alphanumeric, min_length: 2, max_length: 20)) do
        assert Simile.sorensen_dice(a, a) == 1.0
      end
    end

    property "symmetric" do
      check all(a <- short_string(), b <- short_string()) do
        assert Simile.sorensen_dice(a, b) == Simile.sorensen_dice(b, a)
      end
    end
  end

  describe "ngram properties" do
    property "distance is between 0.0 and 1.0" do
      check all(a <- short_string(), b <- short_string()) do
        val = Simile.ngram_distance(a, b, 2)
        assert val >= 0.0 and val <= 1.0
      end
    end

    property "distance(a, a) == 0.0" do
      check all(a <- StreamData.string(:alphanumeric, min_length: 2, max_length: 20)) do
        assert Simile.ngram_distance(a, a, 2) == 0.0
      end
    end

    property "symmetric" do
      check all(a <- short_string(), b <- short_string()) do
        assert Simile.ngram_distance(a, b, 2) == Simile.ngram_distance(b, a, 2)
      end
    end
  end

  describe "lcs properties" do
    property "lcs length is non-negative" do
      check all(a <- short_string(), b <- short_string()) do
        assert Simile.lcs(a, b) >= 0
      end
    end

    property "lcs(a, a) == length(a)" do
      check all(a <- short_string()) do
        assert Simile.lcs(a, a) == String.length(a)
      end
    end

    property "lcs <= min(len(a), len(b))" do
      check all(a <- short_string(), b <- short_string()) do
        assert Simile.lcs(a, b) <= min(String.length(a), String.length(b))
      end
    end

    property "symmetric" do
      check all(a <- short_string(), b <- short_string()) do
        assert Simile.lcs(a, b) == Simile.lcs(b, a)
      end
    end
  end

  describe "indel properties" do
    property "distance is non-negative" do
      check all(a <- short_string(), b <- short_string()) do
        assert Simile.indel(a, b) >= 0
      end
    end

    property "distance(a, a) == 0" do
      check all(a <- short_string()) do
        assert Simile.indel(a, a) == 0
      end
    end

    property "symmetric" do
      check all(a <- short_string(), b <- short_string()) do
        assert Simile.indel(a, b) == Simile.indel(b, a)
      end
    end

    property "indel == len(a) + len(b) - 2 * lcs(a, b)" do
      check all(a <- short_string(), b <- short_string()) do
        expected = String.length(a) + String.length(b) - 2 * Simile.lcs(a, b)
        assert Simile.indel(a, b) == expected
      end
    end

    property "similarity + normalized == 1.0 for non-empty pairs" do
      check all(
              a <- StreamData.string(:alphanumeric, min_length: 1, max_length: 20),
              b <- StreamData.string(:alphanumeric, min_length: 1, max_length: 20)
            ) do
        sum = Simile.indel_similarity(a, b) + Simile.normalized_indel(a, b)
        assert_in_delta sum, 1.0, 1.0e-10
      end
    end
  end

  describe "cross-algorithm properties" do
    property "indel >= levenshtein (substitution = delete + insert in indel)" do
      check all(a <- short_string(), b <- short_string()) do
        assert Simile.indel(a, b) >= Simile.levenshtein(a, b)
      end
    end
  end
end
