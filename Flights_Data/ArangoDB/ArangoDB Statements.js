// // Gremlin (some algorithms require using NetworkX)

// /*

// Algorithms Page for Analytics in NetworkX: https://networkx.org/documentation/stable/reference/index.html

// Algorithm Categories to consider:
// - Assortativity
//     - Assortativity
//         - degree_assortativity_coefficient,
//         - attribute_assortativity_coefficient
//         - numeric_assortativity_coefficient(G, attribute)
//         - degree_pearson_correlation_coefficient
//     - Average Neighbor Degree
//         - average_neighbor_degree
//     - Average Degree Connectivity
//         - average_degree_connectivity
//     - Miing
//         - attribute_mixing_matrix
//         - degree_mixing_matrix
//         - attribute_mixing_dict
//         - degree_mixing_dict
//         - mixing_dict
//     - Pairs
//         - node_attribute_xy(G, attribute[, nodes])
//         - node_degree_xy
// - Bridges
//     - bridges
//     - has_bridges
//     - local_bridges
// - Centrality
//     - Degree
//         - degree_centrality
//         - in_degree_centrality
//         - out_degree_centrality
//     - Eigenvector
//         - eigenvector_centrality
//         - eigenvector_centrality_numpy
//         - katz_centrality
//         - katz_centrality_numpy
//     - Closeness
//         - closeness_centrality
//         - incremental_closeness_centrality
//     - Current Flow Closeness
//         - current_flow_closeness_centrality
//         - information_centrality
//     - (Shortest Path) Betweenness
//         - betweenness_centrality
//         - betweenness_centrality_subset
//         - edge_betweenness_centrality
//         - edge_betweenness_centrality_subset
//     - Current Flow Betweenness
//         - current_flow_betweenness_centrality
//         - edge_current_flow_betweenness_centrality
//         - approximate_current_flow_betweenness_centrality
//         - current_flow_betweenness_centrality)subset
//         - edge_current_flow_betweenness_centrality_subset
//     - Communicability Betweenness
//         - communicability_betweenness_centrality
//     - Group Centrality
//         - group_betweenness_centrality
//         - group_closeness_centrality
//         - group_degree_centrality
//         - group_in_degree_centrality
//         - group_out_degree_centrality
//         - prominent_group
//     - Load
//         - load_centrality
//         - edge_load_centrality
//     - Subgraph
//         - subgraph_centrality
//         - subgraph_centrality_exp
//         - estrada_index
//     - Harmonic Centrality
//         - harmonic_centrality
//     - Dispersion
//         - dispersion
//     - Reaching
//         - local_reaching_centrality
//         - global_reaching_centrality
//     - Percolation
//         - percolation_centrality
//     - Second Order Centrality
//         - second_order_centrality
//     - Trophic
//         - trophic_levels
//         - trophic_differences
//         - trophic_incoherence_parameter
//     - VoteRank
//         -voterank
//     - Laplacian
//         - laplacian_centrality
// - Chains
//     - chain_decomposition
// - Clustering
//     - triangles
//     - transitivity
//     - clustering
//     - average_clustering
//     - square_clustering
//     - generalized_degree
// - Communicability
//     - communicability
//     - communicability_exp
// - Communities
//     - bipartitions
//     - Divisive Communities
//         - edge_betweenness_partition
//         - edge_current_flow_betweenness_partition
//     - K-Clique
//         - k_clique_communities
//     - Modularity-Based Communities
//         - greedy_modularity_communities
//         - naive_greedy_modularity_communities
//     - Label Propagation
//         - asyn_lpa_communities
//         - label_propagation_communities
//         - fast_label_propagation_communities
//     - Louvain Community Detection
//         - louvain_communities
//         - louvain_partitions
//     - Fluid Communities
//         - async_fluidc
//     - Measuring Partitions
//         - modularity
//         - partition_quality
//     - Partitions via Centrality Measures
//         - girvan_newman
//     - Validating Partitions (more or less a checksum or utility-like function)
//         is_partition
// - Components
//     - Connectivity
//         - is_connected
//         - number_connected_components
//         - connected_components
//         - node_connected
//     - Strong Connectivity
//         - is_strongly_connected
//         - number_strongly_connected_components
//         - strongly_connected_components
//         - kosaraju_strongly_connected_components
//         - condensation
//     - Weak Connectivity
//         - is_weakly_connected
//         - number_weakly_connected_components
//         - weakly_connected_components
//     - Attracting Components 
//         - is_attracting_component
//         - number_attracting_components
//         - attracting_components
//     - Semiconnectedness
//         -  is_semiconnected
// - Connectivity
//     - Also See
//         - k_edge_augmentation
//         - is_k_edge_connected
//         - is_locally_k_edge_connected
//     - k-edge-components
//         - k_edge_components
//         - k_edge_subgraphs
//         - bridge_components
//         - EdgeComponentAuxGraph
//     - k-node-components
//         - k_components
//     - k-node-cutsets
//         - all_node_cuts
//     - Flow-Based Disjoint Paths
//         - edge_disjoint_paths
//         - node_disjoint_paths
//     - Flow-Based Connectivity
//         - average_node_connectivity
//         - all_pairs_node_connectivity
//         - edge_connectivity
//         - local_edge_connectivity
//         - local_node_connectivity
//         - node_connectivity
//     - Flow-Based Minimum Cuts
//         - minimum_edge_cut
//         - minimum_node_cut
//         - minimum_st_edge_cut
//         - minimum_st_node_cut
//     - Stoer-Wagner Minimum Cut
//         - stoer_wagner
//     - Utilities for Flow-based Connectivity
//         - build_auxiliary_edge_connectivity
//         - build_auxiliary_node_connectivity
// - Cores
//     - core_number
//     - k_core
//     - k_shell
//     - k_crust
//     - k_corona
//     - k_truss
//     -  onion_layers
// - Cycles
//     - cycle_basis
//     - simple_cycles
//     - recursive_simple_cycles
//     - find_cycle
//     - minimum_cycle_basis
//     - chordless_cycles
//     - girth
// - Cuts
//     - boundary_expansion
//     - conductance
//     - cut_size
//     - edge_expansion
//     - mixing_expansion
//     - node_expansion
//     - normalized_cut_size
//     - volume
// - Distance Measures
//     - barycenter
//     - center
//     - diameter
//     - harmonic_diameter
//     - eccentricity
//     - effective_graph_resistance
//     - kemeny_constant
//     - periphery
//     - radius
//     - resistance_distance
// - Distance-Regular Graphs
//     - is_distance_regular
//     - is_strongly_regular
//     - intersection_array
//     - global_parameters
// - Dominating Sets
//     - immediate_dominators
//     - dominance_frontiers
// - Efficiency
//     - efficiency
//     - local_efficiency
//     - global_efficiency
// - Link Analysis
//     - PageRanks
//         - pagerank
//         - google_matrix
//     - Hits
//         - hits
// - Link Prediction
//     - resource_allocation_index
//     - jaccard_coefficient
//     - adamic_adar_index
//     - preferential_attachment
//     - cn_soundarajan_hopcroft
//     - ra_index_soundarajan_hopcroft
//     - within_inter_cluster
//     - common_neighbor_centrality
// - Regular
//     - is_regular
//     - is_k_regular
//     - k_factor
// - Rich Club
//     - rich_club_coefficient
// - Shortest Paths
//     - Main
//         - shortest_path
//         - all_shortest_paths
//         - all_pairs_all_shortest_path
//         - single_source_all_shortest_paths
//         - shortest_path_length
//         - average_shortest_path_length
//         - has_path
//     - Advanced Interface 
//         - shortest path algorithms for unweighted graphs
//             - single_source_shortest_path
//             - single_source_shortest_path_length
//             - single_target_shortest_path
//             - single_target_shortest_path_length
//             - bidirectional_shortest_path
//             - all_pairs_shortest_path
//             - all_pairs_shortest_path_length
//             - predecessor
//         - shortest path algorithms for weighted graphs
//             - dijkstra_predecessor_and_distance
//             - dijkstra_path
//             - dijkstra_path_length
//             - single_source_dijkstra
//             - single_source_dijkstra_path
//             - single_source_dijkstra_path_length
//             - multi_source_dijkstra
//             - multi_source_dijkstra_path
//             - multi_source_dijkstra_path_length
//             - all_pairs_dijkstra
//             - all_pairs_dijkstra_path
//             - all_pairs_dijkstra_path_length
//             - bidirectional_dijkstra
//             - bellman_ford_path
//             - bellman_ford_path_length
//             - single_source_bellman_ford
//             - single_source_bellman_ford_path
//             - single_source_bellman_ford_path_length
//             - all_pairs_bellman_ford_path
//             - all_pairs_bellman_ford_path_length
//             - bellman_ford_predecessor_and_distance
//             - negative_edge_cycle
//             - find_negative_cycle
//             - goldberg_radzik
//             - johnson
//     - Dense Graphs
//         - floyd_warshall
//         - floyd_warshall_predecessor_and_distance
//         - floyd_warshall_numpy
//         - reconstruct_path
//     - A* Algorithms
//         - astar_path
//         - astar_path_length
// - Similarity Measures
//     - graph_edit_distance
//     - optimal_edit_paths
//     - optimize_graph_edit_distance
//     - optimize_edit_paths
//     - simrank_similarity
//     - panther_similarity
//     - generate_random_paths
// - Simple Paths (would this work for all paths between two airports???)
//     - all_simple_paths
//     - all_simple_edge_paths
//     - is simple_paths
//     - shortest_simple_paths
// - Small-World
//     - random_reference
//     - lattice_reference
//     - sigma
//     - omega
// - s_metric
//     - s_metric
// - Structural Holes
//     - constraint
//     - effective_size
//     - local_constraint
// - Summarization
//     - dedensify
//     - snap_aggregation
// - Traversals
//     - Depth First Search
//         - dfs_edges
//         - dfs_tree
//         - dfs_predecessors
//         - dfs_successors
//         - dfs_preorder_nodes
//         - dfs_postorder_nodes
//         - dfs_labeled_edges
//     - Breadth First Search
//         - bfs_edges
//         - bfs_layers
//         - bfs_tree
//         - bfs_predecessors
//         - bfs_successors
//         - descendants_at_distance
//         - generic_bfs_edges
//     - Beam Search
//         - bfs_beam_edges
//     - Depth First Search on Edges
//         - edge_dfs
//     - Breadth First Search on Edges
//         - edge_bfs
// - Triads
//     - triadic_census
//     - random_triad
//     - triads_by_type
//     - triad_type
//     - is_triad
//     - all_triads
//     - all_triplets
// - Vitality
//     - closeness_vitality
// - Walks
//     - number_of_walks
// - Clique
//     - enumerate_all_classes
//     - find_clique
//     - find_cliques_recursive
//     - make_max_clique_graph
//     - make_clique_bipartite
//     - node_clique_number
//     - number_of_cliques
//     - max_weight_clique

