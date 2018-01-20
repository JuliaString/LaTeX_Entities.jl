using LaTeX_Entities

@static VERSION < v"0.7.0-DEV" ? (using Base.Test) : (using Test)

# Test the functions lookupname, matches, longestmatches, completions
# Check that characters from all 3 tables (BMP, non-BMP, 2 character) are tested

LE = LaTeX_Entities

@testset "LaTeX_Entities" begin

@testset "lookupname" begin
    @test LE.lookupname(SubString("My name is Spock", 12)) == ""
    @test LE.lookupname("foobar")   == ""
    @test LE.lookupname("dagger")   == "†" # \u2020
    @test LE.lookupname("mscrl")    == "𝓁" # \U1f4c1
    @test LE.lookupname("nleqslant") == "⩽̸" # \u2a7d\u338
end

@testset "matches" begin
    @test isempty(LE.matches(""))
    @test isempty(LE.matches("\U1f596"))
    @test isempty(LE.matches(SubString("My name is \U1f596", 12)))
    for (chrs, exp) in (("√", ["sqrt", "surd"]),
                        ("𝓁", ["mscrl"]),
                        ("⩽̸", ["nleqslant"]))
        res = LE.matches(chrs)
        @test length(res) >= length(exp)
        @test intersect(res, exp) == exp
    end
end

@testset "longestmatches" begin
    @test isempty(LE.longestmatches("\U1f596 abcd"))
    @test isempty(LE.longestmatches(SubString("My name is \U1f596", 12)))
    for (chrs, exp) in (("√abcd", ["sqrt", "surd"]),
                        ("𝓁abcd", ["mscrl"]),
                        ("⩽̸abcd", ["nleqslant"]))
        res = LE.longestmatches(chrs)
        @test length(res) >= length(exp)
        @test intersect(res, exp) == exp
    end
end

@testset "completions" begin
    @test isempty(LE.completions("ScottPaulJones"))
    @test isempty(LE.completions(SubString("My name is Scott", 12)))
    for (chrs, exp) in (("A", ["AA", "AE", "Alpha"]),
                        ("mtt", ["mtta", "mttthree", "mttzero"]),
                        ("nleq", ["nleq", "nleqslant"]))
        res = LE.completions(chrs)
        @test length(res) >= length(exp)
        @test intersect(res, exp) == exp
    end
end
end
