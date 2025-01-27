// ############################################################################################################
// ############################################################################################################
// ###############  Introductory Commands (Non-GDS Statements)  ###############################################
// ############################################################################################################
// ############################################################################################################

// ############################################################################################################
// ######################################  Commands Saved to PDF  #############################################
// ############################################################################################################

CALL gds.version(); # Return the installed graph data science library version.
CALL gds.systemMonitor(); # Get an overview of the system's workload and available resources

// Show the Number of Each Airports
MATCH 
    (n:Airport) 
RETURN 
    COUNT(n) AS NumberOfAirports;

// Show the Number of Flights

MATCH 
    ()-[r:FLIGHT]->() 
RETURN 
    COUNT(r) AS NumberOfFlights;

// Add the Airline Names for Each Airline Code
LOAD CSV WITH HEADERS FROM 'file:///airlines.csv' AS row
MATCH 
    ()-[f:FLIGHT]->()
WHERE 
    f.airline_id = toInteger(row.airline_id)
SET 
    f.airline_name = row.airline_name, 
    f.airline_code = row.airline_code;

// Add airport name, city, and state
LOAD CSV WITH HEADERS FROM 'file:///airports.csv' AS row
MATCH 
    (a:Airport)
WHERE 
    a.id = toInteger(row.unique_id)
SET 
    a.airport_code = row.airport_code, 
    a.airport_name = row.airport_name, 
    a.airport_city = row.city_name, 
    a.airportState_code = row.state, 
    a.airportState_name = row.state_name;

// Check Other information
CALL db.labels();
CALL db.relationshipTypes();
CALL gds.graph.list();

// Return the name of the Airline with an ID of 2
MATCH 
    ()-[f:FLIGHT]->() 
WHERE 
    f.airline_id = 2
RETURN 
    DISTINCT 
        f.airline_name AS AirlineName, 
        f.airline_code AS AirlineCode;

// Return the airport with an ID of 33

MATCH 
    (a1:Airport)-[f:FLIGHT]->(a2:Airport) 
WHERE 
    a1.id = 33 
RETURN 
    DISTINCT 
        a1.airport_name AS AirportName;



// Count of how many distinct airport origins there are in this dataset
MATCH 
    (origin:Airport)-[:FLIGHT]->(:Airport)
RETURN 
    COUNT(DISTINCT origin);

// Count of how many distinct airport destinations there are in this dataset
MATCH 
    (:Airport)-[:FLIGHT]->(dest:Airport) 
RETURN
    COUNT(DISTINCT dest) AS NumOfDestinations;


// ############################################################################################################
// ###################################  Commands Saved to Individual File  ####################################
// ############################################################################################################


// Return a list of the unique Airline Codes & Names
WITH "MATCH 
        ()-[f:FLIGHT]->() 
    RETURN 
        DISTINCT 
            f.airline_code AS AirlineCode, 
            f.airline_name AS AirlineName" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/1/return_list_of_unique_airline_codes_and_names.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;

// Return the Number of Flights for Each Carrier
WITH "MATCH 
        ()-[f:FLIGHT]->() 
    RETURN 
        f.airline_name AS Airline, 
        f.airline_code AS AirlineCode, 
        COUNT(*) AS Number_of_Flights" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/1/number_of_flights_for_each_carrier.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;

// Show all Airports & their data
WITH "MATCH 
        (a:Airport) 
    RETURN 
        a.airport_code AS AirportCode,
        a.airport_name AS AirportName,
        a.airport_city AS City,
        a.airportState_code AS StateShorthand,
        a.airportState_name AS StateName" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/1/show_all_airports_and_their_data.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;

// Display Full (Relevant) Flight Details for 250 flights
WITH "MATCH 
        (a1:Airport)-[r:FLIGHT]->(a2:Airport) 
    RETURN 
        a1.airport_name AS OriginAirport,
        r.airline_name AS Airline,
        r.flight_number AS FlightNumber, 
        r.flight_distance AS FlightDistance,
        r.departure_datetime AS ScheduledDepartTime,
        r.arrival_datetime AS ScheduledArrivalTime,
        a2.airport_name AS DestinationAirport
    LIMIT 250" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/1/display_full_flight_details_for_250_flights.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;

// Calculate & Display the duration of each of the flights (return only 250 results to keep it manageable)
WITH "MATCH (a1:Airport)-[r:FLIGHT]->(a2:Airport)
    WITH 
        a1, 
        r, 
        a2, 
        duration.between(r.departure_datetime, r.arrival_datetime) AS flight_duration
    RETURN 
        a1.airport_name AS OriginAirport,
        flight_duration.minutes AS FlightDurationMins,
        a2.airport_name AS DestinationAirport,
        r.flight_number AS Flight_Number,
        r.airline_name AS AirlineName,
        r.flight_distance AS FlightDistance,
        r.tail_number AS TailNumber,
        r.departure_datetime AS ScheduledDepartureTime,
        r.arrival_datetime AS ScheduledArrivalTime
    LIMIT 250" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/1/calc_and_display_duration_of_each_of_flight_250.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;

// Count of how many flights originate at each airport
WITH "MATCH 
        (origin:Airport)-[:FLIGHT]->(:Airport)
    WITH 
        origin.airport_code AS AirportCode, 
        origin.airport_name AS AirportName, 
        origin.airport_city AS City, 
        origin.airportState_name AS State, 
        COUNT(*) AS FlightCount
    RETURN 
        AirportCode, 
        AirportName, City, State, FlightCount
    ORDER BY FlightCount DESC" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/1/count_flights_orig_at_each_airport.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;

// Count Flights Originating from Each Airport by Airline
WITH "MATCH 
        (origin:Airport)-[f:FLIGHT]->(:Airport)
    WITH
        origin.airport_code AS AirportCode,
        f.airline_name AS Airline,
        COUNT(*) AS FlightCount
    RETURN 
        AirportCode,
        Airline,
        FlightCount
    ORDER BY FlightCount DESC" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/1/count_flights_orig_from_each_airport_by_airline.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;

// Count of how many flights arrive at each airport
WITH "MATCH 
        (:Airport)-[:FLIGHT]->(dest:Airport)
    WITH 
        dest.airport_code AS AirportCode, 
        dest.airport_name AS AirportName, 
        dest.airport_city AS City, 
        dest.airportState_name AS State, 
        COUNT(*) AS FlightCount
    RETURN 
        AirportCode, 
        AirportName, City, State, FlightCount
    ORDER BY FlightCount DESC" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/1/count_of_flights_arrive_at_each_airport.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;

// Count Flights Arriving from Each Airport by Airline
WITH "MATCH 
        (:Airport)-[f:FLIGHT]->(dest:Airport)
    WITH
        dest.airport_code AS AirportCode,
        f.airline_name AS Airline,
        COUNT(*) AS FlightCount
    RETURN 
        AirportCode,
        Airline,
        FlightCount
    ORDER BY FlightCount DESC" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/1/count_flights_arrive_from_each_airport_by_airline.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;


// ############################################################################################################
// ######################################  Save Entire Graph to PDF  ##########################################
// ############################################################################################################

CALL apoc.export.csv.all("Neo4j/exports/1/flights_graph_database.csv", {})