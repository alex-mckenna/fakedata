{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

module Faker.Provider.SouthPark where

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

parseSouthPark :: FromJSON a => FakerSettings -> Value -> Parser a
parseSouthPark settings (Object obj) = do
  en <- obj .: (getLocale settings)
  faker <- en .: "faker"
  southPark <- faker .: "south_park"
  pure southPark
parseSouthPark settings val = fail $ "expected Object, but got " <> (show val)

parseSouthParkField ::
     (FromJSON a, Monoid a) => FakerSettings -> Text -> Value -> Parser a
parseSouthParkField settings txt val = do
  southPark <- parseSouthPark settings val
  field <- southPark .:? txt .!= mempty
  pure field

parseSouthParkFields ::
     (FromJSON a, Monoid a) => FakerSettings -> [Text] -> Value -> Parser a
parseSouthParkFields settings txts val = do
  southPark <- parseSouthPark settings val
  helper southPark txts
  where
    helper :: (FromJSON a) => Value -> [Text] -> Parser a
    helper a [] = parseJSON a
    helper (Object a) (x:xs) = do
      field <- a .: x
      helper field xs
    helper a (x:xs) = fail $ "expect Object, but got " <> (show a)

$(genParser "southPark" "characters")

$(genProvider "southPark" "characters")

$(genParser "southPark" "quotes")

$(genProvider "southPark" "quotes")
