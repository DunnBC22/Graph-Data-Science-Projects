// Introductory Commands
RETURN gds.version(); # Return the installed graph data science library version.
CALL gds.version(); # Return the installed graph data science library version.

CALL gds.systemMonitor() # Get an overview of the system's workload and available resources

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

// Return a list of the unique Airline Codes & Names

MATCH 
    ()-[f:FLIGHT]->() 
RETURN 
    DISTINCT 
        f.airline_code AS AirlineCode, 
        f.airline_name AS AirlineName;

// show 12 Airports and their data
MATCH (a:Airport) 
RETURN 
    a.airport_code AS AirportCode,
    a.airport_name AS AirportName,
    a.airport_city AS City,
    a.airportState_code AS StateShorthand,
    a.airportState_name AS StateName;

// Check Other information
CALL db.labels();
CALL db.relationshipTypes();
CALL gds.graph.list();

// Return the Number of Flights 
//  - for Each Carrier
MATCH 
    ()-[f:FLIGHT]->() 
RETURN 
    f.airline_name AS Airline, 
    f.airline_code AS AirlineCode, 
    COUNT(*) AS Number_of_Flights;

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








// Display Full (Relevant) Flight Details for 250 flights

MATCH (a1:Airport)-[r:FLIGHT]->(a2:Airport) 
RETURN 
    a1.airport_name AS OriginAirport,
    r.airline_name AS Airline,
    r.flight_number AS FlightNumber, 
    r.flight_distance AS FlightDistance,
    r.departure_datetime AS ScheduledDepartTime,
    r.arrival_datetime AS ScheduledArrivalTime,
    a2.airport_name AS DestinationAirport
LIMIT 250;

// Calculate & Display the duration of each of the flights (return only 250 results to keep it manageable)

MATCH (a1:Airport)-[r:FLIGHT]->(a2:Airport)
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
LIMIT 250;

// -- Count of how many flights originate at each airport
MATCH 
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
ORDER BY FlightCount DESC;

// -- Count Flights Originating from Each Airport by Airline
MATCH 
    (origin:Airport)-[f:FLIGHT]->(:Airport)
WITH
    origin.airport_code AS AirportCode,
    f.airline_name AS Airline,
    COUNT(*) AS FlightCount
RETURN 
    AirportCode,
    Airline,
    FlightCount
ORDER BY FlightCount DESC;






// -- Count of how many flights arrive at each airport
MATCH 
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
ORDER BY FlightCount DESC;

// -- Count Flights Originating from Each Airport by Airline
MATCH 
    (:Airport)-[f:FLIGHT]->(dest:Airport)
WITH
    dest.airport_code AS AirportCode,
    f.airline_name AS Airline,
    COUNT(*) AS FlightCount
RETURN 
    AirportCode,
    Airline,
    FlightCount
ORDER BY FlightCount DESC;


// Prepare data to create graph projection
// Convert timestamps to epoch (milliseconds since 1970)
MATCH
    ()-[f:FLIGHT]->()
SET
    f.departure_timestamp_ms = duration.between(datetime('1970-01-01T00:00:00Z'), datetime(f.departure_datetime)).milliseconds
SET
    f.arrival_timestamp_ms = duration.between(datetime('1970-01-01T00:00:00Z'), datetime(f.arrival_datetime)).milliseconds
RETURN
    f.departure_timestamp_ms,
    f.arrival_timestamp_ms;


// Create the Graph Projection
// drop graph projection (if it exists)


CALL gds.graph.exists('flights_proj') YIELD exists
WITH exists
WHERE exists
CALL gds.graph.drop('flights_proj') YIELD graphName
RETURN 'Graph dropped' AS result;

// Create the graph projection
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




// --- Shortest Path ---


// Dijkstra Source Shortest Path (to determine the shortest path between MKE & each and every other airport)
MATCH (n:Airport {airport_code: 'MKE'})
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
WHERE Origin <> Destination // Exclude paths where the origin is the same as the destination
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
ORDER BY TotalCost ASC;




