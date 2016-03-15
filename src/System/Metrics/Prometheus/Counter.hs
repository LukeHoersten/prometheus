module System.Metrics.Prometheus.Counter where


import           Data.Atomics.Counter (AtomicCounter, incrCounter_, newCounter,
                                       readCounter)


newtype Counter = Counter { unCounter :: AtomicCounter }


new :: IO Counter
new = Counter <$> newCounter 0


add :: Int -> Counter -> IO ()
add by = incrCounter_ by . unCounter


inc :: Counter -> IO ()
inc = add 1


view :: Counter -> IO Int
view = readCounter . unCounter