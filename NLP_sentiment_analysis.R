# NLP Sentiment Analysis of CHILDES English-North America corpus
#
# Download children's speech tokens from the CHILDES database.
# Perform sentiment analysis using the "bing" lexicon.
# Visualize the most frequent positive and negative words.

## LOAD LIBRARIES
library("childesr")
library("wordbankr")
library("dplyr")
library("tidytext")
library("textdata")
library("ggplot2")

## DOWNLOAD AND CACHE DATA

# Define the file path for caching
token_file_path <- file.path(
  dirname(rstudioapi::getSourceEditorContext()$path),
  "CHILDES.words.csv"
)

if (file.exists(token_file_path)) {

  # If the file already exists, read it from the disk (much faster)
  message("Reading tokens from local cache file: ", token_file_path)
  tokens <- read.csv(token_file_path, header = TRUE)

} else {

  # If the file doesn't exist, download it from the CHILDES database
  message("Downloading CHILDES data (this may take a few minutes)...")
  tokens <- childesr::get_tokens(
    collection = "Eng-NA",      # Specify the English-North America corpus
    role = "target_child",      # Get tokens spoken only by the child
    token = "*",                # Get all tokens (words)
    db_version = "current"      # Use the most current database version
  )

  # Save downloaded tokens to CSV
  message("Saving tokens to cache file: ", token_file_path)
  write.csv(tokens, token_file_path, row.names = FALSE)
}

## SENTIMENT ANALYSIS

# Select 'stem' col and rename to 'word' (e.g. "jumped" to "jump")
# Stemming is a form of dimensionality reduction
words <- tokens %>%
  select(word = stem)

# Remove stop words (e.g. "the", "a")
words <- words %>%
  anti_join(stop_words, by = "word")

# Join with the "bing" sentiment lexicon
# Count occurences of each word as positive or negative
words_sentiment <- words %>%
  inner_join(get_sentiments("bing"), by = "word") %>%
  count(word, sentiment, sort = TRUE)

## VISUALIZE DATA
# Plot the top 20 most frequent positive and negative words.

# Summarize data for plotting
words_sentiment_summary <- words_sentiment %>%
  group_by(sentiment) %>%
  # Select the top 20 words by frequency
  slice_max(n, n = 20) %>%
  ungroup() %>%
  # Reorder by frequency
  mutate(word = reorder(word, n))

# Create the plot
plot <- ggplot(
  data = words_sentiment_summary,
  aes(x = n, y = word, fill = sentiment)
) +
  geom_col(show.legend = FALSE) +
  # Display 2 facets (positive and negative)
  # Use "free_y" to allow different y-axis labels per panel
  facet_wrap(~sentiment, scales = "free_y") +
  # Customize labels
  labs(
    x = "Sentiment Frequency",
    y = NULL, # Remove y-axis label (words are already displayed)
    title = "Top 20 Positive and Negative Words in
    CHILDES English, North American Corpus"
  ) +
  # Customize theme
  theme_bw(base_family = "Arial", base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major = element_blank(),
    panel.border = element_rect(linewidth = 1, color = "black"),
    legend.position = "none"
  )

# Display the plot
print(plot)