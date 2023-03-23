rm(list=ls(all=T))
library(wordbankr)
library(childesr)
# # get words from transcripts with 1037 children across 57 English language corpora (~3.5 million word tokens)
# tokens <- get_tokens(collection = "Eng-NA", role = "target_child", token = "*", db_version = "current")
# write.csv(tokens, "CHILDES.words.csv", row.names = F)
tokens <- read.csv("CHILDES.words.csv", header = T)
library(dplyr)
words <- dplyr::select(tokens, stem) # get words
colnames(words)[1:1] <- c('word')
library(tidytext)
library(textdata)
words <- words %>% anti_join(stop_words) # remove stop words
words <- words %>% inner_join(get_sentiments("bing")) %>% count(word, sentiment, sort = T) # merge words and sentiment
library(ggplot2)
words %>% # visualize positive and negative words
  group_by(sentiment) %>%
  slice_max(n, n = 20) %>% 
  ungroup() %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(n, word, fill = sentiment)) +
  geom_col(show.legend = F) +
  facet_wrap(~sentiment, scales = "free_y") +
  labs(x = "Contribution to Sentiment", y = NULL) +
  theme_bw(base_family = "Times", base_size=12) +
  theme(panel.grid.minor = element_blank(), 
        panel.grid.major = element_blank(), 
        panel.border = element_rect(size=1, color='black'), 
        legend.position = 'none', l
        egend.title = element_blank())