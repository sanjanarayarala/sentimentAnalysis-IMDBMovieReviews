#Loading required libraries
library(dplyr)

# 1. Importing Data
data <- read.csv("IMDB Dataset.csv") 

# 2. Data Description
# Check the structure of the dataset
cat("Structure of the dataset:\n")
str(data)

#First few rows of the dataset
cat("First few rows of the dataset:\n")
head(data)

# Summary statistics
cat("Summary of the dataset:\n")
summary(data)


# 3. Checking for Missing Values
missing_values <- colSums(is.na(data))
cat("\nMissing values in the dataset:\n")
print(missing_values)

# 4. Checking for Duplicate Entries
duplicate_entries <- sum(duplicated(data))
cat("\nNumber of duplicate entries:", duplicate_entries)

# 5. Checking for Bias
positive_reviews <- data %>% filter(sentiment == "positive")

negative_reviews <- data %>% filter(sentiment == "negative")

total_positive_reviews <- nrow(positive_reviews)
total_negative_reviews <- nrow(negative_reviews)

cat("\nClass Distribution:\n")
cat("Number of Positive Reviews:", total_positive_reviews, "\n")
cat("Number of Negative Reviews:", total_negative_reviews, "\n")

# Calculate the percentage of positive and negative reviews
percentage_positive <- (total_positive_reviews / nrow(data)) * 100
percentage_negative <- (total_negative_reviews / nrow(data)) * 100

cat("\nPercentage of Positive Reviews:", percentage_positive, "\n")
cat("Percentage of Negative Reviews:", percentage_negative, "\n")

# Check for bias
if (percentage_positive != percentage_negative) {
  cat("\nThe dataset may be biased.\n")
} else {
  cat("\nThe dataset appears balanced.\n")
}

##Data Cleaning
# 1. Identify and display duplicate entries
duplicate_rows <- data[duplicated(data), ]
cat("Duplicate entries in the dataset:\n")
print(duplicate_rows)

# Remove duplicate entries and keep only unique rows
data <- data[!duplicated(data), ]
#Checking for Duplicate Entries
duplicate_entries <- sum(duplicated(data))
cat("\nNumber of duplicate entries:", duplicate_entries)

# Checking for Bias after removal of duplicate entries
positive_reviews <- data %>% filter(sentiment == "positive")
negative_reviews <- data %>% filter(sentiment == "negative")

total_positive_reviews <- nrow(positive_reviews)
total_negative_reviews <- nrow(negative_reviews)

cat("\nClass Distribution:\n")
cat("Number of Positive Reviews:", total_positive_reviews, "\n")
cat("Number of Negative Reviews:", total_negative_reviews, "\n")

# Calculate the percentage of positive and negative reviews
percentage_positive <- (total_positive_reviews / nrow(data)) * 100
percentage_negative <- (total_negative_reviews / nrow(data)) * 100

cat("\nPercentage of Positive Reviews:", percentage_positive, "\n")
cat("Percentage of Negative Reviews:", percentage_negative, "\n")

# Check for bias
if (abs(percentage_positive- percentage_negative)>5) {
  cat("\nThe dataset may be biased.\n")
} else {
  cat("\nThe dataset appears balanced.\n")
}

# 2. Convert text to lowercase 
data$review <- tolower(data$review)
data$review <- gsub("[^a-zA-Z ]", "", data$review)

# 3. Removing special characters, numbers and punctuations
library(tm)
corpus <- Corpus(VectorSource(data$review))
corpus <- tm_map(corpus, content_transformer(tolower))
corpus <- tm_map(corpus, removePunctuation)
corpus <- tm_map(corpus, removeNumbers)

# 4. Removing Stopwords
corpus <- tm_map(corpus, removeWords, stopwords("english"))
data$review <- sapply(corpus, function(x) paste(unlist(strsplit(x, " ")), collapse=" "))

# Data Visualization
# 1. Visualize the distribution of sentiment labels
library(ggplot2)
ggplot(data, aes(x = sentiment)) +
  geom_bar(fill = "skyblue") +
  labs(title = "Distribution of Sentiment Labels", x = "Sentiment", y = "Count")
# Load necessary libraries
library(quanteda)
library(quanteda.textstats)
library(wordcloud)
library(caret)
library(SnowballC)

# 2. Identify frequent words in positive reviews and generate word cloud
positive_reviews_corpus <- corpus(data[data$sentiment == "positive", "review"])
positive_reviews_dfm <- dfm(positive_reviews_corpus, remove = stopwords("english"), remove_punct = TRUE)
positive_reviews_dfm <- dfm_trim(positive_reviews_dfm, min_termfreq = 5000) 

# Get the frequency of terms in positive reviews
positive_freq <- textstat_frequency(positive_reviews_dfm)
top_positive_words <- head(positive_freq, 25) # Select top 25 words
print(top_positive_words)

# Generate word cloud
set.seed(1234) # for reproducibility
wordcloud(words = top_positive_words$feature, freq = top_positive_words$frequency,
          max.words = 100, random.order = FALSE, colors = brewer.pal(8, "Dark2"))

