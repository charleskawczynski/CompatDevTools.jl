using Test
using CompatDevTools

function simulate_keystrokes(keys...)
    keydict =  Dict(:up => "\e[A",
                    :down => "\e[B",
                    :enter => "\r")
    for key in keys
        if isa(key, Symbol)
            write(stdin.buffer, keydict[key])
        elseif isa(key, Char)
            write(stdin.buffer, "$key")
        else
            write(stdin.buffer, key)
        end
    end
end

function generate_env(filename::S, pkg_versions::Tuple{S,S,S}) where {S <: String}
    mkpath(dirname(filename))
    open(filename, "w") do io
        println(io, "[deps]")
        println(io, "SomePkgA = \"commitSHAA\"")
        println(io, "SomePkgB = \"commitSHAB\"")
        println(io, "SomePkgC = \"commitSHAC\"")
        println(io, "")
        println(io, "[compat]")
        println(io, "SomePkgA = \"$(pkg_versions[1])\"")
        println(io, "SomePkgB = \"$(pkg_versions[2])\"")
        println(io, "SomePkgC = \"$(pkg_versions[3])\"")
    end
end

@testset "CompatDevTools Unit tests - changes" begin
    mktempdir() do path
        tomlPkg = joinpath(path, "Pkg.jl", "Project.toml")
        tomlA   = joinpath(path, "Pkg.jl", "envA", "Project.toml")
        tomlB   = joinpath(path, "Pkg.jl", "envB", "Project.toml")
        generate_env(tomlPkg, ("1.2.3", "4.5.6", "7.8.9"))
        generate_env(tomlA,   ("1.2.4", "4.6.6", "8.8.9"))
        generate_env(tomlB,   ("1.3.3", "4.6.6", "7.8.9"))

        simulate_keystrokes(:down, :down, :enter, 'd')
        simulate_keystrokes(:down, :down, :enter, 'd')
        simulate_keystrokes(:down, :down, :enter, 'd')
        CompatDevTools.synchronize_compats(path)

        contents = join(readlines(tomlPkg; keep=true))
        @test contents == "[deps]\nSomePkgA = \"commitSHAA\"\nSomePkgB = \"commitSHAB\"\nSomePkgC = \"commitSHAC\"\n\n[compat]\nSomePkgA = \"1.3.3\"\nSomePkgB = \"4.6.6\"\nSomePkgC = \"7.8.9\"\n"
    end
end

@testset "CompatDevTools Unit tests - compat kickstart" begin
    @test CompatDevTools.compat_kick_start(dirname(@__DIR__)) == "[compat]\nOrderedCollections = \"1.4.1\"\njulia = \"1\""
end
