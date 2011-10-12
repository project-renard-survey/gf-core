module WebSetup(installWeb,copyWeb) where

import System.Directory(createDirectoryIfMissing,copyFile,removeFile)
import System.FilePath((</>))
import System.Cmd(system)
import System.Exit(ExitCode(..))
import Distribution.Simple.Setup(Flag(..),CopyDest(..),copyDest)
import Distribution.Simple.LocalBuildInfo(datadir,buildDir,absoluteInstallDirs)

{-
   To test the GF web services, the minibar and the grammar editor, use
   "cabal install" (or "runhaskell Setup.hs install") to install gf as usual.
   Then start the server with the command "gf -server" and
   open http://localhost:41296/minibar/minibar.html in your web browser
   (Firefox, Safari, Opera or Chrome). The example grammars listed below will
   be available in the minibar.
-}

example_grammars =  -- :: [(pgf, tmp, src)]
   [("Foods.pgf","foods","contrib"</>"summerschool"</>"foods"</>"Foods???.gf"),
    ("Letter.pgf","letter","examples"</>"letter"</>"Letter???.gf")]


installWeb args flags pki lbi = setupWeb args dest pki lbi
  where
    dest = NoCopyDest

copyWeb args flags pki lbi = setupWeb args dest pki lbi
  where
    dest = case copyDest flags of
             NoFlag -> NoCopyDest
             Flag d -> d

setupWeb args dest pkg lbi =
    do putStrLn "setupWeb"
       mapM_ (createDirectoryIfMissing True) [grammars_dir,cloud_dir]
       mapM_ build_pgf example_grammars
  where
    grammars_dir = www_dir </> "grammars"
    cloud_dir = www_dir </> "tmp" -- hmm
    www_dir = datadir (absoluteInstallDirs pkg lbi dest) </> "www"
    gfo_dir = buildDir lbi </> "gfo"

    build_pgf (pgf,tmp,src) =
      do createDirectoryIfMissing True tmp_dir
         execute cmd
         copyFile pgf (grammars_dir</>pgf)
         putStrLn (grammars_dir</>pgf)
         removeFile pgf
      where
        tmp_dir = gfo_dir</>tmp
        cmd = "gf -make -s -optimize-pgf --gfo-dir="++tmp_dir++
           -- " --output-dir="++grammars_dir++  -- has no effect?!
              " "++src

execute command =
  do putStrLn command
     e <- system command
     case e of
       ExitSuccess -> return ()
       _ -> fail "Command failed"
     return ()
