// ############################################################################################################
// ############################################################################################################
// ###############  Introductory Commands (to make sure graph was set up correctly)  ##########################
// ############################################################################################################
// ############################################################################################################

RETURN gds.version(); # Return installed graph data science library version.
CALL gds.version(); # Return installed graph data science library version.
CALL gds.systemMonitor(); # Get an overview of system's workload & available resources

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
    relationshipCount;

// ############################################################################################################
// ############################################################################################################
// ########################  Unweighted Shortest Path Analysis  ###############################################
// ############################################################################################################
// ############################################################################################################

// ############################################################################################################
// ########################  Unweighted Source (Shortest Path)  ###############################################
// ############################################################################################################

/*
Source/Origin Airport: 'MKE'
*/

// ############################################################################################################
// ########################  Dijkstra's Unweighted Source Shortest Path  ######################################
// ############################################################################################################


WITH "MATCH (n:Airport {airport_code: 'MKE'})
WITH id(n) AS sourceNodeId
CALL gds.allShortestPaths.dijkstra.stream(
    'flights_proj',
    {
        sourceNode: sourceNodeId
    }
)
YIELD
    index AS Index,
    sourceNode AS Origin,
    targetNode AS Destination,
    totalCost AS TotalCost,
    nodeIds AS NodeIds,
    costs AS Cost,
    path AS Path
WHERE Origin <> Destination // Make sure to exclude paths where origin is same as destination
WITH Index, Origin, Destination, TotalCost, NodeIds, Cost, Path
MATCH (origin:Airport) WHERE id(origin) = Origin
MATCH (destination:Airport) WHERE id(destination) = Destination
WITH Index, origin.airport_code AS OriginCode, destination.airport_code AS DestinationCode, TotalCost, NodeIds, Cost, Path
UNWIND NodeIds AS stopId
MATCH (stop:Airport) WHERE id(stop) = stopId
WITH Index, OriginCode, DestinationCode, TotalCost, collect(stop.airport_code) AS IntermediateStopCodes, Cost, Path
RETURN
    Index,
    OriginCode AS Origin,
    DestinationCode AS Destination,
    TotalCost,
    IntermediateStopCodes AS AirportCodes,
    Cost,
    Path
ORDER BY TotalCost ASC" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/2a/dijkstras_unweighted_source_shortest_path.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;


// ############################################################################################################
// ########################  Bellman-Ford's Unweighted Source Shortest Path  ##################################
// ############################################################################################################

/*
https://neo4j.com/docs/graph-data-science/current/algorithms/bellman-ford-single-source/
*/

WITH "MATCH (n:Airport {airport_code: 'MKE'})
WITH id(n) AS sourceNodeId
CALL gds.bellmanFord.stream(
    'flights_proj',
    {
        sourceNode: sourceNodeId
    }
)
YIELD
    index AS Index,
    sourceNode AS Origin,
    targetNode AS Destination,
    totalCost AS TotalCost,
    nodeIds AS NodeIds,
    costs AS Cost,
    route AS Path
WHERE Origin <> Destination // Make sure to exclude paths where origin is same as destination
WITH Index, Origin, Destination, TotalCost, NodeIds, Cost, Path
MATCH (origin:Airport) WHERE id(origin) = Origin
MATCH (destination:Airport) WHERE id(destination) = Destination
WITH Index, origin.airport_code AS OriginCode, destination.airport_code AS DestinationCode, TotalCost, NodeIds, Cost, Path
UNWIND NodeIds AS stopId
MATCH (stop:Airport) WHERE id(stop) = stopId
WITH Index, OriginCode, DestinationCode, TotalCost, collect(stop.airport_code) AS IntermediateStopCodes, Cost, Path
RETURN
    Index,
    OriginCode AS Origin,
    DestinationCode AS Destination,
    TotalCost,
    IntermediateStopCodes AS AirportCodes,
    Cost,
    Path
ORDER BY TotalCost ASC" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/2a/bellman_ford_unweighted_source_shortest_path.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;


// ############################################################################################################
// ########################  Delta-Stepping Unweighted Source Shortest Path  ##################################
// ############################################################################################################

/*
https://neo4j.com/docs/graph-data-science/current/algorithms/delta-single-source/
*/

WITH "MATCH (n:Airport {airport_code: 'MKE'})
WITH id(n) AS sourceNodeId
CALL gds.allShortestPaths.delta.stream(
    'flights_proj',
    {
        sourceNode: sourceNodeId
    }
)
YIELD
    index AS Index,
    sourceNode AS Origin,
    targetNode AS Destination,
    totalCost AS TotalCost,
    nodeIds AS NodeIds,
    costs AS Cost,
    path AS Path
WHERE Origin <> Destination // Make sure to exclude paths where origin is same as destination
WITH Index, Origin, Destination, TotalCost, NodeIds, Cost, Path
MATCH (origin:Airport) WHERE id(origin) = Origin
MATCH (destination:Airport) WHERE id(destination) = Destination
WITH Index, origin.airport_code AS OriginCode, destination.airport_code AS DestinationCode, TotalCost, NodeIds, Cost, Path
UNWIND NodeIds AS stopId
MATCH (stop:Airport) WHERE id(stop) = stopId
WITH Index, OriginCode, DestinationCode, TotalCost, collect(stop.airport_code) AS IntermediateStopCodes, Cost, Path
RETURN
    Index,
    OriginCode AS Origin,
    DestinationCode AS Destination,
    TotalCost,
    IntermediateStopCodes AS AirportCodes,
    Cost,
    Path
