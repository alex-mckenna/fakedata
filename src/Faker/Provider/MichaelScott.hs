{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

module Faker.Provider.MichaelScott where

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

parseMichaelScott :: FromJSON a => FakerSettings -> Value -> Parser a
parseMichaelScott settings (Object obj) = do
  en <- obj .: (getLocale settings)
  faker <- en .: "faker"
  michaelScott <- faker .: "michael_scott"
  pure michaelScott
parseMichaelScott settings val =
  fail $ "expected Object, but got " <> (show val)

parseMichaelScottField ::
     (FromJSON a, Monoid a) => FakerSettings -> Text -> Value -> Parser a
parseMichaelScottField settings txt val = do
  michaelScott <- parseMichaelScott settings val
  field <- michaelScott .:? txt .!= mempty
  pure field

parseMichaelScottFields ::
     (FromJSON a, Monoid a) => FakerSettings -> [Text] -> Value -> Parser a
parseMichaelScottFields settings txts val = do
  michaelScott <- parseMichaelScott settings val
  helper michaelScott txts
  where
    helper :: (FromJSON a) => Value -> [Text] -> Parser a
    helper a [] = parseJSON a
    helper (Object a) (x:xs) = do
      field <- a .: x
      helper field xs
    helper a (x:xs) = fail $ "expect Object, but got " <> (show a)

$(genParser "michaelScott" "quotes")

$(genProvider "michaelScott" "quotes")