// Dijkstra Source-Target Shortest Path
//  - this algorithm computes the shortest path between nodes. It supports weighted graphs with positive relationship weights. The Dijkstra Source-Target algorithm computes the shortest path between a source and a list of target nodes. To compute all paths from a source node to all reachable nodes, Dijkstras Single-Source can be used.
//  - https://neo4j.com/docs/graph-data-science/current/algorithms/dijkstra-source-target/
MATCH (n:Airport {airport_code: 'LGA'})
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
    Path;




// gds.bellmanFord.stream
// - https://neo4j.com/docs/graph-data-science/current/algorithms/bellman-ford-single-source/
CALL gds.bellmanFord.stream(
  graphName: String,
  configuration: Map
)
YIELD
  index: Integer,
  sourceNode: Integer,
  targetNode: Integer,
  totalCost: Float,
  nodeIds: List of Integer,
  costs: List of Float,
  route: Path,
  isNegativeCycle: Boolean

// gds.shortestPath.astar.stream
// - https://neo4j.com/docs/graph-data-science/current/algorithms/astar/

CALL gds.shortestPath.astar.stream(
  graphName: String,
  configuration: Map
)
YIELD
  index: Integer,
  sourceNode: Integer,
  targetNode: Integer,
  totalCost: Float,
  nodeIds: List of Integer,
  costs: List of Float,
  path: Path

// gds.shortestPath.yens.stream
// - https://neo4j.com/docs/graph-data-science/current/algorithms/yens/

CALL gds.shortestPath.yens.stream(
  graphName: String,
  configuration: Map
)
YIELD
  index: Integer,
  sourceNode: Integer,
  targetNode: Integer,
  totalCost: Float,
  nodeIds: List of Integer,
  costs: List of Float,
  path: Path


// gds.allShortestPaths.delta.stream
// - https://neo4j.com/docs/graph-data-science/current/algorithms/delta-single-source/

CALL gds.allShortestPaths.delta.stream(
  graphName: String,
  configuration: Map
)
YIELD
  index: Integer,
  sourceNode: Integer,
  targetNode: Integer,
  totalCost: Float,
  nodeIds: List of Integer,
  costs: List of Float,
  path: Path


// --- Community Detection ---

// K-Means Clustering 
//  - it is an unsupervised learning algorithm that is used to solve clustering problems. It follows a simple procedure of classifying a given data set into a number of clusters, defined by the parameter k. The Neo4j GDS library conducts clustering based on node properties. 
//  - https://neo4j.com/docs/graph-data-science/current/algorithms/kmeans/

CALL gds.kmeans.stream(
  'flights_proj',
    {
        k: 12,
        maxIterations: 12,
        deltaThreshold: 0.25,
        numberOfRestarts: 3,
        randomSeed: 42,
        initialSampler: "kmeans++", // the other option is "uniform"
        computeSilhouette: true
    }
)
YIELD
    nodeId AS NodeId,
    communityId AS CommunityId,
    distanceFromCentroid AS DistanceFromCentroid,
    silhouette AS SilhouetteScore

// Label Propagation 
//  - This is a fast algorithm for finding communities in a graph. It detects these communities using network structure 
//    alone as its guide, and does not require a pre-defined objective function or prior information about the communities. 
//  - https://neo4j.com/docs/graph-data-science/current/algorithms/label-propagation/


CALL gds.labelPropagation.stream(
    'flights_proj',
    {
        maxIterations: 12,
        minCommunitySize: 5
    }
)
YIELD
    nodeId AS NodeId,
    communityId AS CommunityId

// Local Clustering Coefficient
//  - This algorithm computes the local clustering coefficient for each node in the graph. The local clustering coefficient of a node describes the likelihood that the neighbors of it are also connected. 
//  - https://neo4j.com/docs/graph-data-science/current/algorithms/local-clustering-coefficient/#algorithms-local-clustering-coefficient-syntax

