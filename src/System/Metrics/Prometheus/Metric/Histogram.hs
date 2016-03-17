{-# LANGUAGE TupleSections #-}

module System.Metrics.Prometheus.Metric.Histogram
       ( Histogram
       , HistogramSample (..)
       , UpperBound
       , new
       , put
       , sample
       ) where


import           Data.IORef (IORef, atomicModifyIORef', newIORef, readIORef)
import           Data.Map   (Map)
import qualified Data.Map   as Map


newtype Histogram = Histogram { unHistogram :: IORef HistogramSample }


type UpperBound = Double -- Inclusive upper bounds
type Buckets = Map UpperBound Double


data HistogramSample =
    HistogramSample
    { histBuckets :: Buckets
    , histSum     :: Double
    , histCount   :: Int
    }


new :: [UpperBound] -> IO Histogram
new buckets = Histogram <$> newIORef empty
  where
    empty = HistogramSample (Map.fromList $ map (, 0) (read "Infinity" : buckets)) zeroSum zeroCount
    zeroSum = 0.0
    zeroCount = 0


put :: Double -> Histogram -> IO ()
put x ioref = atomicModifyIORef' (unHistogram ioref) update
    where
      update histData = (hist' histData, ())
      hist' histData =
          histData { histBuckets = updateBuckets x $ histBuckets histData
                   , histSum = histSum histData + x
                   , histCount = histCount histData + 1
                   }


updateBuckets :: Double -> Buckets -> Buckets
updateBuckets x = Map.mapWithKey updateBucket
  where updateBucket key val
            | x <= key  = val + 1
            | otherwise = val


sample :: Histogram -> IO HistogramSample
sample = readIORef . unHistogram