ORDER BY TotalCost ASC" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/2a/delta_stepping_unweighted_source_shortest_path.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;


// ############################################################################################################
// ############################################################################################################
// ########################  Source-Target Unweighted Shortest Path Analysis  #################################
// ############################################################################################################
// ############################################################################################################

/*
Source/Origin Airport: 'MKE'
Target/Destination Airport: 'CDC'
*/

// ############################################################################################################
// ########################  Dijkstra's Unweighted Source-Target Shortest Path  ###############################
// ############################################################################################################

WITH "MATCH (n:Airport {airport_code: 'MKE'})
WITH id(n) AS sourceNodeId
MATCH (target:Airport {airport_code: 'CDC'})
WITH sourceNodeId, id(target) AS targetNodeId
CALL gds.shortestPath.dijkstra.stream(
    'flights_proj',
    {
        sourceNode: sourceNodeId,
        targetNode: targetNodeId
    }
)
YIELD
    index AS Index,
    sourceNode AS Origin,
    targetNode AS Destination,
    totalCost AS TotalCost,
    nodeIds AS NodeIds,
    costs AS Cost,
    path AS Path
WITH Index, Origin, Destination, TotalCost, NodeIds, Cost, Path
MATCH (origin:Airport) WHERE id(origin) = Origin
MATCH (destination:Airport) WHERE id(destination) = Destination
WITH Index, origin.airport_code AS OriginCode, destination.airport_code AS DestinationCode, TotalCost, NodeIds, Cost, Path
UNWIND NodeIds AS stopId
MATCH (stop:Airport) WHERE id(stop) = stopId
WITH Index, OriginCode, DestinationCode, TotalCost, collect(stop.airport_code) AS IntermediateStopCodes, Cost, Path
RETURN
    Index,
    OriginCode AS Origin,
    DestinationCode AS Destination,
    TotalCost,
    IntermediateStopCodes AS AirportCodes,
    Cost,
    Path
ORDER BY TotalCost ASC" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/2a/dijkstras_unweighted_source_target_shortest_path.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;


// ############################################################################################################
// ########################  Bellman-Ford's Unweighted Source-Target Shortest Path  ######################################
// ############################################################################################################

/*
https://neo4j.com/docs/graph-data-science/current/algorithms/bellman-ford-single-source/
*/

WITH "MATCH (n:Airport {airport_code: 'MKE'})
WITH id(n) AS sourceNodeId
CALL gds.bellmanFord.stream(
    'flights_proj',
    {
        sourceNode: sourceNodeId
    }
)
YIELD
    index AS Index,
    sourceNode AS Origin,
    targetNode AS Destination,
    totalCost AS TotalCost,
    nodeIds AS NodeIds,
    costs AS Cost,
    route AS Path
WITH Index, Origin, Destination, TotalCost, NodeIds, Cost, Path
MATCH (origin:Airport) WHERE id(origin) = Origin
MATCH (destination:Airport) WHERE id(destination) = Destination
WITH Index, origin.airport_code AS OriginCode, destination.airport_code AS DestinationCode, TotalCost, NodeIds, Cost, Path
UNWIND NodeIds AS stopId
MATCH (stop:Airport) WHERE id(stop) = stopId
WITH Index, OriginCode, DestinationCode, TotalCost, collect(stop.airport_code) AS IntermediateStopCodes, Cost, Path
RETURN
    Index,
    OriginCode AS Origin,
    DestinationCode AS Destination,
    TotalCost,
    IntermediateStopCodes AS AirportCodes,
    Cost,
    Path
ORDER BY TotalCost ASC" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/2a/bellman_ford_unweighted_source_target_shortest_path.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;


// ############################################################################################################
// ########################  Yen's Unweighted Source-Target Shortest Path  ###############################################
// ############################################################################################################

/*
https://neo4j.com/docs/graph-data-science/current/algorithms/yens/
*/

WITH "MATCH (n:Airport {airport_code: 'MKE'})
WITH id(n) AS sourceNodeId
MATCH (target:Airport {airport_code: 'CDC'})
WITH sourceNodeId, id(target) AS targetNodeId
CALL gds.shortestPath.yens.stream(
    'flights_proj',
    {
        sourceNode: sourceNodeId,
        targetNode: targetNodeId,
        k: 3
    }
)
YIELD
    index AS Index,
    sourceNode AS Origin,
    targetNode AS Destination,
    totalCost AS TotalCost,
    nodeIds AS NodeIds,
    costs AS Cost,
    path AS Path
WITH Index, Origin, Destination, TotalCost, NodeIds, Cost, Path
MATCH (origin:Airport) WHERE id(origin) = Origin
MATCH (destination:Airport) WHERE id(destination) = Destination
WITH Index, origin.airport_code AS OriginCode, destination.airport_code AS DestinationCode, TotalCost, NodeIds, Cost, Path
UNWIND NodeIds AS stopId
MATCH (stop:Airport) WHERE id(stop) = stopId
WITH Index, OriginCode, DestinationCode, TotalCost, collect(stop.airport_code) AS IntermediateStopCodes, Cost, Path
RETURN
    Index,
    OriginCode AS Origin,
    DestinationCode AS Destination,
    TotalCost,
    IntermediateStopCodes AS AirportCodes,
    Cost,
    Path
ORDER BY TotalCost ASC" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/2a/yens_unweighted_source_target_shortest_path.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;