// */



// // Create a MultiDiGraph


// docker exec -it arangodb_container bash

// arangoimport --file /import/airports.csv --type csv --collection airports --create-collection true

// arangoimport --file /import/data.csv --type csv --collection flights --create-collection true --create-collection-type edge






// /*
// MultiDiGraph—Directed graphs with self loops and parallel edges
// Overview
// class MultiDiGraph(incoming_graph_data=None, multigraph_input=None, **attr)[source]
// A directed graph class that can store multiedges.

// Multiedges are multiple edges between two nodes. Each edge can hold optional data or attributes.

// A MultiDiGraph holds directed edges. Self loops are allowed.

// Nodes can be arbitrary (hashable) Python objects with optional key/value attributes. By convention None is not used as a node.

// Edges are represented as links between nodes with optional key/value attributes.

// Parameters:
// incoming_graph_data
// input graph (optional, default: None)
// Data to initialize graph. If None (default) an empty graph is created. The data can be any format that is supported by the to_networkx_graph() function, currently including edge list, dict of dicts, dict of lists, NetworkX graph, 2D NumPy array, SciPy sparse matrix, or PyGraphviz graph.

// multigraph_input
// bool or None (default None)
// Note: Only used when incoming_graph_data is a dict. If True, incoming_graph_data is assumed to be a dict-of-dict-of-dict-of-dict structure keyed by node to neighbor to edge keys to edge data for multi-edges. A NetworkXError is raised if this is not the case. If False, to_networkx_graph() is used to try to determine the dict’s graph data structure as either a dict-of-dict-of-dict keyed by node to neighbor to edge data, or a dict-of-iterable keyed by node to neighbors. If None, the treatment for True is tried, but if it fails, the treatment for False is tried.

