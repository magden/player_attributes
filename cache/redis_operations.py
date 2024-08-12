import json
import logging
import os

import redis
import yaml
from google.cloud import bigquery

logging.basicConfig(level=logging.INFO)

redis_client = redis.StrictRedis(host='localhost', port=6379, db=0)


def store_user_panel_in_cache():
    logging.info("Storing user_panel in cache...")
    keyfile_path = get_keyfile_from_profiles()
    os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = keyfile_path

    client = bigquery.Client()

    query = "SELECT * FROM `play-perfect-432018.game_events.user_panel`"
    try:
        query_job = client.query(query)
        user_panel_data = query_job.result().to_dataframe().to_dict(orient='records')  # Fetch data
        logging.info("user_panel is ready to store")

        # Store the data in Redis cache
        redis_client.set('user_panel', json.dumps(user_panel_data))  # Convert to JSON string for Redis
        logging.info("user_panel data stored successfully.")
    except Exception as e:
        logging.error(f"Error retrieving user_panel data: {e}")


def get_keyfile_from_profiles():
    dbt_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '../dbt/profiles.yml'))
    profiles_path = os.path.expanduser(dbt_dir)
    with open(profiles_path, 'r') as file:
        profiles = yaml.safe_load(file)
    try:
        return profiles['my_bigquery_profile']['outputs']['dev']['keyfile']
    except KeyError:
        logging.error("Keyfile not found in profiles.yml.")
        raise
