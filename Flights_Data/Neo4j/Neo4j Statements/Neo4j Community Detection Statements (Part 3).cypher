// ############################################################################################################
// ############################################################################################################
// #################  Introductory Commands (to make sure graph was set up correctly)  ########################
// ############################################################################################################
// ############################################################################################################

RETURN gds.version(); # Return the installed graph data science library version.
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
// ###################################  Prep & Project Graph  #################################################
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
// ###################################  Create Graph Projection  ##############################################
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
// #################################  Community Detection Analysis  ###########################################
// ############################################################################################################
// ############################################################################################################


// ############################################################################################################
// #################################  Label Propagation  ######################################################
// ############################################################################################################

/* 
https://neo4j.com/docs/graph-data-science/current/algorithms/label-propagation/
*/

WITH "CALL gds.labelPropagation.stream(
    'flights_proj',
    {
        maxIterations: 12,
        minCommunitySize: 5
    }
)
YIELD
    nodeId,
    communityId
RETURN
    nodeId AS NodeId,
    communityId AS CommunityId" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/3/label_propagation.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;


// ############################################################################################################
// #################################  Louvain Modularity  #####################################################
// ############################################################################################################

/*
https://neo4j.com/docs/graph-data-science/current/algorithms/louvain/
*/

WITH "CALL gds.louvain.stream(
    'flights_proj',
    {
        maxLevels: 12,
        maxIterations: 15
    }
)
YIELD
    nodeId,
    communityId,
    intermediateCommunityIds
RETURN
    nodeId AS NodeId,
    communityId AS CommunityId" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/3/louvain_modularity.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;


// ############################################################################################################
// #################################  Strongly Connected Components  ##########################################
// ############################################################################################################

/*
https://neo4j.com/docs/graph-data-science/current/algorithms/strongly-connected-components/
*/

WITH "CALL gds.scc.stream(
    'flights_proj',
    {}
)
YIELD
    nodeId,
    componentId
RETURN
    gds.util.asNode(nodeId).airport_name AS Name, 
    componentId AS Component
ORDER BY 
    Component,
    Name DESC" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/3/strongly_connected_components.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;


// ############################################################################################################
// #################################  Strongly Connected Components (Stats) ###################################
// ############################################################################################################

/*
https://neo4j.com/docs/graph-data-science/current/algorithms/strongly-connected-components/
*/

WITH "CALL gds.scc.stats(
    'flights_proj',
    {}
)
YIELD
    componentCount,
    componentDistribution
RETURN
    componentCount AS ComponentCount,
    componentDistribution AS ComponentDistribution" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/3/strongly_connected_components_stats.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;