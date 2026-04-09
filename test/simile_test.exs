defmodule SimileTest do
  use ExUnit.Case

  describe "levenshtein/2" do
    test "identical strings" do
      assert Simile.levenshtein("abc", "abc") == 0
    end

    test "empty strings" do
      assert Simile.levenshtein("", "") == 0
      assert Simile.levenshtein("abc", "") == 3
      assert Simile.levenshtein("", "abc") == 3
    end

    test "known values" do
      assert Simile.levenshtein("kitten", "sitting") == 3
      assert Simile.levenshtein("saturday", "sunday") == 3
    end

    test "symmetry" do
      assert Simile.levenshtein("abc", "def") == Simile.levenshtein("def", "abc")
    end

    test "unicode" do
      assert Simile.levenshtein("cafe", "cafe") == 0
      assert Simile.levenshtein("cafe", "caff") == 1
    end
  end

  describe "normalized_levenshtein/2" do
    test "identical strings" do
      assert Simile.normalized_levenshtein("abc", "abc") == 0.0
    end

    test "empty strings" do
      assert Simile.normalized_levenshtein("", "") == 0.0
    end

    test "range 0 to 1" do
      val = Simile.normalized_levenshtein("kitten", "sitting")
      assert val >= 0.0 and val <= 1.0
    end
  end

  describe "damerau_levenshtein/2" do
    test "identical strings" do
      assert Simile.damerau_levenshtein("abc", "abc") == 0
    end

    test "empty strings" do
      assert Simile.damerau_levenshtein("", "") == 0
      assert Simile.damerau_levenshtein("abc", "") == 3
      assert Simile.damerau_levenshtein("", "abc") == 3
    end

    test "transposition" do
      assert Simile.damerau_levenshtein("abc", "bac") == 1
      assert Simile.damerau_levenshtein("abcd", "badc") == 2
    end

    test "known values" do
      assert Simile.damerau_levenshtein("ca", "abc") == 2
    end
  end

  describe "osa_distance/2" do
    test "identical strings" do
      assert Simile.osa_distance("abc", "abc") == 0
    end

    test "empty strings" do
      assert Simile.osa_distance("", "") == 0
      assert Simile.osa_distance("abc", "") == 3
    end

    test "transposition" do
      assert Simile.osa_distance("abc", "bac") == 1
    end

    test "osa vs damerau-levenshtein divergence" do
      # OSA: ca -> ac (transpose) -> abc (insert) = 2
      # DL: ca -> a (delete c) -> ab (insert b) -> abc (insert c) ... but actually
      # DL can do ca -> ac (transpose) -> abc (insert) = 2, same here
      # Classic divergence: "CA" -> "ABC"
      # OSA = 3, DL = 2 for this case
      assert Simile.osa_distance("CA", "ABC") == 3
      assert Simile.damerau_levenshtein("CA", "ABC") == 2
    end
  end

  describe "hamming/2" do
    test "identical strings" do
      assert Simile.hamming("abc", "abc") == {:ok, 0}
    end

    test "empty strings" do
      assert Simile.hamming("", "") == {:ok, 0}
    end

    test "known values" do
      assert Simile.hamming("karolin", "kathrin") == {:ok, 3}
    end

    test "different lengths" do
      assert Simile.hamming("abc", "ab") == {:error, :different_lengths}
    end
  end

  describe "jaro/2" do
    test "identical strings" do
      assert Simile.jaro("abc", "abc") == 1.0
    end

    test "empty strings" do
      assert Simile.jaro("", "") == 1.0
      assert Simile.jaro("abc", "") == 0.0
      assert Simile.jaro("", "abc") == 0.0
    end

    test "known values" do
      assert_in_delta Simile.jaro("martha", "marhta"), 0.9444, 0.001
      assert_in_delta Simile.jaro("DWAYNE", "DUANE"), 0.8222, 0.001
    end

    test "completely different" do
      assert Simile.jaro("abc", "xyz") == 0.0
    end
  end

  describe "jaro_winkler/2" do
    test "identical strings" do
      assert Simile.jaro_winkler("abc", "abc") == 1.0
    end

    test "known values" do
      assert_in_delta Simile.jaro_winkler("martha", "marhta"), 0.9611, 0.001
      assert_in_delta Simile.jaro_winkler("DWAYNE", "DUANE"), 0.8400, 0.001
    end

    test "prefix bonus" do
      jaro = Simile.jaro("prefix_abc", "prefix_xyz")
      jw = Simile.jaro_winkler("prefix_abc", "prefix_xyz")
      assert jw >= jaro
    end
  end

  describe "sorensen_dice/2" do
    test "identical strings" do
      assert Simile.sorensen_dice("night", "night") == 1.0
    end

    test "known values" do
      assert_in_delta Simile.sorensen_dice("night", "nacht"), 0.25, 0.001
    end

    test "single char strings" do
      assert Simile.sorensen_dice("a", "b") == 0.0
    end

    test "no overlap" do
      assert Simile.sorensen_dice("abc", "xyz") == 0.0
    end
  end

  describe "ngram_distance/3" do
    test "identical strings" do
      assert Simile.ngram_distance("abc", "abc") == 0.0
    end

    test "empty strings" do
      assert Simile.ngram_distance("", "") == 0.0
      assert Simile.ngram_distance("abc", "") == 1.0
      assert Simile.ngram_distance("", "abc") == 1.0
    end

    test "range 0 to 1" do
      val = Simile.ngram_distance("night", "nacht", 2)
      assert val >= 0.0 and val <= 1.0
    end
  end

  describe "lcs/2" do
    test "identical strings" do
      assert Simile.lcs("abc", "abc") == 3
    end

    test "empty strings" do
      assert Simile.lcs("", "") == 0
      assert Simile.lcs("abc", "") == 0
      assert Simile.lcs("", "abc") == 0
    end

    test "known values" do
      assert Simile.lcs("abcdef", "acbcf") == 4
      assert Simile.lcs("kitten", "sitting") == 4
    end

    test "symmetry" do
      assert Simile.lcs("abc", "aec") == Simile.lcs("aec", "abc")
    end
  end

  describe "indel/2" do
    test "identical strings" do
      assert Simile.indel("abc", "abc") == 0
    end

    test "empty strings" do
      assert Simile.indel("", "") == 0
      assert Simile.indel("abc", "") == 3
      assert Simile.indel("", "abc") == 3
    end

    test "known values" do
      # kitten -> sitting: lcs=4, indel = 6+7-2*4 = 5
      assert Simile.indel("kitten", "sitting") == 5
    end

    test "symmetry" do
      assert Simile.indel("abc", "def") == Simile.indel("def", "abc")
    end
  end

  describe "normalized_indel/2" do
    test "identical strings" do
      assert Simile.normalized_indel("abc", "abc") == 0.0
    end

    test "empty strings" do
      assert Simile.normalized_indel("", "") == 0.0
    end

    test "range 0 to 1" do
      val = Simile.normalized_indel("kitten", "sitting")
      assert val >= 0.0 and val <= 1.0
    end
  end

  describe "indel_similarity/2" do
    test "identical strings" do
      assert Simile.indel_similarity("abc", "abc") == 1.0
    end

    test "complement of normalized" do
      a = "kitten"
      b = "sitting"
      assert_in_delta Simile.indel_similarity(a, b) + Simile.normalized_indel(a, b), 1.0, 0.0001
    end
  end

  describe "best_match/3" do
    @candidates ["elixir", "erlang", "elm", "python", "ruby"]

    test "returns best match by default" do
      [{match, score}] = Simile.best_match("elxir", @candidates)
      assert match == "elixir"
      assert score > 0.9
    end

    test "returns top n" do
      results = Simile.best_match("el", @candidates, top: 3)
      assert length(results) == 3
    end

    test "respects min_score" do
      results = Simile.best_match("zzzzz", @candidates, min_score: 0.9)
      assert results == []
    end

    test "custom scoring function" do
      results =
        Simile.best_match("elxir", @candidates,
          by: &Simile.sorensen_dice/2,
          top: 1
        )

      [{match, _score}] = results
      assert match == "elixir"
    end

    test "empty candidates" do
      assert Simile.best_match("test", []) == []
    end
  end

  describe "filter/3" do
    @candidates ["elixir", "erlang", "elm", "python", "ruby"]

    test "filters by default threshold" do
      results = Simile.filter("elxir", @candidates)
      assert results != []
      assert Enum.all?(results, fn {_, score} -> score >= 0.6 end)
    end

    test "custom threshold" do
      results = Simile.filter("elxir", @candidates, min_score: 0.9)
      assert Enum.all?(results, fn {_, score} -> score >= 0.9 end)
    end

    test "high threshold filters everything" do
      results = Simile.filter("zzz", @candidates, min_score: 0.99)
      assert results == []
    end

    test "sorted by score descending" do
      results = Simile.filter("elxir", @candidates, min_score: 0.0)
      scores = Enum.map(results, fn {_, s} -> s end)
      assert scores == Enum.sort(scores, :desc)
    end
  end
end
