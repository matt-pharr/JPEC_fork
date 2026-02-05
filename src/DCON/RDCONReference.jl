using Dates
using NCDatasets

const RDCON_REFERENCE_SCHEMA_VERSION = 1

"""
    rdcon_fixture_root()

Return the root directory containing RDCON reference fixtures.
"""
function rdcon_fixture_root()
    return normpath(joinpath(@__DIR__, "..", "..", "test", "test_data", "rdcon_reference"))
end

"""
    rdcon_case_dir(case_name)

Return the absolute path for a named RDCON reference case.
"""
function rdcon_case_dir(case_name::AbstractString)
    return joinpath(rdcon_fixture_root(), case_name)
end

"""
    rdcon_reference_path(case_name)

Return the absolute path to the reference JLD2 file for the case.
"""
function rdcon_reference_path(case_name::AbstractString)
    return joinpath(rdcon_case_dir(case_name), "reference.jld2")
end

"""
    rdcon_reference_cases()

List available reference case directory names.
"""
function rdcon_reference_cases()
    root = rdcon_fixture_root()
    if !isdir(root)
        return String[]
    end
    cases = filter(name -> startswith(name, "rdcon_case_"), readdir(root))
    return sort(cases)
end

"""
    load_rdcon_reference(case_name)

Load the reference data for a named case. Returns `nothing` if the fixture is missing.
"""
function load_rdcon_reference(case_name::AbstractString)
    path = rdcon_reference_path(case_name)
    if !isfile(path)
        return nothing
    end
    return JLD2.load(path, "reference")
end

"""
    ComparisonResult

Holds comparison metrics for array comparisons.
"""
struct ComparisonResult
    name::String
    max_abs::Float64
    max_rel::Float64
    passed::Bool
end

"""
    compare_arrays(name, expected, actual; rtol=1e-6, atol=1e-8)

Compare two arrays and return a `ComparisonResult`.
"""
function compare_arrays(name::AbstractString, expected, actual; rtol=1e-6, atol=1e-8)
    if size(expected) != size(actual)
        return ComparisonResult(String(name), Inf, Inf, false)
    end
    diff = abs.(actual .- expected)
    max_abs = maximum(diff)
    denom = maximum(abs.(expected))
    max_rel = denom == 0 ? max_abs : max_abs / denom
    passed = max_abs <= atol || max_rel <= rtol
    return ComparisonResult(String(name), max_abs, max_rel, passed)
end

"""
    comparison_report(results)

Format comparison results for logs.
"""
function comparison_report(results::Vector{ComparisonResult})
    lines = ["name | max_abs | max_rel | passed", "--- | --- | --- | ---"]
    for result in results
        push!(lines, string(result.name, " | ", result.max_abs, " | ", result.max_rel, " | ", result.passed))
    end
    return join(lines, "\n")
end

"""
    rdcon_fortran_root()

Return the root directory for the Fortran RDCON sources.
"""
function rdcon_fortran_root()
    return normpath(joinpath(@__DIR__, "rdcon_fortran"))
end

"""
    rdcon_fortran_executable()

Return the expected path to the RDCON executable.
"""
function rdcon_fortran_executable()
    return joinpath(rdcon_fortran_root(), "bin", "rdcon")
end

"""
    build_rdcon_fortran!(; force=false)

Build the Fortran RDCON executable unless it already exists. Set the environment
variable `JPEC_RDCON_SKIP_BUILD=1` to skip rebuilding.
"""
function build_rdcon_fortran!(; force=false)
    exe_path = rdcon_fortran_executable()
    skip_build = get(ENV, "JPEC_RDCON_SKIP_BUILD", "0") == "1"
    if skip_build
        if isfile(exe_path)
            return exe_path
        end
        error("RDCON build skipped but executable is missing at $(exe_path)")
    end
    if isfile(exe_path) && !force
        @info "RDCON executable already exists at $(exe_path)."
        return exe_path
    end
    rdcon_dir = joinpath(rdcon_fortran_root(), "install")
    run(`make -C $rdcon_dir`)
    @info "Built RDCON Fortran executable at $(exe_path)"
    return exe_path
