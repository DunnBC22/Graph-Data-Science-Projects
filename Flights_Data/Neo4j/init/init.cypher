// Clear any existing data
MATCH (n) DETACH DELETE n;

// Load data from csv file
LOAD CSV WITH HEADERS FROM 'file:///data.csv' AS row
WITH toInteger(row.origin_airport_id) AS origin, toInteger(row.dest_airport_id) AS dest, row
MERGE (o:Airport {id: origin})
MERGE (d:Airport {id: dest})
CREATE (o)-[:FLIGHT {
    tail_number: row.tail_number,
    flight_number: toInteger(row.flight_number),
    airline_id: toInteger(row.airline_id),
    flight_distance: toInteger(row.flight_distance),
    departure_datetime: datetime(row.departure_datetime),
    arrival_datetime: datetime(row.arrival_datetime)
}]->(d);