// attr
// keyword arguments, optional (default= no attributes)
// Attributes to add to graph as key=value pairs.

// Examples

// Create an empty graph structure (a “null graph”) with no nodes and no edges.

// G = nx.MultiDiGraph()
// G can be grown in several ways.

// Nodes:

// Add one node at a time:

// G.add_node(1)
// Add the nodes from any container (a list, dict, set or even the lines from a file or the nodes from another graph).

// G.add_nodes_from([2, 3])
// G.add_nodes_from(range(100, 110))
// H = nx.path_graph(10)
// G.add_nodes_from(H)
// In addition to strings and integers any hashable Python object (except None) can represent a node, e.g. a customized node object, or even another Graph.

// G.add_node(H)
// Edges:

// G can also be grown by adding edges.

// Add one edge,

// key = G.add_edge(1, 2)
// a list of edges,

// keys = G.add_edges_from([(1, 2), (1, 3)])
// or a collection of edges,

// keys = G.add_edges_from(H.edges)
// If some edges connect nodes not yet in the graph, the nodes are added automatically. If an edge already exists, an additional edge is created and stored using a key to identify the edge. By default the key is the lowest unused integer.

// keys = G.add_edges_from([(4, 5, dict(route=282)), (4, 5, dict(route=37))])
// G[4]
// AdjacencyView({5: {0: {}, 1: {'route': 282}, 2: {'route': 37}}})
// Attributes:

