library(httr)

# Example review text
review_text <- "What a disappointment! The plot was weak, full of clichés, and utterly predictable. The acting was subpar, and the special effects were laughable. It was a complete waste of time and money. I wouldn't recommend it to anyone."

# Create a JSON request
request_body <- list(review = review_text)

# Make a POST request to the API
response <- POST("http://localhost:8000/predict_sentiment", body = request_body, encode = "json")

# Extract the predicted sentiment
result <- content(response, "parsed")
print(result)
