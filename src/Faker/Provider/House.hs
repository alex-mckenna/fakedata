{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

module Faker.Provider.House where

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

parseHouse :: FromJSON a => FakerSettings -> Value -> Parser a
parseHouse settings (Object obj) = do
  en <- obj .: (getLocale settings)
  faker <- en .: "faker"
  house <- faker .: "house"
  pure house
parseHouse settings val = fail $ "expected Object, but got " <> (show val)

parseHouseField ::
     (FromJSON a, Monoid a) => FakerSettings -> Text -> Value -> Parser a
parseHouseField settings txt val = do
  house <- parseHouse settings val
  field <- house .:? txt .!= mempty
  pure field

parseHouseFields ::
     (FromJSON a, Monoid a) => FakerSettings -> [Text] -> Value -> Parser a
parseHouseFields settings txts val = do
  house <- parseHouse settings val
  helper house txts
  where
    helper :: (FromJSON a) => Value -> [Text] -> Parser a
    helper a [] = parseJSON a
    helper (Object a) (x:xs) = do
      field <- a .: x
      helper field xs
    helper a (x:xs) = fail $ "expect Object, but got " <> (show a)

$(genParser "house" "furniture")

$(genProvider "house" "furniture")

$(genParser "house" "rooms")

$(genProvider "house" "rooms")
