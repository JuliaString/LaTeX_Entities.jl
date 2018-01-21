using LaTeX_Entities

@static VERSION < v"0.7.0-DEV" ? (using Base.Test) : (using Test)

# Test the functions lookupname, matches, longestmatches, completions
# Check that characters from all 3 tables (BMP, non-BMP, 2 character) are tested

LE = LaTeX_Entities

le_matchchar(ch)       = LE.matchchar(LE.default, ch)
le_lookupname(nam)     = LE.lookupname(LE.default, nam)
le_longestmatches(str) = LE.longestmatches(LE.default, str)
le_matches(str)        = LE.matches(LE.default, str)
le_completions(str)    = LE.completions(LE.default, str)

@testset "LaTeX_Entities" begin

@testset "lookupname" begin
    @test le_lookupname(SubString("My name is Spock", 12)) == ""
    @test le_lookupname("foobar")   == ""
    @test le_lookupname("dagger")   == "†" # \u2020
    @test le_lookupname("mscrl")    == "𝓁" # \U1f4c1
    @test le_lookupname("nleqslant") == "⩽̸" # \u2a7d\u338
end

@testset "matches" begin
    @test isempty(le_matches(""))
    @test isempty(le_matches("\U1f596"))
    @test isempty(le_matches(SubString("My name is \U1f596", 12)))
    for (chrs, exp) in (("√", ["sqrt", "surd"]),
                        ("𝓁", ["mscrl"]),
                        ("⩽̸", ["nleqslant"]))
        res = le_matches(chrs)
        @test length(res) >= length(exp)
        @test intersect(res, exp) == exp
    end
end

@testset "longestmatches" begin
    @test isempty(le_longestmatches("\U1f596 abcd"))
    @test isempty(le_longestmatches(SubString("My name is \U1f596", 12)))
    for (chrs, exp) in (("√abcd", ["sqrt", "surd"]),
                        ("𝓁abcd", ["mscrl"]),
                        ("⩽̸abcd", ["nleqslant"]))
        res = le_longestmatches(chrs)
        @test length(res) >= length(exp)
        @test intersect(res, exp) == exp
    end
end

@testset "completions" begin
    @test isempty(le_completions("ScottPaulJones"))
    @test isempty(le_completions(SubString("My name is Scott", 12)))
    for (chrs, exp) in (("A", ["AA", "AE", "Alpha"]),
                        ("mtt", ["mtta", "mttthree", "mttzero"]),
                        ("nleq", ["nleq", "nleqslant"]))
        res = le_completions(chrs)
        @test length(res) >= length(exp)
        @test intersect(res, exp) == exp
    end
end
end
