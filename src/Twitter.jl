using DataFrames, CSV
using DynamicNetworkMeasuringTools
using StatsBase

twitter_history_df = DataFrame(CSV.File("data/twitter.csv"))[1:20000, :]
twitter_history = Tuple.(zip(twitter_history_df.src, twitter_history_df.dst))

tgamma, _ = calc_gamma(twitter_history)
tc = calc_cluster_coefficient(twitter_history)
toc, too, tnc, tno = calc_connectedness(twitter_history) |> values
ty, _ = calc_youth_coefficient(twitter_history)
tr = calc_recentness(twitter_history)
th = calc_local_entropy(twitter_history) |> mean
tg, _ = calc_ginilike_coefficient(twitter_history)