end

"""
    run_rdcon_case(case_dir; build=true, work_dir=nothing)

Run the Fortran RDCON executable for the provided case directory.
Returns the working directory containing outputs.
"""
function run_rdcon_case(case_dir::AbstractString; build=true, work_dir=nothing)
    run_dir = work_dir === nothing ? mktempdir() : work_dir
    for filename in ("rdcon.in", "equil.in")
        input_path = joinpath(case_dir, filename)
        if !isfile(input_path)
            error("Missing RDCON input file: $(input_path)")
        end
        cp(input_path, joinpath(run_dir, filename); force=true)
    end
    eq_input = joinpath(case_dir, "sol.in")
    if isfile(eq_input)
        cp(eq_input, joinpath(run_dir, "sol.in"); force=true)
    end
    exe_path = build ? build_rdcon_fortran!() : rdcon_fortran_executable()
    if !isfile(exe_path)
        error("RDCON executable not found at $(exe_path)")
    end
    log_path = joinpath(run_dir, "rdcon.log")
    run(pipeline(Cmd([exe_path]; dir=run_dir), stdout=log_path, stderr=log_path))
    return run_dir
end

"""
    convert_rdcon_netcdf_to_reference(netcdf_path, output_path; metadata=Dict())

Convert a RDCON netCDF output into a JLD2 reference file.
"""
function convert_rdcon_netcdf_to_reference(netcdf_path::AbstractString,
    output_path::AbstractString; metadata=Dict{String, Any}())
    dataset = NCDatasets.Dataset(netcdf_path, "r")
    attributes = Dict{String, Any}()
    for name in keys(dataset.attrib)
        attributes[name] = dataset.attrib[name]
    end
    variables = Dict{String, Any}()
    for (name, var) in dataset.vars
        data = Array(var)
        variables[name] = _rdcon_maybe_complex(data)
    end
    close(dataset)

    reference = Dict(
        "schema_version" => RDCON_REFERENCE_SCHEMA_VERSION,
        "metadata" => merge(Dict(
            "generated_at" => string(Dates.now()),
            "source" => netcdf_path,
        ), metadata),
        "attributes" => attributes,
        "variables" => variables,
    )

    JLD2.@save output_path reference
    return reference
end

"""
    run_rdcon_reference(case_name; build=true, output_path=nothing, work_dir=nothing)

Run the Fortran RDCON case and write a reference fixture from the produced
netCDF output. Returns the path to the generated JLD2 file.
"""
function run_rdcon_reference(case_name::AbstractString; build=true, output_path=nothing, work_dir=nothing)
    case_dir = rdcon_case_dir(case_name)
    run_dir = run_rdcon_case(case_dir; build=build, work_dir=work_dir)
    netcdf_files = filter(name -> startswith(name, "rdcon_output_n") && endswith(name, ".nc"),
        readdir(run_dir))
    if isempty(netcdf_files)
        error("No rdcon_output_n*.nc files found in $(run_dir)")
    end
    netcdf_path = joinpath(run_dir, first(netcdf_files))
    output_path = output_path === nothing ? rdcon_reference_path(case_name) : output_path
    metadata = Dict("case" => case_name, "fortran_output" => basename(netcdf_path))
    convert_rdcon_netcdf_to_reference(netcdf_path, output_path; metadata=metadata)
    return output_path
end

function _rdcon_maybe_complex(data)
    if eltype(data) <: AbstractFloat && ndims(data) >= 1 && size(data, ndims(data)) == 2
        real_part = selectdim(data, ndims(data), 1)
        imag_part = selectdim(data, ndims(data), 2)
        return complex.(real_part, imag_part)
    end
    return data
end
