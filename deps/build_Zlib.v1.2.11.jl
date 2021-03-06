using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libz"], :libz),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaBinaryWrappers/Zlib_jll.jl/releases/download/Zlib-v1.2.11+5"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/Zlib.v1.2.11.aarch64-linux-gnu.tar.gz", "21f91fad2fd1a2903a72b1b9dbb833dbc81df115268a9e3e80350d9a5b71d950"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/Zlib.v1.2.11.aarch64-linux-musl.tar.gz", "91fcbb2d4720102deb5af81996f40b0ec11410ab8278f48b0b1cd08ffd01af45"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/Zlib.v1.2.11.arm-linux-gnueabihf.tar.gz", "c6210cadb32f5a8098cbbe7422d2f0ff4c029af463e740e211692a2cfaea9223"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/Zlib.v1.2.11.arm-linux-musleabihf.tar.gz", "627d93d9981ca5d0b19ead1356bffaacf8dd66e5627b60eadb449cc8618d8ee8"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/Zlib.v1.2.11.i686-linux-gnu.tar.gz", "12f0c3aa21aa4609b4eb4363f3ce47f8b648ee82cdaf46a2c60dc7a0d81f84ef"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/Zlib.v1.2.11.i686-linux-musl.tar.gz", "8deea79e1172972634e0ced27e756139cf1e205ee6b0ecc5601835c72fe42962"),
    Windows(:i686) => ("$bin_prefix/Zlib.v1.2.11.i686-w64-mingw32.tar.gz", "4971a6447699fd9a806199e8a196fcd5fd1b0b3cc5a87cd5d6d78193a448b093"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/Zlib.v1.2.11.powerpc64le-linux-gnu.tar.gz", "2854a41a7f15430aed0df4e5d9208b20afb27123941ce71af4b0c99dcf4a3b28"),
    MacOS(:x86_64) => ("$bin_prefix/Zlib.v1.2.11.x86_64-apple-darwin14.tar.gz", "4487aba8b584ec732ea3bb567e9b98dd9e23f256294841adb84e7cf86ca6451a"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/Zlib.v1.2.11.x86_64-linux-gnu.tar.gz", "b733a4ad486e6e4c8d9168c1f70333e7e6e64331c04a068ea608e8b820933c21"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/Zlib.v1.2.11.x86_64-linux-musl.tar.gz", "d179217caa04f5aa5fae6b7851c0344f142fca635f0561c5f4f14a86bb534d7b"),
    FreeBSD(:x86_64) => ("$bin_prefix/Zlib.v1.2.11.x86_64-unknown-freebsd11.1.tar.gz", "9c87da9a21351a25fb6a1c806f14421da345649c3c6f4c8d83e0aa3e00b95922"),
    Windows(:x86_64) => ("$bin_prefix/Zlib.v1.2.11.x86_64-w64-mingw32.tar.gz", "1010aa960a0c721a88dd9c46c6d0b3bd209e8b9f2ed27a8f9a5e9523dabc8f0c"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
    # Download and install binaries
    install(dl_info...; prefix=prefix, force=true, verbose=verbose)
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)
