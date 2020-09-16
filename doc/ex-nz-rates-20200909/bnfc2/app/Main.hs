-- automatically generated by BNF Converter
module Main where


import System.IO ( stdin, hGetContents )
import System.Environment ( getArgs, getProgName )
import System.Exit ( exitFailure, exitSuccess )
import Control.Monad (when)

import LexL
import ParL
import SkelL
import PrintL
import AbsL




import ErrM

type ParseFun a = [Token] -> Err a

myLLexer = myLexer

type Verbosity = Int

putStrV :: Verbosity -> String -> IO ()
putStrV v s = when (v > 1) $ putStrLn s

runFile :: (Print a, Show a) => Verbosity -> ParseFun a -> FilePath -> IO ()
runFile v p f = putStrLn ("file: " ++ f) >> readFile f >>= \input ->
  let mylines = lines input
   in do
    putStrLn ("*** we now have " ++ show (length mylines) ++ " lines")
    mapM_ (run v p) mylines

run :: (Print a, Show a) => Verbosity -> ParseFun a -> String -> IO ()
run v p s = do
    putStrLn $ "<<< " ++ s
    let ts = myLLexer s
     in case p ts of
           Bad ss   -> do putStrLn "\nParse              Failed...\n"
                          putStrV v "Tokens:"
                          putStrV v $ show ts
                          putStrLn ss
                          exitFailure
           Ok  tree -> do showTree v tree



showTree :: (Show a, Print a) => Int -> a -> IO ()
showTree v tree
 = do
      putStrV v $ "    [Abstract Syntax]\n    " ++ show tree
      putStrV v $ "    [Linearized tree]\n    " ++ printTree tree ++ "\n"

usage :: IO ()
usage = do
  putStrLn $ unlines
    [ "usage: Call with one of the following argument combinations:"
    , "  --help          Display this help message."
    , "  (no arguments)  Parse stdin verbosely."
    , "  (files)         Parse content of files verbosely."
    , "  -s (files)      Silent mode. Parse content of files silently."
    ]
  exitFailure

main :: IO ()
main = do
  args <- getArgs
  case args of
    ["--help"] -> usage
    [] -> getContents >>= run 2 pL4StatementMulti
    "-s":fs -> mapM_ (runFile 0 pL4StatementMulti) fs
    fs -> mapM_ (runFile 2 pL4StatementMulti) fs




