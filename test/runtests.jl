using MultiDocumenter
using Test

@testset "MultiDocumenter.jl" begin
    clonedir = mktempdir()

    docs = [
        MultiDocumenter.DropdownNav("Debugging", [
            MultiDocumenter.MultiDocRef(
                upstream = joinpath(clonedir, "Infiltrator"),
                path = "inf",
                name = "Infiltrator",
                giturl = "https://github.com/JuliaDebug/Infiltrator.jl.git",
            ),
            MultiDocumenter.MultiDocRef(
                upstream = joinpath(clonedir, "JuliaInterpreter"),
                path = "debug",
                name = "JuliaInterpreter",
                giturl = "https://github.com/JuliaDebug/JuliaInterpreter.jl.git",
            ),
        ]),
        MultiDocumenter.MegaDropdownNav("Mega Debugger", [
            MultiDocumenter.Column("Column 1", [
                MultiDocumenter.MultiDocRef(
                    upstream = joinpath(clonedir, "Infiltrator"),
                    path = "inf",
                    name = "Infiltrator",
                    giturl = "https://github.com/JuliaDebug/Infiltrator.jl.git",
                ),
                MultiDocumenter.MultiDocRef(
                    upstream = joinpath(clonedir, "JuliaInterpreter"),
                    path = "debug",
                    name = "JuliaInterpreter",
                    giturl = "https://github.com/JuliaDebug/JuliaInterpreter.jl.git",
                ),
                MultiDocumenter.MultiDocRef(
                    upstream = joinpath(clonedir, "Lux"),
                    path = "lux",
                    name = "Lux",
                    giturl = "https://github.com/avik-pal/Lux.jl",
                ),
            ]),
            MultiDocumenter.Column("Column 2", [
                MultiDocumenter.MultiDocRef(
                    upstream = joinpath(clonedir, "Infiltrator"),
                    path = "inf",
                    name = "Infiltrator",
                    giturl = "https://github.com/JuliaDebug/Infiltrator.jl.git",
                ),
                MultiDocumenter.MultiDocRef(
                    upstream = joinpath(clonedir, "JuliaInterpreter"),
                    path = "debug",
                    name = "JuliaInterpreter",
                    giturl = "https://github.com/JuliaDebug/JuliaInterpreter.jl.git",
                ),
            ]),
        ]),
        MultiDocumenter.MultiDocRef(
            upstream = joinpath(clonedir, "DataSets"),
            path = "data",
            name = "DataSets",
            giturl = "https://github.com/JuliaComputing/DataSets.jl.git",
            # or use ssh instead for private repos:
            # giturl = "git@github.com:JuliaComputing/DataSets.jl.git",
        ),
    ]

    outpath = joinpath(@__DIR__, "out")

    rootpath = "/MultiDocumenter.jl/"

    MultiDocumenter.make(
        outpath,
        docs;
        search_engine = MultiDocumenter.SearchConfig(
            index_versions = ["stable", "dev"],
            engine = MultiDocumenter.FlexSearch
        ),
        custom_scripts = [
            "foo/bar.js",
            "https://foo.com/bar.js",
            Docs.HTML("const foo = 'bar';")
        ],
        rootpath = rootpath,
    )

    @testset "structure" begin
        @test isdir(outpath, "inf")
        @test isdir(outpath, "inf", "stable")
        @test isfile(outpath, "inf", "stable", "index.html")

        @test read(joinpath(outpath, "inf", "index.html"), String) == """
        <!--This file is automatically generated by Documenter.jl-->
        <meta http-equiv="refresh" content="0; url=./stable/"/>
        """
    end


    @testset "custom scripts" begin
        index = read(joinpath(outpath, "inf", "stable", "index.html"), String)

        @test occursin("""<script charset="utf-8" type="text/javascript">window.MULTIDOCUMENTER_ROOT_PATH = '$rootpath'</script>""", index)
        @test occursin("""<script charset="utf-8" src="../../foo/bar.js" type="text/javascript"></script>""", index)
        @test occursin("""<script charset="utf-8" src="https://foo.com/bar.js" type="text/javascript"></script>""", index)
        @test occursin("""<script charset="utf-8" type="text/javascript">const foo = 'bar';</script>""", index)
    end

    @testset "flexsearch" begin
        @test isdir(outpath, "search-data")
        store_content = read(joinpath(outpath, "search-data", "store.json"), String)
        @test !isempty(store_content)
        @test occursin("Infiltrator.jl", store_content)
        @test occursin("@infiltrate", store_content)
        @test occursin("$(rootpath)inf/stable/", store_content)
        @test occursin("$(rootpath)inf/stable/", store_content)
        @test !occursin("/inf/dev/", store_content)
    end

    rm(outpath, recursive=true, force=true)
    rm(clonedir, recursive=true, force=true)
end
