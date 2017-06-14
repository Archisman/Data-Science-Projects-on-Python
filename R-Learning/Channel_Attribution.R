library(dplyr)
library(ChannelAttribution)

# simulating the "real" data
set.seed(354)
df2 <- data.frame(client_id = sample(c(1:1000), 5000, replace = TRUE),
                  date = sample(c(1:32), 5000, replace = TRUE),
                  channel = sample(c(0:9), 5000, replace = TRUE,
                                   prob = c(0.1, 0.15, 0.05, 0.07, 0.11, 0.07, 0.13, 0.1, 0.06, 0.16)))
df2$date <- as.Date(df2$date, origin = "2015-01-01")
df2$channel <- paste0('channel_', df2$channel)

# aggregating channels to the paths for each customer
df2 <- df2 %>%
  group_by(client_id) %>%
  summarise(path = paste(channel, collapse = ' > '),
            # assume that all paths were finished with conversion
            conv = 1,
            conv_null = 0) %>%
  ungroup()

# calculating the models (Markov and heuristics)
mod2 <- markov_model(df2,
                     var_path = 'path',
                     var_conv = 'conv',
                     var_null = 'conv_null',
                     out_more = TRUE)

# heuristic_models() function doesn't work for me, therefore I used the manual calculations
# instead of:
#h_mod2 <- heuristic_models(df2, var_path = 'path', var_conv = 'conv')

df_hm <- df2 %>%
  mutate(channel_name_ft = sub('>.*', '', path),
         channel_name_ft = sub(' ', '', channel_name_ft),
         channel_name_lt = sub('.*>', '', path),
         channel_name_lt = sub(' ', '', channel_name_lt))
# first-touch conversions
df_ft <- df_hm %>%
  group_by(channel_name_ft) %>%
  summarise(first_touch_conversions = sum(conv)) %>%
  ungroup()
# last-touch conversions
df_lt <- df_hm %>%
  group_by(channel_name_lt) %>%
  summarise(last_touch_conversions = sum(conv)) %>%
  ungroup()

h_mod2 <- merge(df_ft, df_lt, by.x = 'channel_name_ft', by.y = 'channel_name_lt')

# merging all models
all_models <- merge(h_mod2, mod2$result, by.x = 'channel_name_ft', by.y = 'channel_name')
colnames(all_models)[c(1, 4)] <- c('channel_name', 'attrib_model_conversions')
