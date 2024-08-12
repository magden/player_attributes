
from fastapi import FastAPI, HTTPException
import redis
import json
import uvicorn

redis_client = redis.StrictRedis(host='localhost', port=6379, db=0)

app = FastAPI()


@app.get("/player/attribute")
async def get_attribute(player_id: str, attribute_name: str):

    user_panel_data = redis_client.get('user_panel')

    if user_panel_data is None:
        raise HTTPException(status_code=404, detail="User panel data not found in cache.")

    user_panel = json.loads(user_panel_data)

    player = next((item for item in user_panel if item['player_id'] == player_id), None)

    if player is None:
        raise HTTPException(status_code=404, detail=f"Player with ID {player_id} not found.")

    attribute_value = player.get(attribute_name)

    if attribute_value is None:
        raise HTTPException(status_code=404, detail=f"Attribute {attribute_name} not found for player ID {player_id}.")

    return {attribute_name: attribute_value}


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)