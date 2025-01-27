// ############################################################################################################
// ############################################################################################################
// ###############  Introductory Commands (to make sure graph was set up correctly)  ##########################
// ############################################################################################################
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

// ############################################################################################################
// ############################################################################################################
// ########################  Prep & Project Graph  ############################################################
// ############################################################################################################
// ############################################################################################################

// ############################################################################################################
// #################  Prep - Convert timestamps to epoch (milliseconds since 1970)  ###########################
// ############################################################################################################

MATCH
    ()-[f:FLIGHT]->()
SET
    f.departure_timestamp_ms = duration.between(datetime('1970-01-01T00:00:00Z'), datetime(f.departure_datetime)).milliseconds
SET
    f.arrival_timestamp_ms = duration.between(datetime('1970-01-01T00:00:00Z'), datetime(f.arrival_datetime)).milliseconds
RETURN
    f.departure_timestamp_ms,
    f.arrival_timestamp_ms;

// ############################################################################################################
// ########################  Drop Graph Projection (if it exists)  ############################################
// ############################################################################################################

CALL gds.graph.exists('flights_proj') YIELD exists
WITH exists
WHERE exists
CALL gds.graph.drop('flights_proj') YIELD graphName
RETURN 'Graph dropped' AS result;

// ############################################################################################################
// ########################  Create Graph Projection  #########################################################
// ############################################################################################################

CALL gds.graph.project(
    'flights_proj',
    ['Airport'],
    ['FLIGHT'],
    {
    nodeProperties: [
        'id'
        ],
    relationshipProperties: [
        'flight_number', 
        'arrival_timestamp_ms',
        'departure_timestamp_ms',
        'flight_distance'
        ]  // Properties on FLIGHT relationships
    }
)
YIELD
    graphName, 
    nodeProjection, 
    nodeCount, 
    relationshipProjection, 
    relationshipCount, 
    projectMillis;

// ############################################################################################################
// ############################################################################################################
// ########################  Similarity Analysis  #########################################################
// ############################################################################################################
// ############################################################################################################

// ############################################################################################################
// ########################  (Unweighted) Node Similarity  ####################################################
// ############################################################################################################

/*
https://neo4j.com/docs/graph-data-science/current/algorithms/node-similarity/
*/

// Aggregate Jaccard, Overlap, and Cosine similarities into one result
WITH "CALL gds.nodeSimilarity.stream(
    'flights_proj',
    {
        similarityMetric: 'JACCARD'
    }
) YIELD
    node1 AS Airport1,
    node2 AS Airport2,
    similarity AS JaccardSimilarity
WITH Airport1, Airport2, JaccardSimilarity
CALL gds.nodeSimilarity.stream(
    'flights_proj',
    {
        similarityMetric: 'OVERLAP'
    }
) YIELD
    node1 AS Airport1_temp,
    node2 AS Airport2_temp,
    similarity AS OverlapSimilarity
WHERE Airport1 = Airport1_temp AND Airport2 = Airport2_temp
WITH Airport1, Airport2, JaccardSimilarity, OverlapSimilarity
CALL gds.nodeSimilarity.stream(
    'flights_proj',
    {
        similarityMetric: 'COSINE'
    }
) YIELD
    node1 AS Airport1_temp,
    node2 AS Airport2_temp,
    similarity AS CosineSimilarity
WHERE Airport1 = Airport1_temp AND Airport2 = Airport2_temp
WITH Airport1, Airport2, JaccardSimilarity, OverlapSimilarity, CosineSimilarity
MATCH (a1:Airport) WHERE id(a1) = Airport1
MATCH (a2:Airport) WHERE id(a2) = Airport2
RETURN
    a1.airport_code AS Airport1,
    a2.airport_code AS Airport2,
    JaccardSimilarity AS Jaccard,
    OverlapSimilarity AS Overlap,
    CosineSimilarity AS Cosine" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/5/unweighted_node_similarity.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;


// ############################################################################################################
// ########################  (Weighted) Node Similarity  ######################################################
// ############################################################################################################

/*
https://neo4j.com/docs/graph-data-science/current/algorithms/node-similarity/
*/

// Aggregate Jaccard, Overlap, and Cosine similarities into one result
WITH "CALL gds.nodeSimilarity.stream(
    'flights_proj',
    {
        similarityMetric: 'JACCARD',
        relationshipWeightProperty: 'flight_distance'
    }
) YIELD
    node1 AS Airport1,
    node2 AS Airport2,
    similarity AS JaccardSimilarity
WITH Airport1, Airport2, JaccardSimilarity
CALL gds.nodeSimilarity.stream(
    'flights_proj',
    {
        similarityMetric: 'OVERLAP',
        relationshipWeightProperty: 'flight_distance'
    }
) YIELD
    node1 AS Airport1_temp,
    node2 AS Airport2_temp,
    similarity AS OverlapSimilarity
WHERE Airport1 = Airport1_temp AND Airport2 = Airport2_temp
WITH Airport1, Airport2, JaccardSimilarity, OverlapSimilarity
CALL gds.nodeSimilarity.stream(
    'flights_proj',
    {
        similarityMetric: 'COSINE',
        relationshipWeightProperty: 'flight_distance'
    }
) YIELD
    node1 AS Airport1_temp,
    node2 AS Airport2_temp,
    similarity AS CosineSimilarity
WHERE Airport1 = Airport1_temp AND Airport2 = Airport2_temp
WITH Airport1, Airport2, JaccardSimilarity, OverlapSimilarity, CosineSimilarity
MATCH (a1:Airport) WHERE id(a1) = Airport1
MATCH (a2:Airport) WHERE id(a2) = Airport2
RETURN
    a1.airport_code AS Airport1,
    a2.airport_code AS Airport2,
    JaccardSimilarity AS Jaccard,
    OverlapSimilarity AS Overlap,
    CosineSimilarity AS Cosine" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/5/weighted_node_similarity.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;