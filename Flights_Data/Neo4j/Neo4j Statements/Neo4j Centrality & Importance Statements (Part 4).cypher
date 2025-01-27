// ############################################################################################################
// ############################################################################################################
// ###############  Introductory Commands (to make sure graph was set up correctly)  ##########################
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

CALL gds.graph.exists('flights_proj_part_4') YIELD exists
WITH exists
WHERE exists
CALL gds.graph.drop('flights_proj_part_4') YIELD graphName
RETURN 'Graph dropped' AS result;

// ############################################################################################################
// ########################  Create Graph Projection  #########################################################
// ############################################################################################################

CALL gds.graph.project(
    'flights_proj_part_4',
    ['Airport'],
    {
        FLIGHT: {
            type: 'FLIGHT',
            orientation: 'UNDIRECTED'  // Makes the relationships undirected
        }
    },
    {
        nodeProperties: [
            'id'
        ],
        relationshipProperties: [
            'flight_number', 
            'arrival_timestamp_ms',
            'departure_timestamp_ms',
            'flight_distance'
        ]
    }
)
YIELD
    graphName, 
    nodeProjection, 
    nodeCount, 
    relationshipProjection, 
    relationshipCount, 
    projectMillis
RETURN
    graphName AS GraphName, 
    nodeProjection AS NodeProjection, 
    nodeCount AS NodeCount, 
    relationshipProjection AS RelationshipProjection, 
    relationshipCount AS RelationshipCount, 
    projectMillis AS ProjectMilliseconds;


// ############################################################################################################
// ############################################################################################################
// #########################  Centrality & Importance Analysis  ###############################################
// ############################################################################################################
// ############################################################################################################

// ############################################################################################################
// #################################  Influence Maximization (CELF)  ##########################################
// ############################################################################################################

/*
https://neo4j.com/docs/graph-data-science/current/algorithms/celf/
*/

WITH "CALL gds.influenceMaximization.celf.stream(
    'flights_proj_part_4',
    {
        seedSetSize: 6
    }
)
YIELD
    nodeId,
    spread
RETURN
    gds.util.asNode(nodeId).airport_code AS Airport,
    spread AS Spread" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/4/influence_maximization_celf.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;


// ############################################################################################################
// #################################  Bridges  ################################################################
// ############################################################################################################

/*
https://neo4j.com/docs/graph-data-science/current/algorithms/bridges/
*/

WITH "CALL gds.bridges.stream(
    'flights_proj_part_4',
    {}
)
YIELD
    from,
    to
RETURN 
    gds.util.asNode(from).airport_code AS From_Airport,
    gds.util.asNode(to).airport_code AS To_Airport" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/4/bridges.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;


// ############################################################################################################
// #################################  Articulation Points  ####################################################
// ############################################################################################################

/*
https://neo4j.com/docs/graph-data-science/current/algorithms/articulation-points/
*/

WITH "CALL gds.articulationPoints.stream(
    'flights_proj_part_4'
)
YIELD
    nodeId
RETURN
    gds.util.asNode(nodeId).airport_code AS Airport" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/4/articulation_points.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;


// ############################################################################################################
// #################################  Degree Centrality  ######################################################
// ############################################################################################################

/*
https://neo4j.com/docs/graph-data-science/current/algorithms/degree-centrality/
*/

WITH "CALL gds.degree.stream(
    'flights_proj_part_4'
) 
YIELD
    nodeId,
    score
RETURN
    gds.util.asNode(nodeId).airport_code AS Airport,
    score AS Degree_Score" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/4/degree_centrality.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;


// ############################################################################################################
// #################################  Closeness Centrality  ###################################################
// ############################################################################################################

/*
https://neo4j.com/docs/graph-data-science/current/algorithms/closeness-centrality/
*/

WITH "CALL gds.closeness.stream(
    'flights_proj_part_4',
    {
        useWassermanFaust: true
    }
)
YIELD
    nodeId,
    score
