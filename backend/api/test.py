from .viewcounter import count_updater
from azure.cosmos import CosmosClient
import os
import requests

# Cosmos DB connection global vars
endpoint = os.environ["COSMOS_ENDPOINT"]
account_key = os.environ["COSMOS_KEY"]

client = CosmosClient(url=endpoint, credential=account_key)
database_name = "AzureResume"
container_name = "Counter"
item_id = "1"

database = client.get_database_client(database_name)
container = database.get_container_client(container_name)

def get_count_from_cosmosdb() -> int:

    count_item = container.read_item(item_id, item_id)
    current_count = count_item.get('count', 0)
    return current_count
    
def test_resume_counter():
    initial_count = get_count_from_cosmosdb()

    # increment_count in cosmos db with a new API call
    req = requests.get("https://crckb.azureedge.net/")
    count_updater(req)

    new_count = get_count_from_cosmosdb()
    
    # if new_count is greater than intial_count then our test passed
    print(f"Initial Count: {initial_count} | New Count: {new_count}")
    assert new_count > initial_count