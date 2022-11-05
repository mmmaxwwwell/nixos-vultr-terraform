#!/usr/bin/env bash
source settings/settings.tfvars
curl "https://api.vultr.com/v2/iso" \
  -X GET \
  -H "Authorization: Bearer ${vultr_api_key}" | jq


