library(plumber)
library(quanteda.textmodels)
library(jsonlite)
# Load the saved logistic regression model
model_lr <- readRDS("C:/IIT/F23/DPA/project/sentimentAnalysis-IMDBMovieReviews/logistic_regression_model.rds")

# Define API endpoint for sentiment prediction
#* @post /predict_sentiment
function(req){
  # Parse the request body as JSON
  data <- jsonlite::fromJSON(req$postBody)
  
  # Preprocess the review text
  processed_review <- data$review
  processed_review <- quanteda::tokens(processed_review)
  processed_review <- quanteda::dfm(processed_review)
  
  # Make a prediction
  prediction <- predict(model_lr, newdata = processed_review, type = "prob")
  
  # Extract probabilities
  positive_prob <- prediction[,"positive"]
  negative_prob <- prediction[,"negative"]
  
  # Determine sentiment label
  sentiment <- ifelse(positive_prob > negative_prob, "positive", "negative")
  probability <- max(positive_prob, negative_prob)
  
  # Return the result as JSON
  return(list(sentiment = sentiment, probability = probability))
}
