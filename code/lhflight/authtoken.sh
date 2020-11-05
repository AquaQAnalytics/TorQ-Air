curl "https://api.lufthansa.com/v1/oauth/token" -X POST -d "client_id=$1" -d "client_secret=$2" -d "grant_type=client_credentials"