CALL gds.localClusteringCoefficient.stream(
    'flights_proj',
    {
        maxIterations: 12,
        minCommunitySize: 5
    }
)
YIELD
    nodeId AS NodeId,
    localClusteringCoefficient AS LocalClusteringCoefficient

// Louvain Modularity
//  - This algorithm detects communities in large networks. It maximizes a modularity score for each community, where the modularity quantifies the quality of an assignment of nodes to communities. This means that evaluating how much more densely connected the nodes within a community are, compared to how connected they would be in a random network.  It is a hierarchical clustering algorithm, that recursively merges communities into a single node and executes the modularity clustering on the condensed graphs. 
//  - https://neo4j.com/docs/graph-data-science/current/algorithms/louvain/

CALL gds.louvain.stream(
    'flights_proj',
    {
        maxLevels: 12,
        maxIterations: 15
    }
)
YIELD
    nodeId AS NodeId,
    communityId AS CommunityId,
    intermediateCommunityIds AS IntermediateCommunityIds;

// Strongly Connected Components
//  - This algorithm finds maximal sets of connected  nodes in a directed graph. A set is considered a stronly connected component if there is a directed path between each pair of nodes within the set. It is often used early in a graph analysis process to help us get an idea of how our graph is structured.
//  - https://neo4j.com/docs/graph-data-science/current/algorithms/strongly-connected-components/

CALL gds.scc.stream(
    'flights_proj'
)
YIELD
    nodeId AS NodeId,
    componentId AS ComponentId;






// gds.modularity.stream


// - https://neo4j.com/docs/graph-data-science/current/algorithms/modularity/


// gds.conductance.stream

// - https://neo4j.com/docs/graph-data-science/current/algorithms/conductance/



-- Centrality & Importance --


// gds.influenceMaximization.celf.stream

// - https://neo4j.com/docs/graph-data-science/current/algorithms/celf/


CALL gds.influenceMaximization.celf.stream(
  graphName: String,
  configuration: Map
)
YIELD
  nodeId: Integer,
  spread: Float




// gds.bridges.stream

// - https://neo4j.com/docs/graph-data-science/current/algorithms/bridges/


CALL gds.bridges.stream(
  graphName: String,
  configuration: Map
)
YIELD
  from: Integer,
  to: Integer


// gds.articulationPoints.stream
// - https://neo4j.com/docs/graph-data-science/current/algorithms/articulation-points/

CALL gds.articulationPoints.stream(
  graphName: String,
  configuration: Map
)
YIELD
  nodeId: Integer


// Degree Centrality
//  - This algorithm can be used to find popular nodes within a graph. Degree centrality measures the number of incoming or outgoing (or both) relationships from a node, depending on the orientation of a relationship projection.  It can be applied to either weighted or unweighted graphs. In the weighted case, the algorithm computes the sum of all positive weights of adjacent relationships of a node, for each node in the graph. Non-positive weights are ignored. 
//  - https://neo4j.com/docs/graph-data-science/current/algorithms/degree-centrality/

CALL gds.degree.stream(
    'flights_proj',
    {
        orientation: "NATURAL"
    }
) YIELD
    nodeId AS NodeId,
    score AS DegreeCentralityScore;

// Closeness Centrality 
- It is a way of detecting nodes that are able to spread information very efficiently through a graph. The closeness centrality of a node measures it average fatness (inverse distance) to all other nodes. Nodes with a high closeness score have the shortest distances to all other nodes. 
- https://neo4j.com/docs/graph-data-science/current/algorithms/closeness-centrality/

CALL gds.closeness.stream(
    'flights_proj',
    {
        useWassermanFaust: true
    }
)
YIELD
    nodeId AS NodeId,
    score AS ClosenessCentralityScore

