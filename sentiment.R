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
