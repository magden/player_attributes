## FastAPI Project with Redis and dbt

### Project Overview
This project implements a FastAPI application that retrieves player attributes from a Redis cache. 
It uses a scheduled job to run a dbt pipeline, which populates a user panel in a BigQuery data warehouse, and stores the resulting data in Redis for fast access.
 
### Components:

# FastAPI Application (api.py)
- Purpose: provides an API endpoint to retrieve specific player attributes from the cache.
- Endpoint: GET /player/attribute
  - Fetches a specific attribute for a player based on player_id and attribute_name.
- Redis Integration: uses Redis to store and retrieve the user_panel data, ensuring fast access to frequently requested player attributes.
# Scheduler (scheduler.py)
- Purpose: schedules a job to run the dbt pipeline every minute and refresh the user panel data in the Redis cache.
- Functionality: 
  - executes the dbt run command for specified models to populate the user panel.
  - calls the store_user_panel_in_cache function to update the Redis cache with the latest data.
# Redis Operations (redis_operations.py)
- Purpose: Manages storing and retrieving data from Redis.
- Functions: store_user_panel_in_cache(): Queries the user_panel from BigQuery and stores it in Redis for caching.
# DBT Model
- Purpose: SQL code that defines how to create the user_panel in BigQuery.
- Functionality: Joins multiple tables to produce a summary of player attributes, which is stored in the user panel.

### Setup Instructions
- Install Dependencies:
- pip install -r requirements.txt
- Configure Google Cloud Credentials: 
- Update the profiles.yml file in the dbt directory with your Google Cloud credentials.

Run Redis Server: Ensure that your Redis server is running on localhost at port 6379.

Start the Scheduler: Run the scheduler to start fetching and caching data:
- python -m scheduler.scheduler

Run the API: Start the FastAPI application:
- uvicorn api_service.api:app --host 0.0.0.0 --port 8000 --reload

Testing the API
You can test the API by sending a GET request to the endpoint:

http://localhost:8000/player/attribute?player_id=<PLAYER_ID>&attribute_name=<ATTRIBUTE_NAME>

### High-Level Design

Data Flow: The scheduler regularly triggers the dbt pipeline to refresh the user panel in BigQuery. After the update, it caches the user panel data in Redis. The FastAPI application reads from the Redis cache to provide quick responses to attribute requests.

#### Second Suggestion: Using Airflow for Task Management
An alternative approach is to utilize an existing task management platform like Apache Airflow for managing the data pipeline.

Airflow offers effective task scheduling with complex workflows and dependencies, supports parallel processing for quicker attribute creation, and provides an easy-to-use interface for monitoring task execution and logs, making debugging and maintenance simpler.
- DAG Creation: Create a DAG for each attribute that needs to be calculated. These DAGs are should be designed to run in parallel, allowing for efficient processing.

- Attribute Calculation: Each DAG executes its tasks to calculate the respective attributes concurrently.

- Join Task: Once all attribute calculation tasks are complete, a join task is triggered to combine the results and create the user_panel in BigQuery.

- Cache Update: The final DAG updates the Redis cache with the latest user_panel data, ensuring that the cache is always in sync with the most recent calculations.

## Next Steps

1. **Add Tests**: Implement unit and integration tests to ensure the reliability and correctness of the API and caching mechanisms.

2. **Optimize DB Querying**: Analyze and optimize the SQL queries used in the dbt models to improve performance and reduce costs in BigQuery.

3. **Validate Cached Data**: Create a mechanism to validate that the data stored in Redis matches the data in BigQuery, ensuring consistency.

4. **Monitoring and Logging**: Implement monitoring and logging to track the performance of the API and scheduler, and detect any issues.

5. **Error Handling**: Enhance error handling in the API and scheduling to provide more informative responses and improve robustness.

6**Read Data Using Executors**: Implement functionality to read data from the user_panel using executors and bulk requests, with retry logic for failed requests.

7**Containerize the Project**: Create Docker containers for the API and scheduler to simplify deployment and scaling.