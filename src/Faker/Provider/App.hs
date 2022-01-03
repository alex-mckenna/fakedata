{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

module Faker.Provider.App where

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
import Faker.Provider.Company (companyNameProvider, resolveCompanyText)
import Faker.Provider.Name (nameNameProvider, resolveNameText)
import Faker.Provider.TH
import Language.Haskell.TH

parseApp :: FromJSON a => FakerSettings -> Value -> Parser a
parseApp settings (Object obj) = do
  en <- obj .: (getLocale settings)
  faker <- en .: "faker"
  app <- faker .: "app"
  pure app
parseApp settings val = fail $ "expected Object, but got " <> (show val)

parseAppField ::
     (FromJSON a, Monoid a) => FakerSettings -> Text -> Value -> Parser a
parseAppField settings txt val = do
  app <- parseApp settings val
  field <- app .:? txt .!= mempty
  pure field

parseUnresolvedAppField ::
     (FromJSON a, Monoid a)
  => FakerSettings
  -> Text
  -> Value
  -> Parser (Unresolved a)
parseUnresolvedAppField settings txt val = do
  app <- parseApp settings val
  field <- app .:? txt .!= mempty
  pure $ pure field

$(genAppParser "name")

$(genAppProvider "name")

$(genAppParserUnresolved "version")

$(genAppParserUnresolved "author")

$(genAppProviderUnresolved "version")

$(genAppProviderUnresolved "author")

resolveAppText :: (MonadIO m, MonadThrow m) => FakerSettings -> Text -> m Text
resolveAppText = genericResolver' resolveAppField

resolveAppField :: (MonadThrow m, MonadIO m) => FakerSettings -> Text -> m Text
resolveAppField settings "Name.name" =
  cachedRandomUnresolvedVec
    "name"
    "name"
    nameNameProvider
    resolveNameText
    settings
resolveAppField settings "Company.name" =
  cachedRandomUnresolvedVec
    "company"
    "name"
    companyNameProvider
    resolveCompanyText
    settings
resolveAppField settings str = throwM $ InvalidField "app" str
