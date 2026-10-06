import Lake
open System Lake DSL

package «hex-ecpp-mathlib» where
  leanOptions := #[⟨`doc.verso, true⟩, ⟨`doc.verso.suggestions, false⟩]

require HexArith from git
  "https://github.com/leanprover/hex-arith.git" @ "v0.7.0"
require HexPrimality from git
  "https://github.com/leanprover/hex-primality.git" @ "v0.7.0"
require HexECPP from git
  "https://github.com/leanprover/hex-ecpp.git" @ "v0.7.0"
require HexPrimalityMathlib from git
  "https://github.com/leanprover/hex-primality-mathlib.git" @ "v0.7.0"
require AINTLIB from git
  "https://github.com/CBirkbeck/AINTLIB.git" @ "ab1451487da02cd4483d0e2cdb2cc9e44bbbac17"
require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "d870b9068518a0870842d15a0cd42637ec30b587"

target hexecpppariio pkg : FilePath := do
  let oFile := pkg.dir / defaultBuildDir / "HexECPPMathlib" / "ffi" / "pari_pipe.o"
  let srcTarget ← inputTextFile <| pkg.dir / "HexECPPMathlib" / "ffi" / "pari_pipe.c"
  let oTarget ← buildFileAfterDep oFile srcTarget fun srcFile => do
    createParentDirs oFile
    proc {
      cmd := "cc"
      args := #["-c", "-o", oFile.toString, srcFile.toString,
        "-I", (← getLeanIncludeDir).toString, "-fPIC", "-O2", "-std=c11"]
      env := #[("TMPDIR", some (← IO.FS.realPath (oFile.parent.getD ".")).toString)]
    }
  buildStaticLib (pkg.staticLibDir / nameToStaticLib "hexecpppariio") #[oTarget]

@[default_target]
lean_lib HexECPPMathlib where
  roots := #[`HexECPPMathlib, `HexECPPMathlib.Native, `HexECPPMathlib.Pari]

lean_lib HexECPPMathlibPariIO where
  roots := #[`HexECPPMathlib.Pari.IO]
  globs := #[.one `HexECPPMathlib.Pari.IO]
  precompileModules := true
  moreLinkObjs := #[hexecpppariio]

@[default_target]
lean_lib HexECPPMathlibModules where
  globs := #[`HexECPPMathlib.Native, `HexECPPMathlib.Pari]

lean_lib HexECPPMathlibTests where
  globs := #[`HexECPPMathlib.Tests]
