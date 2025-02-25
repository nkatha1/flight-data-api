# Load required libraries
library(plumber)
library(data.table)
library(RSQLite)

# Create the flights data.table (if not already created)
flights_dt <- data.table(
  id = c(1, 2, 3),
  carrier = c("Delta", "United", "American"),
  origin = c("JFK", "LAX", "ORD"),
  dest = c("LAX", "JFK", "DFW"),
  dep_delay = c(10, 15, 5),
  arr_delay = c(5, 20, 10)
)

# Create the Plumber API
api <- plumb("flights_api.R")  # Explicitly specify the path to your script

# POST /flight to add a new flight
api$POST("/flight", function(req, res) {
  id <- as.integer(req$args$id)
  carrier <- req$args$carrier
  origin <- req$args$origin
  dest <- req$args$dest
  dep_delay <- as.numeric(req$args$dep_delay)
  arr_delay <- as.numeric(req$args$arr_delay)
  
  # Add new flight to the data.table
  new_flight <- data.table(id = id, carrier = carrier, origin = origin, dest = dest, 
                           dep_delay = dep_delay, arr_delay = arr_delay)
  
  flights_dt <<- rbind(flights_dt, new_flight)  # Update global data.table

  return(list(message = "Flight added successfully"))
})

# GET /flight/:id to retrieve flight by id
api$GET("/flight/{id}", function(req, res) {
  flight_id <- as.integer(req$args$id)
  flight <- flights_dt[flight_id == id]
  
  if (nrow(flight) == 0) {
    res$status <- 404
    return(list(message = "Flight not found"))
  }
  
  return(flight)  # Return the flight data
})

# Run the API on port 8081
api$run(host = "127.0.0.1", port = 8081, debug = TRUE)