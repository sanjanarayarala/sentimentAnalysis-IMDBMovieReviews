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
