# AM/EVE Split Twilio Function

This directory contains a pair of Twilio functions to route to two different
rosters depending on the time of day.

## Development

This application is developed using the [Twilio Serverless Toolkit][tst] and
deployed as a [Serverless Function][sf]. 

### Requirements

* `node.js`/`npm` matching the version in the `.node-version` file (just run
  `nodenv install` if using nodenv)

### Setup

```sh
npm install # bundle dependencies
```

Copy the `.env.example` file to `.env.dev` and edit values as appropriate:

* `ACCOUNT_SID` and `AUTH_TOKEN`: Belong to the account that these functions
  will be deployed under. Get them from the [developer's console][dc]. Note,
  however, that these aren't actually needed unless you're looking to deploy
  to "dev" for testing purposes.
* `DAY_START_HOUR`: What hour the "day" starts at. Calls before this time will
  be considered "eve" calls, likely for the day before.
* `SWITCHOVER_HOUR`: What hour the "eve" starts at. Calls after this time will
  be considered "eve" calls. This should probably match your "eve" roster's
  switch-over hour.
* `DAY_ROSTER_ID`: the id of the "day" roster in the Rails app.
* `EVE_ROSTER_ID`: the id of the "eve" roster in the Rails app.
* `ROSTER_URL`: the URL in the Rails app that responds to Twilio web hooks.
  The string, "`:id:`", will be replaced with the appropriate roster ID, the
  string, "`:type:`", will be replaced with "`voice`" or "`text`" depending on
  the function.

### Development

```sh
npm run start            # Starts a development server
npm run start -- --ngrok # Same server, but exposed via ngrok
npm run start -- --help  # See this for other dev server options
```

### Deployment

Copy the `.env.example` file to `.env.ops` (for example, I used the department
name as the "environment" name) and edit values as appropriate. This time you
should use production values, and you _do_ need the `ACCOUNT_SID` and
`AUTH_TOKEN`.

```sh
npm run deploy -- --to ops
```

Now you should be able to connect a phone number to the appropriate
functions/environment in the number settings.

[tst]: https://www.twilio.com/docs/labs/serverless-toolkit
[sf]: https://www.twilio.com/docs/serverless/functions-assets
[dc]: https://console.twilio.com/