// Betweenness Centrality (& Approximation)
//  - It is a way of detecting the amount of influence a node has over the flow of information in a graph. It is often used to find nodes that serve as a bridge from one part of a graph to another. The algorithm calculates shortest paths between all pairs of nodes in a graph. Each node receives a score, based on the number of shortest paths that pass through the node. Nodes that more frequently lie on shortest paths between other nodes will have higher betweenness centrality scores. 
//  - https://neo4j.com/docs/graph-data-science/current/algorithms/betweenness-centrality/

CALL gds.betweenness.stream(
    'flights_proj',
    {
        samplingSeed: 42
    }
)
YIELD
    nodeId AS NodeId,
    score AS BetweennessCentralityScore

// PageRank 
//  - The PageRank algorithm measures the importance of each node within the graph, based on the number of incoming relationships and the importance of the corresponding source nodes. The underlying assumption roughly speaking is that a page is only as important the pages that link to it. 
//  - https://neo4j.com/docs/graph-data-science/current/algorithms/page-rank/

CALL gds.pageRank.stream(
    'flights_proj',
    {
        dampingFactor: 0.75,
        maxIterations: 25,
        sourceNodes: , //need to complete this line
        scaler: // Available options are: None, MinMax, Max, Mean, Log, and StdScore
    }
)
YIELD
    nodeId AS NodeId,
    score AS Page_RankScore

// ArticleRank
//  - This is a variant of the Page Rank algorithm, which measures the transitive influence of nodes. It follows the assumption that relationships originating from low-degree nodes have a higher influence than relationships from high-degree nodes. Article Rank lowers the influence of low-degree nodes by lowering the scores being sent to their neighbors in each iteration. 
//  - https://neo4j.com/docs/graph-data-science/current/algorithms/article-rank/ 

CALL gds.articleRank.stream(
    'flights_proj',
    {
        dampingFactor: 0.75,
        maxIterations: 25,
        scaler:  // Available options are: None, MinMax, Max, Mean, Log, and StdScore
    }
)
YIELD
    nodeId AS NodeId,
    score AS Article_RankScore






// --- Similarity ---

// Node Similarity
//  - This algorithm is based on the Jaccard and Overlap similarity metrics. It compares a set of nodes based on the nodes they are connected. Two nodes are considered similar if they share many of the same neighbors. Node similarity computes pair-wise similarities based on the Jaccard metric, Overlap Metric, and the Cosine Metric. The first two are most frequently assocated with unweighted sets, whereas Cosine is associated with weighted input.
//  - https://neo4j.com/docs/graph-data-science/current/algorithms/node-similarity/

// Combine Jaccard, Overlap, and Cosine Node Similarities
CALL gds.nodeSimilarity.stream(
    'flights_proj',
    {
        similarityMetric: 'JACCARD'
    }
) YIELD
    node1 AS Airport1,
    node2 AS Airport2,
    similarity AS Similarity
RETURN
    Airport1, Airport2, Similarity, 'JACCARD' AS Metric
UNION ALL
CALL gds.nodeSimilarity.stream(
    'flights_proj',
    {
        similarityMetric: 'OVERLAP'
    }
) YIELD
    node1 AS Airport1,
    node2 AS Airport2,
    similarity AS Similarity
RETURN
    Airport1, Airport2, Similarity, 'OVERLAP' AS Metric
UNION ALL
CALL gds.nodeSimilarity.stream(
    'flights_proj',
    {
        similarityMetric: 'COSINE'
    }
) YIELD
    node1 AS Airport1,
    node2 AS Airport2,
    similarity AS Similarity
RETURN
    Airport1, Airport2, Similarity, 'COSINE' AS Metric;

------------------------------ OR ------------------------------

