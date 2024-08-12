import logging
import os
import subprocess

from apscheduler.schedulers.blocking import BlockingScheduler

from cache.redis_operations import store_user_panel_in_cache

logging.basicConfig(level=logging.INFO)


def run_dbt():
    try:
        logging.info("Running dbt...")
        dbt_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '../dbt'))

        result = subprocess.run(
            ["dbt", "run", "--models", "active_days_since_last_purchase", "avg_price_10", "country",
             "score_perc_50_last_5_days", "weighted_matches", "user_panel"],
            capture_output=True,
            text=True,
            check=True,
            cwd=dbt_dir
        )
        logging.info("dbt run completed successfully.")
        logging.debug(result.stdout)  # Log stdout for debugging
    except subprocess.CalledProcessError as e:
        logging.error(f"Error running dbt: {e}")


def scheduled_job():
    run_dbt()
    store_user_panel_in_cache()


scheduler = BlockingScheduler()
scheduler.add_job(scheduled_job, 'interval', seconds=60)

try:
    logging.info("Starting scheduler...")
    scheduler.start()
except (KeyboardInterrupt, SystemExit):
    logging.info("Scheduler stopped.")
