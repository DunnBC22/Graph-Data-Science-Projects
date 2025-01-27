# Flights Data Graph Data Analysis

## Project Overview
This project is more like three or four projects in one. Notes for each of the sub-projects are shown below.

The overarching intent of this project was to:
- Clean the existing data
- Learn how to run both standard commands on data, using:
    - Neo4j's Cypher
    - ArangoDB's AQL
- Learn how to run advanced data science/analytics commands/functions on graph data, using:
    - Neo4j's Graph Data Science (GDS) plugin
    - ArangoClient (ArangoDB's Python client library);

** __Note(s):__ 
    
1. I (initially) wanted to run the same commands in both Neo4j and ArangoDB; however, since there are differences in the offereings of the two libraries, I soon learned that was not ideal.
2. Because the files for the code in both the Neo4j and ArangoDB subprojects (individually) became rather lengthy, I decided to split them up to make them more manageable. Some of the initial commands were used in all files as they were necessary for setting up the graph(s) and testing to make sure the graphs were set up correctly.

## Dataset Source

https://www.kaggle.com/datasets/mmetter/flights

## Notes for Each Section

<details>
    <summary><ins>Data Cleaning</ins></summary>

- To clean the data I opted to use the Python Polars library instead of the Python Pandas library.
    - I enjoyed learning it. You can tell that it is faster than Pandas. 
    - As much as I thought it would be a quick and easy library to learn, there was a slightly steeper learner curve than I expected. This was mainly due to the differences in use between lazyframes and dataframes.
- Only after nearly completing this project did I think to apply data validation function on the data. While I am sure that it did not have any adverse impact on the results, it is something that I would apply to the dataset next time.

</details>

<details>
    <summary><ins>Neo4j</ins></summary>

- I split the code into a few files as having all of it in a single file was tough to manage. As such, there are some functions that are repeated in each of the files.
- The results for commands in Non-GDS Statements (Part 1) [Neo4j] file that have less than ~50 rows of results are in a pdf with a similar file name (screenshots of command & results).
- I had to create a different graph projection for part 4 of the analysis. All of the other sections use the other (initial) graph projection.
- I worked on this subproject at a different time than when I worked on the ArangoDB subproject. I made some updates in between the two, which likely explains the discrepancy in the number of airports. Since the are the same number of flights in both subprojects, I am sure that the issue lies in somthing with how Cypher (in Neo4j) reads in the data relating to the airports.
- I removed most of the flight records from the file that to which I saved the data to keep the file within the 25MB file size requirement for uploading files to GitHub.
</details>

<details>
    <summary><ins>ArangoDB</ins></summary>

- I split the code into a few files as having all of it in a single file was tough to manage. As such, there is some overlap of the initial code from file to file.
</details>

<details>
    <summary><ins>Visualizaitons</ins></summary>
    
- My initial plan was to create either a D3.js visualization or a Tableau visualization (or both) to include in this project. Since this project took longer than I was expecting, I have decided to post what I have now. I may or may not return to complete the visualization sub-project(s) in the future.
</details>


## Potential Next Steps

It would be interesting to add other details about flights and the air transportation to further this graph. Some ideas to add include:

* Passenger tickets/sales & airplane seating capacity data to calculate utilization rates for each flight &/or path, 
* Include departure and arrival times to calculate the full duration of flight paths that have layovers,
* Staffing for pilots & flight attendants