// Each graph, node, and edge can hold key/value attribute pairs in an associated attribute dictionary (the keys must be hashable). By default these are empty, but can be added or changed using add_edge, add_node or direct manipulation of the attribute dictionaries named graph, node and edge respectively.

// G = nx.MultiDiGraph(day="Friday")
// G.graph
// {'day': 'Friday'}
// Add node attributes using add_node(), add_nodes_from() or G.nodes

// G.add_node(1, time="5pm")
// G.add_nodes_from([3], time="2pm")
// G.nodes[1]
// {'time': '5pm'}
// G.nodes[1]["room"] = 714
// del G.nodes[1]["room"]  # remove attribute
// list(G.nodes(data=True))
// [(1, {'time': '5pm'}), (3, {'time': '2pm'})]
// Add edge attributes using add_edge(), add_edges_from(), subscript notation, or G.edges.

// key = G.add_edge(1, 2, weight=4.7)
// keys = G.add_edges_from([(3, 4), (4, 5)], color="red")
// keys = G.add_edges_from([(1, 2, {"color": "blue"}), (2, 3, {"weight": 8})])
// G[1][2][0]["weight"] = 4.7
// G.edges[1, 2, 0]["weight"] = 4
// Warning: we protect the graph data structure by making G.edges[1, 2, 0] a read-only dict-like structure. However, you can assign to attributes in e.g. G.edges[1, 2, 0]. Thus, use 2 sets of brackets to add/change data attributes: G.edges[1, 2, 0]['weight'] = 4 (for multigraphs the edge key is required: MG.edges[u, v, key][name] = value).

// Shortcuts:

// Many common graph features allow python syntax to speed reporting.

// 1 in G  # check if node in graph
// True
// [n for n in G if n < 3]  # iterate through nodes
// [1, 2]
// len(G)  # number of nodes in graph
// 5
// G[1]  # adjacency dict-like view mapping neighbor -> edge key -> edge attributes
// AdjacencyView({2: {0: {'weight': 4}, 1: {'color': 'blue'}}})
// Often the best way to traverse all edges of a graph is via the neighbors. The neighbors are available as an adjacency-view G.adj object or via the method G.adjacency().

// for n, nbrsdict in G.adjacency():
//     for nbr, keydict in nbrsdict.items():
//         for key, eattr in keydict.items():
//             if "weight" in eattr:
//                 # Do something useful with the edges
//                 pass
// But the edges() method is often more convenient:

// for u, v, keys, weight in G.edges(data="weight", keys=True):
//     if weight is not None:
//         # Do something useful with the edges
//         pass
// */


// /*
// Run some of these:

// - subgraph_view
// - networkx.classes.coreviews.AtlasView
// - networkx.classes.coreviews.AdjacencyView
// - networkx.classes.coreviews.FilterAtlas
// - networkx.classes.coreviews.FilterAdjacency
// - 

// */