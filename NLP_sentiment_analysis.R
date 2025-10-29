# -----------------------------------------------------------------------------
# NLP Sentiment Analysis of CHILDES English-North America corpus
#
# Download children's speech tokens from the CHILDES database.
# Perform sentiment analysis using the "bing" lexicon.
# Visualize the most frequent positive and negative words.
# -----------------------------------------------------------------------------


## 1. LOAD LIBRARIES
# -----------------------------------------------------------------------------
library(childesr)
library(wordbankr)
library(dplyr)
library(tidytext)
library(textdata)
library(ggplot2)


## 2. DOWNLOAD AND CACHE DATA
# -----------------------------------------------------------------------------
# Download data if it doesn't exist locally.
# If it does, reads from the local file to save time.

# Define the file path for caching the downloaded tokens
token_file_path <- "CHILDES.words.csv"

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

  # Save the downloaded tokens to the CSV file for future use
  message("Saving tokens to cache file: ", token_file_path)
  write.csv(tokens, token_file_path, row.names = FALSE)
}


## 3. PERFORM SENTIMENT ANALYSIS
# -----------------------------------------------------------------------------
# Select the 'stem' column (the root form of a word) and rename it to 'word'
words <- tokens %>%
  select(word = stem)

# Remove "stop words" (common words like "the", "a", "is", "in").
# These words are filtered out because they don't carry sentiment.
words <- words %>%
  anti_join(stop_words, by = "word")

# Perform sentiment analysis
words_sentiment <- words %>%
  # Join with the "bing" sentiment lexicon
  # This labels words as "positive" or "negative"
  inner_join(get_sentiments("bing"), by = "word") %>%

  # Count the occurrences of each word/sentiment pair and sort by most frequent
  count(word, sentiment, sort = TRUE)


## 4. VISUALIZE DATA
# -----------------------------------------------------------------------------
# Plot the top N most frequent positive and negative words.

# Define how many top words to show per category
top_n <- 20

# Group data by sentiment (positive/negative) to find the top N for each
words_sentiment %>%
  group_by(sentiment) %>%
  # Select the top N words (based on frequency 'n') within each group
  slice_max(n, n = top_n) %>%
  # Ungroup to allow reordering for the plot
  ungroup() %>%
  # Reorder the 'word' factor based on its frequency 'n'.
  # This makes the plot display from lowest to highest frequency.
  mutate(word = reorder(word, n)) %>%

  # Generate plot
  ggplot(aes(x = n, y = word, fill = sentiment)) +
  # Create a bar chart (geom_col is for when 'n' is a value)
  geom_col(show.legend = FALSE) +
  # Create two separate panels ("facets"): one for positive, one for negative
  # 'scales = "free_y"' allows the y-axis labels (words) to differ per panel
  facet_wrap(~sentiment, scales = "free_y") +
  # Add labels and theme
  labs(
    x = "Contribution to Sentiment (Frequency)",
    y = NULL, # No y-axis label (the words are self-explanatory)
    title = "Top 20 Positive and Negative Words in CHILDES (Eng-NA) Corpus"
  ) +
  # Use a clean black & white theme with a Times font
  theme_bw(base_family = "Times", base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),     # Remove minor grid lines
    panel.grid.major = element_blank(),     # Remove major grid lines
    panel.border = element_rect(size = 1, color = "black"), # Add a border
    legend.position = "none"               # Hide the legend
  )