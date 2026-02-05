using Test
using JPEC

const DCON = JPEC.DCON

@testset "RDCON reference fixtures" begin
    cases = DCON.rdcon_reference_cases()
    @test length(cases) >= 2

    expected_q0 = Dict(
        "rdcon_case_01" => 1.0,
        "rdcon_case_02" => 1.1,
    )

    for case_name in cases
        reference = DCON.load_rdcon_reference(case_name)
        if reference === nothing
            @test_skip "Missing RDCON reference fixture for $(case_name)"
            continue
        end

        @test reference["schema_version"] == DCON.RDCON_REFERENCE_SCHEMA_VERSION
        @test haskey(reference, "grid")
        @test haskey(reference, "elements")
        @test haskey(reference, "matrices")
        @test haskey(reference, "vectors")
        @test haskey(reference, "diagnostics")

        grid = reference["grid"]
        elements = reference["elements"]
        matrices = reference["matrices"]
        vectors = reference["vectors"]
        diagnostics = reference["diagnostics"]

        @test length(grid["psi_n"]) > 0
        @test size(matrices["wp"], 1) == elements["mpert"]
        @test size(matrices["wp"], 2) == elements["mpert"]
        @test length(vectors["ep"]) == elements["mpert"]

        expected = expected_q0[case_name]
        result = DCON.compare_arrays("q_profile", [expected], [diagnostics["q_profile"][1]])
        @test result.passed
    end
end
