#!/bin/bash

##check variables exist
if [ -z "$CLOUDFLARE_API_KEY" ]; then
  echo "CLOUDFLARE_API_KEY is not set"
  exit 1
fi
if [ -z "$CLOUDFLARE_EMAIL" ]; then
  echo "CLOUDFLARE_EMAIL is not set"
  exit 1
fi
if [ -z "$DOMAIN" ]; then
  echo "DOMAIN is not set"
  exit 1
fi
if [ -z "$RECORD" ]; then
  echo "RECORD is not set"
  exit 1
fi

## Get the current public IP address
IP=$(curl -s https://cloudflare.com/cdn-cgi/trace | grep -E '^ip' | cut -d = -f 2)

## Get Domain ID
ZONE_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$DOMAIN" \
  -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
  -H "Authorization: Bearer $CLOUDFLARE_API_KEY" \
  -H "Content-Type: application/json" | jq -r '.result[0].id')

## Get Record ID
RECORD_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?name=$RECORD.$DOMAIN" \
  -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
  -H "Authorization: Bearer $CLOUDFLARE_API_KEY" \
  -H "Content-Type: application/json" | jq -r '.result[0].id')

## Get the current IP address on Cloudflare
CF_IP=$(curl -s https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID \
  -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
  -H "Authorization: Bearer $CLOUDFLARE_API_KEY" \
  -H "Content-Type: application/json" \
  | jq '.result.content' \
  | tr -d \")

## Update the IP address on Cloudflare if it has changed
if [ "$IP" != "$CF_IP" ]; then
  curl -s https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID \
    -X PUT \
    -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
    -H "Authorization: Bearer $CLOUDFLARE_API_KEY" \
    -H "Content-Type: application/json" \
    --data "{\"type\":\"A\",\"name\":\"$RECORD\",\"content\":\"$IP\"}"
    if [ $? -eq 0 ]; then
        echo "IP address updated successfully to $IP"
        else
        echo "Failed to update IP address"
        exit 1
        fi
else
  echo "IP address has not changed. No update required."
fi