// Aggregate Jaccard, Overlap, and Cosine similarities into one result
MATCH (n)
CALL {
    WITH n
    CALL gds.nodeSimilarity.stream(
        'flights_proj',
        { similarityMetric: 'JACCARD' }
    )
    YIELD node1, node2, similarity
    RETURN gds.util.asNode(node1).code AS Airport1,
           gds.util.asNode(node2).code AS Airport2,
           similarity AS JaccardSimilarity
}
WITH Airport1, Airport2, JaccardSimilarity
CALL {
    WITH Airport1, Airport2
    CALL gds.nodeSimilarity.stream(
        'flights_proj',
        { similarityMetric: 'OVERLAP' }
    )
    YIELD node1, node2, similarity
    WHERE gds.util.asNode(node1).code = Airport1 AND gds.util.asNode(node2).code = Airport2
    RETURN similarity AS OverlapSimilarity
}
WITH Airport1, Airport2, JaccardSimilarity, OverlapSimilarity
CALL {
    WITH Airport1, Airport2
    CALL gds.nodeSimilarity.stream(
        'flights_proj',
        { similarityMetric: 'COSINE' }
    )
    YIELD node1, node2, similarity
    WHERE gds.util.asNode(node1).code = Airport1 AND gds.util.asNode(node2).code = Airport2
    RETURN similarity AS CosineSimilarity
}
RETURN Airport1, Airport2, JaccardSimilarity, OverlapSimilarity, CosineSimilarity;




----------------------------------------------------------------

gds.similarity.overlap	RETURN gds.similarity.overlap(vector1, vector2)  \\ - Given two collection vectors, calculate overlap similarity	\\ gds.similarity.overlap(vector1 :: LIST<INTEGER | FLOAT>, vector2 :: LIST<INTEGER | FLOAT>) :: FLOAT
gds.similarity.pearson	RETURN gds.similarity.pearson(vector1, vector2)  \\ - Given two collection vectors, calculate pearson similarity	\\ gds.similarity.pearson(vector1 :: LIST<INTEGER | FLOAT>, vector2 :: LIST<INTEGER | FLOAT>) :: FLOAT


// K-Nearest Neighbors (KNN) Similarity
//      - The KNN algorithm computes a distance value for all node pairs in the graph and creates new relationships between each node and its k nearest neighbors The distance is calculated based on node properties.
//      - https://neo4j.com/docs/graph-data-science/current/algorithms/knn/

CALL gds.knn.stream(
    'flights_proj',
    {
        topK: 5,
        sampleRate: 0.50,
        deltaThreshold: 0.005,
        maxIterations: 125,
        randomJoins: 12,
        initialSampler: "uniform",
        similarityCutoff: 0,
        perturbationRate: 0.10
    }
) YIELD
    node1 AS Airport1,
    node2 AS Airport2,
    similarity AS SimilarityScore





// Model Cleanup


gds.model.store	Store the selected model to disk.	gds.model.store(modelName :: STRING, failIfUnsupported = true :: BOOLEAN) :: (modelName :: STRING, storeMillis :: INTEGER)


if // gds.model.exists	Checks if a given model exists in the model catalog.	gds.model.exists(modelName :: STRING) :: (modelName :: STRING, modelType :: STRING, exists :: BOOLEAN)
gds.model.delete # Deletes a stored model from disk. gds.model.delete(modelName :: STRING) :: (modelName :: STRING, deleteMillis :: INTEGER)


if //gds.graph.drop	Drops a named graph from the catalog and frees up the resources it occupies.	gds.graph.drop(graphName :: ANY, failIfMissing = true :: BOOLEAN, dbName =  :: STRING, username =  :: STRING) :: (graphName :: STRING, database :: STRING, databaseLocation :: STRING, memoryUsage :: STRING, sizeInBytes :: INTEGER, nodeCount :: INTEGER, relationshipCount :: INTEGER, configuration :: MAP, density :: FLOAT, creationTime :: ZONED DATETIME, modificationTime :: ZONED DATETIME, schema :: MAP, schemaWithOrientation :: MAP)
gds.graph.exists // Checks if a graph exists in the catalog.	gds.graph.exists(graphName :: STRING) :: (graphName :: STRING, exists :: BOOLEAN)