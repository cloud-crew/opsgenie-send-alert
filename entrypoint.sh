#!/bin/sh

# Copyright (c) Cloud Crew
# Licensed under the MIT License

set -e

# Validate JSON format
validate_json() {
    if ! jq -e . >/dev/null 2>&1 <<<"$2"; then
        echo "Invalid $1: $2"
        echo "Please check the documentation for the correct format: https://docs.opsgenie.com/docs/alert-api#create-alert"
        exit 1
    fi
}

# Normalize string by trimming leading and trailing whitespaces
normalize() {
    echo "$1" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

# Escape double quotes in a string for JSON compatibility
escape_json() {
    echo "$1" | sed -e 's/"/\\"/g'
}

# Collect input parameters
apiUrl=$(normalize "${1}")
apiKey=$(normalize "${2}")
message=$(normalize "${3}")
alias=$(normalize "${4}")
description=$(normalize "${5}")
responders=$(normalize "${6}")
visibleTo=$(normalize "${7}")
actions=$(normalize "${8}")
tags=$(normalize "${9}")
details=$(normalize "${10}")
entity=$(normalize "${11}")
source=$(normalize "${12}")
priority=$(normalize "${13}")
user=$(normalize "${14}")
note=$(normalize "${15}")
verbose=$(normalize "${16}")

# Initialize payload with an opening brace
payload='{'

# Add alias to payload if provided
if [[ -n $alias ]]; then
    payload+="\"alias\":\"$alias\","
fi

# Add description to payload if provided
if [[ -n $description ]]; then
    description=$(escape_json "$description")
    payload+="\"description\":\"$description\","
fi

# Validate and add responders to payload if provided
if [[ -n $responders ]]; then
    validate_json "responders" "$responders"
    payload+="\"responders\":$responders,"
fi

# Validate and add visibleTo to payload if provided
if [[ -n $visibleTo ]]; then
    validate_json "visibleTo" "$visibleTo"
    payload+="\"visibleTo\":$visibleTo,"
fi

# Validate and add actions to payload if provided
if [[ -n $actions ]]; then
    validate_json "actions" "$actions"
    payload+="\"actions\":$actions,"
fi

# Validate and add tags to payload if provided
if [[ -n $tags ]]; then
    validate_json "tags" "$tags"
    payload+="\"tags\":$tags,"
fi

# Set default details if not provided and validate
if [[ -z $details ]]; then
    details='{'
    details+="\"workflow\":\"$GITHUB_WORKFLOW\","
    details+="\"runId\":\"$GITHUB_RUN_ID\","
    details+="\"runNumber\":\"$GITHUB_RUN_NUMBER\","
    details+="\"action\":\"$GITHUB_ACTION\","
    details+="\"actor\":\"$GITHUB_ACTOR\","
    details+="\"eventName\":\"$GITHUB_EVENT_NAME\","
    details+="\"repository\":\"$GITHUB_REPOSITORY\","
    details+="\"ref\":\"$GITHUB_REF\","
    details+="\"sha\":\"$GITHUB_SHA\""
    details+='}'
fi
validate_json "details" "$details"
payload+="\"details\":$details,"

# Add entity to payload if provided
if [[ -n $entity ]]; then
    payload+="\"entity\":\"$entity\","
fi

# Set default source if not provided
if [[ -z $source ]]; then
    source="GitHub Action - $GITHUB_ACTION"
fi
payload+="\"source\":\"$source\","

# Add priority to payload if provided and validate
if [[ -n $priority ]]; then
    if [[ $priority =~ ^(P1|P2|P3|P4|P5)$ ]]; then
        payload+="\"priority\":\"$priority\","
    else
        echo "Invalid priority: $priority"
        exit 1
    fi
fi

# Set user to GitHub actor if not provided
if [[ -z $user ]]; then
    user="$GITHUB_ACTOR"
fi
payload+="\"user\":\"$user\","

# Escape and add note to payload if provided
if [[ -n $note ]]; then
    note=$(escape_json "$note")
    payload+="\"note\":\"$note\","
fi

# Escape and add message to payload
message=$(escape_json "$message")
payload+="\"message\":\"$message\""

# Close the JSON payload
payload+='}'

# Set HTTP request type, URL, and headers
req_type="POST"
req_url="${apiUrl}/alerts"
req_header_auth="Authorization: GenieKey ${apiKey}"
req_header_content="Content-Type: application/json"

# Execute the HTTP request with or without verbose mode
if [[ $verbose == "true" ]]; then
    curl --request "${req_type}" \
        --url "${req_url}" \
        --header "${req_header_auth}" \
        --header "${req_header_content}" \
        --data "${payload}" \
        --fail \
        --verbose
else
    curl --request "${req_type}" \
        --url "${req_url}" \
        --header "${req_header_auth}" \
        --header "${req_header_content}" \
        --data "${payload}" \
        --fail \
        --silent
fi