RETURN
    gds.util.asNode(nodeId).airport_code AS Airport,
    score AS Closeness_Score" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/4/closeness_centrality.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;


// ############################################################################################################
// ############################  Betweenness Centrality (& Approximation)  ####################################
// ############################################################################################################

/*
https://neo4j.com/docs/graph-data-science/current/algorithms/betweenness-centrality/
*/

WITH "CALL gds.betweenness.stream(
    'flights_proj_part_4',
    {
        samplingSeed: 42
    }
)
YIELD
    nodeId,
    score
RETURN
    gds.util.asNode(nodeId).airport_code AS Airport,
    score AS Betweenness_Score" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/4/betweenness_centrality.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;


// ############################################################################################################
// #################################  Page Rank (No Scaler)  ##################################################
// ############################################################################################################

/*
https://neo4j.com/docs/graph-data-science/current/algorithms/page-rank/
*/

WITH "CALL gds.pageRank.stream(
    'flights_proj_part_4',
    {
        dampingFactor: 0.75,
        maxIterations: 25,
        scaler: 'None'
    }
)
YIELD
    nodeId,
    score
RETURN
    gds.util.asNode(nodeId).airport_code AS Airport,
    score AS Page_Rank_Score" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/4/page_rank_no_scaler.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;


// ############################################################################################################
// #################################  Page Rank (MinMax)  #####################################################
// ############################################################################################################

/*
https://neo4j.com/docs/graph-data-science/current/algorithms/page-rank/
*/

WITH "CALL gds.pageRank.stream(
    'flights_proj_part_4',
    {
        dampingFactor: 0.75,
        maxIterations: 25,
        scaler: 'MinMax'
    }
)
YIELD
    nodeId,
    score
RETURN
    gds.util.asNode(nodeId).airport_code AS Airport,
    score AS Page_Rank_Score" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/4/page_rank_min_max_scaler.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;

// ############################################################################################################
// #################################  Page Rank (Max Scaler)  #################################################
// ############################################################################################################

/*
https://neo4j.com/docs/graph-data-science/current/algorithms/page-rank/
*/

WITH "CALL gds.pageRank.stream(
    'flights_proj_part_4',
    {
        dampingFactor: 0.75,
        maxIterations: 25,
        scaler: 'Max'
    }
)
YIELD
    nodeId,
    score
RETURN
    gds.util.asNode(nodeId).airport_code AS Airport,
    score AS Page_Rank_Score" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/4/page_rank_max_scaler.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;

// ############################################################################################################
// #################################  Page Rank (Mean Scaler)  ################################################
// ############################################################################################################

/*
https://neo4j.com/docs/graph-data-science/current/algorithms/page-rank/
*/

WITH "CALL gds.pageRank.stream(
    'flights_proj_part_4',
    {
        dampingFactor: 0.75,
        maxIterations: 25,
        scaler: 'Mean'
    }
)
YIELD
    nodeId,
    score
RETURN
    gds.util.asNode(nodeId).airport_code AS Airport,
    score AS Page_Rank_Score" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/4/page_rank_mean_scaler.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;

// ############################################################################################################
// #################################  Page Rank (Log Scaler)  #################################################
// ############################################################################################################

/*
https://neo4j.com/docs/graph-data-science/current/algorithms/page-rank/
*/

WITH "CALL gds.pageRank.stream(
    'flights_proj_part_4',
    {
        dampingFactor: 0.75,
        maxIterations: 25,
        scaler: 'Log'
    }
)
YIELD
    nodeId,
    score
RETURN
    gds.util.asNode(nodeId).airport_code AS Airport,
    score AS Page_Rank_Score" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/4/page_rank_log_scaler.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;

// ############################################################################################################
// #################################  Page Rank (StdScore Scaler)  ############################################
// ############################################################################################################

/*
https://neo4j.com/docs/graph-data-science/current/algorithms/page-rank/
*/

WITH "CALL gds.pageRank.stream(
    'flights_proj_part_4',
    {
        dampingFactor: 0.75,
        maxIterations: 25,
        scaler: 'StdScore'
    }
)
YIELD
    nodeId,
    score
