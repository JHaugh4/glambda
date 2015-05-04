{-# LANGUAGE OverloadedStrings #-}

module Tests.Parse where

import Language.Glambda.Lex
import Language.Glambda.Parse
import Language.Glambda.Token
import Tests.Util

import Prelude hiding ( lex )

import Text.PrettyPrint.HughesPJClass

import Data.Text as Text
import Data.List as List
import Control.Monad

import Test.Tasty
import Test.Tasty.HUnit  ( testCase, (@?) )

parseTestCases :: [(Text, Text)]
parseTestCases = [ ("\\x:Int.x", "λ#:Int. 0")
                 , ("\\x:Int.\\y:Int.x", "λ#:Int. λ#:Int. 1")
                 , ("\\x:Int.\\x:Int.x", "λ#:Int. λ#:Int. 0")
                 , ("1 + 2 + 3", "1 + 2 + 3")
                 , ("1 + 2 * 4 % 5", "1 + 2 * 4 % 5")
                 , ("if \\x:Int.x then 4 else (\\x:Int.x) (\\y:Int.y)",
                    "if λ#:Int. 0 then 4 else (λ#:Int. 0) (λ#:Int. 0)")
                 , ("true true true", "true true true")
                 , ("true false (\\x:Int.x)", "true false (λ#:Int. 0)")
                 , ("\\x:Int->Int.\\y:Int.x y", "λ#:Int -> Int. λ#:Int. 1 0")
                 ]

parserFailTestCases :: [Text]
parserFailTestCases = [ "\\x:Int.y"
                      , " {- "
                      , "{-{- -}" ]

parseTests :: TestTree
parseTests = testGroup "Parser"
  [ testGroup "Success" $
    List.map (\(str, out) -> testCase ("`" ++ unpack str ++ "'") $
              (render $ pPrint (parse =<< lex str)) @?=
                ("Right (" ++ unpack out ++ ")"))
             parseTestCases
  , testGroup "Failure" $
    List.map (\str -> testCase ("`" ++ unpack str ++ "'") $
              (case parse =<< lex str of Left _ -> True; _ -> False) @?
              "parse erroneously successful")
             parserFailTestCases ]
