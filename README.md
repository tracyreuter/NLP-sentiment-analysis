# NLP Sentiment Analysis

This repo demonstrates two approaches to sentiment analysis, executed with R and Python.

## R Analysis: CHILDES Corpus Sentiment Visualization
**File:** [NLP_sentiment_analysis.R](NLP_sentiment_analysis.R)

This analysis uses child speech from the Child Language Data Exchange System ([CHILDES](https://childes.talkbank.org/)), processing **3.7 million words** from real-world conversations to provide insights into how children's speech conveys positive and negative emotions.

**Overview:**
- Use the `childesr` package to access the CHILDES TalkBank database.
- Download and cache the CHILDES English-North America corpus (3.7M+ tokens).
- Apply stemming and remove stop words for dimensionality reduction.
- Perform lexicon-based sentiment analysis with the [Bing sentiment lexicon](https://search.r-project.org/CRAN/refmans/textdata/html/lexicon_bing.html).
- Identify the top 20 most frequent positive and negative words in children's speech.
- Use ggplot2 to create a publication-ready visualization.

---

## Python Analysis: RoBERTa Transformer for Binary Sentiment Classification
**File:** [NLP_sentiment_analysis_RoBERTa.ipynb](NLP_sentiment_analysis_RoBERTa.ipynb)

This analysis uses deep learning for text classification using [RoBERTa](https://arxiv.org/abs/1907.11692) (Robustly Optimized BERT Approach), a transformer model with **125 million parameters**. The model is fine-tuned on the NLTK `movie_reviews` corpus to classify reviews as positive or negative. The current, quick-and-dirty method delivers **90%+ accuracy, precision, recall, and F1-score** after 3 training epochs.

**Overview:**
- Load the NLTK `movie_reviews` corpus and the pre-trained RoBERTa model.
- Tokenize text and convert tokenized text to PyTorch tensors for batching.
- Configure training arguments such as number of epochs.
- Evaluate performance with accuracy, precision, recall, and F1-score metrics.
- Use plotnine (ggplot2 for Python) to visualize accuracy by training epoch.

---
