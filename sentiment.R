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

#3. Impact of review length on sentiment classification
data$review_length <- ntoken(tokens(data$review))
ggplot(data, aes(x = sentiment, y = review_length)) +
  geom_boxplot() +
  labs(title = "Review Length by Sentiment", x = "Sentiment", y = "Review Length")

#4. Linguistic & Textual patterns differentiating positive and negative labels
# Create a dfm for the entire dataset
reviews_dfm <- dfm(corpus(data$review), remove = stopwords("english"), remove_punct = TRUE)

# Calculate term frequencies by sentiment
positive_dfm <- reviews_dfm[data$sentiment == "positive", ]
negative_dfm <- reviews_dfm[data$sentiment == "negative", ]
positive_freq <- textstat_frequency(positive_dfm)
negative_freq <- textstat_frequency(negative_dfm)

# Compare term frequencies
term_freq_comparison <- merge(positive_freq, negative_freq, by = "feature")
term_freq_comparison$difference <- abs(term_freq_comparison$frequency.x - term_freq_comparison$frequency.y)

# Sort by the absolute difference to find terms that differentiate the sentiments
term_freq_comparison <- term_freq_comparison[order(term_freq_comparison$difference, decreasing = TRUE), ]

# Look at the top terms
head(term_freq_comparison)


#Building model
#1. Split train and test data
# Create a dfm for the entire dataset
dfm_data <- dfm(data$review, tolower = FALSE) 
set.seed(123) 
train_indices <- sample(seq_len(nrow(dfm_data)), size = 0.8 * nrow(dfm_data))

# Split the dfm
train_dfm <- dfm_data[train_indices, ]
test_dfm <- dfm_data[-train_indices, ]

# Split the labels
train_labels <- data$sentiment[train_indices]
test_labels <- data$sentiment[-train_indices]

#Train Naive bayes classifier
library(quanteda.textmodels)

model_nb <- textmodel_nb(train_dfm, train_labels)
predictions <- predict(model_nb, newdata = test_dfm)

# Confusion Matrix
conf_matrix <- table(Predictions = predictions, Actual = test_labels)
print(conf_matrix)

# Calculate accuracy
accuracy <- sum(diag(conf_matrix)) / sum(conf_matrix)
cat("Accuracy:", accuracy, "\n")

# Train Logistic Regression model
model_lr <- textmodel_lr(train_dfm, y = train_labels)
predictions_lr <- predict(model_lr, newdata = test_dfm)

conf_matrix_lr <- table(Predictions = predictions_lr, Actual = test_labels)
print(conf_matrix_lr)
accuracy_lr <- sum(diag(conf_matrix_lr)) / sum(conf_matrix_lr)
cat("Logistic Regression Accuracy:", accuracy_lr, "\n")

# Train the SVM model
library(e1071)
model_svm <- svm(train_dfm, as.factor(train_labels), kernel = "linear")
# Make predictions
predictions_svm <- predict(model_svm, test_dfm)

# Confusion Matrix
conf_matrix_svm <- table(Predictions = predictions_svm, Actual = test_labels)
print(conf_matrix_svm)

# Calculate accuracy
accuracy_svm <- sum(diag(conf_matrix_svm)) / sum(conf_matrix_svm)
cat("SVM Accuracy:", accuracy_svm, "\n")

library(pROC)

# Calculate ROC curve and AUC for Naive Bayes Classifier
roc_obj <- roc(response = test_labels, predictor = as.numeric(predictions))

# Plotting ROC curve
plot(roc_obj, main = "ROC Curve for Naive Bayes Classifier")
# Calculate AUC
auc_value <- auc(roc_obj)
cat("AUC:", auc_value, "\n")

# Calculate ROC curve and AUC for Logistic Regression Model
roc_obj <- roc(response = test_labels, predictor = as.numeric(predictions_lr))

# Plotting ROC curve
plot(roc_obj, main = "ROC Curve for Logistic Regression Model")
# Calculate AUC
auc_value <- auc(roc_obj)
cat("AUC:", auc_value, "\n")

# Calculate ROC curve and AUC for Support Vector Machine 
roc_obj <- roc(response = test_labels, predictor = as.numeric(predictions_svm))

# Plotting ROC curve
plot(roc_obj, main = "ROC Curve for Support vector machine model")
# Calculate AUC
auc_value <- auc(roc_obj)
cat("AUC:", auc_value, "\n")

##Achieved accuracy for Logistic Regression is 0.8718362!!
# Save the trained logistic regression model to a file
saveRDS(model_lr, file = "logistic_regression_model.rds")
