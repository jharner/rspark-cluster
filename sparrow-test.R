
## FROM test on container
library(sparklyr)
library(dplyr)
sc <- spark_connect(master = "spark://master:7077")
# sc <- spark_connect(master = "local")
###, config = list("sparklyr.shell.driver-memory" = "6g"))
data <- data.frame(y = runif(10^3, 0, 1))

## Benchmark Data copy_to()
microbenchmark::microbenchmark(
  setup = library(arrow),
  arrow_on = {
    sparklyr_df <<- copy_to(sc, data, overwrite = T)
    count(sparklyr_df) %>% collect()
  },
  arrow_off = {
    if ("arrow" %in% .packages()) detach("package:arrow")
    sparklyr_df <<- copy_to(sc, data, overwrite = T)
    count(sparklyr_df) %>% collect()
  },
  times = 10
) %T>% print() %>% ggplot2::autoplot()

spark_disconnect(sc)

# sc <- spark_connect(master = "local")
sc <- spark_connect(master = "spark://master:7077")

# Benchmark collect()
microbenchmark::microbenchmark(
  setup = library(arrow),
  arrow_on = {
    collect(sparklyr_df)
  },
  arrow_off = {
    if ("arrow" %in% .packages()) detach("package:arrow")
    collect(sparklyr_df)
  },
  times = 10
) %T>% print() %>% ggplot2::autoplot()
spark_disconnect(sc)

# sc <- spark_connect(master = "local")
sc <- spark_connect(master = "spark://master:7077")

## Benchmark data transformation
microbenchmark::microbenchmark(
  setup = library(arrow),
  arrow_on = {
    sample_n(sparklyr_df, 10^2) %>% spark_apply(~ .x / 2) %>% count()
  },
  arrow_off = {
    if ("arrow" %in% .packages()) detach("package:arrow")
    sample_n(sparklyr_df, 10^2) %>% spark_apply(~ .x / 2) %>% count()
  },
  times = 10
) %T>% print() %>% ggplot2::autoplot()
spark_disconnect(sc)

# Faithful dataset
#microbenchmark::microbenchmark(
#  setup = library(arrow),
#  arrow_on = {
#    sample_n(sparklyr_df, 10^5) %>% spark_apply(~ .x / 2) %>% count()
#  },
#  arrow_off = {
#    if ("arrow" %in% .packages()) detach("package:arrow")
#    sample_n(sparklyr_df, 10^5) %>% spark_apply(~ .x / 2) %>% count()
#  },
#  times = 10
#) %T>% print() %>% ggplot2::autoplot()
#faithful_tbl <- copy_to(sc, faithful, "faithful_sdf", overwrite = TRUE)
#src_tbls(sc)


spark_disconnect(sc)