RETURN
    gds.util.asNode(nodeId).airport_code AS Airport,
    score AS Page_Rank_Score" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/4/page_rank_std_score_scaler.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;


// ############################################################################################################
// #################################  Article Rank (No Scaler)  ###############################################
// ############################################################################################################

/*
https://neo4j.com/docs/graph-data-science/current/algorithms/article-rank/ 
*/

WITH "CALL gds.articleRank.stream(
    'flights_proj_part_4',
    {
        dampingFactor: 0.75,
        maxIterations: 25,
        scaler:  'None'
    }
)
YIELD
    nodeId,
    score
RETURN
    gds.util.asNode(nodeId).airport_code AS Airport,
    score AS Article_Rank_Score" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/4/article_rank_no_scaler.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;

// ############################################################################################################
// #################################  Article Rank (MinMax Scaler)  ###########################################
// ############################################################################################################

/*
https://neo4j.com/docs/graph-data-science/current/algorithms/article-rank/ 
*/

WITH "CALL gds.articleRank.stream(
    'flights_proj_part_4',
    {
        dampingFactor: 0.75,
        maxIterations: 25,
        scaler: 'MinMax'
    }
)
YIELD
    nodeId,
    score
RETURN
    gds.util.asNode(nodeId).airport_code AS Airport,
    score AS Article_Rank_Score" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/4/article_rank_min_max_scaler.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;

// ############################################################################################################
// #################################  Article Rank (Max Scaler)  ##############################################
// ############################################################################################################

/*
https://neo4j.com/docs/graph-data-science/current/algorithms/article-rank/ 
*/

WITH "CALL gds.articleRank.stream(
    'flights_proj_part_4',
    {
        dampingFactor: 0.75,
        maxIterations: 25,
        scaler: 'Max'
    }
)
YIELD
    nodeId,
    score
RETURN
    gds.util.asNode(nodeId).airport_code AS Airport,
    score AS Article_Rank_Score" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/4/article_rank_max_scaler.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;

// ############################################################################################################
// #################################  Article Rank (Mean Scaler)  #############################################
// ############################################################################################################

/*
https://neo4j.com/docs/graph-data-science/current/algorithms/article-rank/ 
*/

WITH "CALL gds.articleRank.stream(
    'flights_proj_part_4',
    {
        dampingFactor: 0.75,
        maxIterations: 25,
        scaler: 'Mean'
    }
)
YIELD
    nodeId,
    score
RETURN
    gds.util.asNode(nodeId).airport_code AS Airport,
    score AS Article_Rank_Score" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/4/article_rank_mean_scaler.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;

// ############################################################################################################
// #################################  Article Rank (Log Scaler)  ##############################################
// ############################################################################################################

/*
https://neo4j.com/docs/graph-data-science/current/algorithms/article-rank/ 
*/

WITH "CALL gds.articleRank.stream(
    'flights_proj_part_4',
    {
        dampingFactor: 0.75,
        maxIterations: 25,
        scaler: 'Log'
    }
)
YIELD
    nodeId,
    score
RETURN
    gds.util.asNode(nodeId).airport_code AS Airport,
    score AS Article_Rank_Score" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/4/article_rank_log_scaler.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;

// ############################################################################################################
// #################################  Article Rank (StdScore Scaler)  #########################################
// ############################################################################################################

*/
https://neo4j.com/docs/graph-data-science/current/algorithms/article-rank/ 
*/

WITH "CALL gds.articleRank.stream(
    'flights_proj_part_4',
    {
        dampingFactor: 0.75,
        maxIterations: 25,
        scaler:  'StdScore'
    }
)
YIELD
    nodeId,
    score
RETURN
    gds.util.asNode(nodeId).airport_code AS Airport,
    score AS Article_Rank_Score" AS query
CALL apoc.export.csv.query(query, "Neo4j/exports/4/article_rank_std_score_scaler.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;