{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

module Faker.Provider.OnePiece where

import Config
import Control.Monad.Catch
import Control.Monad.IO.Class
import Data.Map.Strict (Map)
import Data.Monoid ((<>))
import Data.Text (Text)
import Data.Vector (Vector)
import Data.Yaml hiding ((.:), (.:?))
import Faker
import Faker.Internal
import Faker.Provider.TH
import Language.Haskell.TH

parseOnePiece :: FromJSON a => FakerSettings -> Value -> Parser a
parseOnePiece settings (Object obj) = do
  en <- obj .: (getLocale settings)
  faker <- en .: "faker"
  onePiece <- faker .: "one_piece"
  pure onePiece
parseOnePiece settings val = fail $ "expected Object, but got " <> (show val)

parseOnePieceField ::
     (FromJSON a, Monoid a) => FakerSettings -> Text -> Value -> Parser a
parseOnePieceField settings txt val = do
  onePiece <- parseOnePiece settings val
  field <- onePiece .:? txt .!= mempty
  pure field

parseOnePieceFields ::
     (FromJSON a, Monoid a) => FakerSettings -> [Text] -> Value -> Parser a
parseOnePieceFields settings txts val = do
  onePiece <- parseOnePiece settings val
  helper onePiece txts
  where
    helper :: (FromJSON a) => Value -> [Text] -> Parser a
    helper a [] = parseJSON a
    helper (Object a) (x:xs) = do
      field <- a .: x
      helper field xs
    helper a (x:xs) = fail $ "expect Object, but got " <> (show a)

$(genParser "onePiece" "characters")

$(genProvider "onePiece" "characters")

$(genParser "onePiece" "seas")

$(genProvider "onePiece" "seas")

$(genParser "onePiece" "islands")

$(genProvider "onePiece" "islands")

$(genParser "onePiece" "locations")

$(genProvider "onePiece" "locations")

$(genParser "onePiece" "quotes")

$(genProvider "onePiece" "quotes")

$(genParser "onePiece" "akumas_no_mi")

$(genProvider "onePiece" "akumas_no_mi")
