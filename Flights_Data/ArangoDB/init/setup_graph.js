'use strict';

const db = require('@arangodb').db;
const fs = require('fs');
const graphModule = require('@arangodb/general-graph');

// Define collections
const nodesCollection = 'airports';
const edgesCollection = 'flights';

// Define graph name and edge definitions
const graphName = 'flightGraph';
const edgeDefinitions = [
  {
    collection: edgesCollection,
    from: [nodesCollection],
    to: [nodesCollection]
  }
];

// Create collections if they don't exist
if (!db._collection(nodesCollection)) {
  db._create(nodesCollection);
}
if (!db._collection(edgesCollection)) {
  db._createEdgeCollection(edgesCollection);
}

// Create graph if it doesn't exist
if (!graphModule._exists(graphName)) {
  graphModule._create(graphName, edgeDefinitions);
}

// Helper function: Parse CSV content
function parseCSV(content) {
  const lines = content.trim().split('\n');
  const headers = lines[0].split(',').map(h => h.trim());
  return lines.slice(1).map(line => {
    const values = line.split(',').map(v => v.trim());
    return headers.reduce((obj, header, index) => {
      obj[header] = values[index];
      return obj;
    }, {});
  });
}

// Import nodes
const nodesContent = fs.read('/import/airports.csv');
const nodesData = parseCSV(nodesContent);
const uniqueIdToKeyMap = {}; // Map unique_id -> _key
nodesData.forEach(node => {
  const savedNode = db[nodesCollection].save(node);
  uniqueIdToKeyMap[node.unique_id] = savedNode._key;
});

// Import edges
const edgesContent = fs.read('/import/data.csv');
const edgesData = parseCSV(edgesContent);
edgesData.forEach(edge => {
  const fromKey = uniqueIdToKeyMap[edge.origin_airport_id];
  const toKey = uniqueIdToKeyMap[edge.dest_airport_id];
  
  if (fromKey && toKey) {
    db[edgesCollection].save({
      _from: `${nodesCollection}/${fromKey}`,
      _to: `${nodesCollection}/${toKey}`,
      ...edge
    });
  } else {
    console.warn(`Skipping edge due to missing nodes: origin=${edge.origin_airport_id}, dest=${edge.dest_airport_id}`);
  }
});

console.log('Graph successfully set up!');