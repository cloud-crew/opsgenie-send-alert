# OpsGenie Send Alert

This GitHub Action creates an alerts in [OpsGenie](https://www.atlassian.com/software/opsgenie).

## Usage

```yaml
- uses: cloud-crew/opsgenie-send-alert@v1
  with:
    apiKey: secret
    message: your message
```

### Inputs

| Name          | Required | Description                                                                                                            | Limitations                               |
|---------------|----------|------------------------------------------------------------------------------------------------------------------------|-------------------------------------------|
| `apiUrl`      | **Yes**  | The base URL for the OpsGenie API (without /alert). **Default**: https://api.opsgenie.com/v2v2                                     |                                           |
| `apiKey`      | **Yes**  | Your OpsGenie API key                                                                                                       |                                           |
| `message`     | **Yes**  | The message to be sent with the alert                                                                                                   |                                           |
| `alias`       | No       | A client-defined unique identifier for the alert, used for alert deduplication De-Duplication                           | 512 characters                            |
| `description` | No       | A detailed description of the alert                | 15000 characters                          |
| `responders`  | No       | A list of teams, users, escalations, and schedules to route the alert to                                   | Maximum of 50 teams, users, escalations, or schedules |
| `visibleTo`   | No       | A list of teams, users, escalations, and schedules who can see the alert without receiving a notification | Maximum of 50 teams or users                |
| `actions`     | No       | A set of custom actions that can be performed on the alert                                                        | 10 actions, each up to 50 characters                        |
| `tags`        | No       | Tags associated with the alert                                                                                          | Maximum of 20 tags, each up to 50 characters                        |
| `details`     | No       | Key-value pairs to define custom properties for the alert                                                        | 8000 characters in total                  |
| `entity`      | No       | The entity field that generally specifies which domain the alert is related to                      | 512 characters                            |
| `source`      | No       | Specifies the source where the alert was created                                            | 100 characters                            |
| `priority`    | No       | The priority level of the alert, default is P3                                                                      | Options: P1, P2, P3, P4, P5       |
| `user`        | No       | The display name of the request owner                                                                                      | 100 characters                            |
| `note`        | No       | An additional note that will be added when creating the alert                                                            | 25000 characters                          |
| `verbose`     | No       | Enables verbose mode for _curl_                                                                                         |                                           |

Fields that are arrays or objects should be formatted as valid JSON. Please refer to the examples below.

### Example

```yaml
name: Example

on:
  workflow_dispatch:

env:
  RUN_URL: ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}

jobs:
  example_job:
    runs-on: ubuntu-latest

    steps:
      - run: |
          echo "Oh no!"
          exit 1

      - if: failure()
        uses: cloud-crew/opsgenie-send-alert@v1
        with:
          apiKey: ${{ secrets.OPSGENIE_API_KEY }}
          message: "${{ github.workflow }} #${{ github.run_number }} failed"
          description: | # The description supports HTML (according to OpsGenie specs)
            Run number ${{ github.run_number }} of workflow <i>${{ github.workflow }}</i> has failed!<br>
            <a href="${{ env.RUN_URL }}" target="_blank">Open run in new window</a>
          tags: '["tag1", "tag2"]'  # Note that this is a JSON array, but enclosed in single quotes. You can use double quotes, but will need to escape them.
          verbose: "true"  # Enable verbose mode for curl debugging (used under the hood)
```

## Resources

* [Create an OpsGenie API Key through an API Integration](https://support.atlassian.com/opsgenie/docs/create-a-default-api-integration/)
* [OpsGenie Alert API Documentation](https://docs.opsgenie.com/docs/alert-api#create-alert)

## License

This project is licensed under the MIT License. See the LICENSE file for more details.
