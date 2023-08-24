exports.handler = (context, event, callback) => {
  let twiml = new Twilio.twiml.MessagingResponse();

  const now = new Date();
  const formatOptions = {
    hour: 'numeric',
    hour12: false,
    weekday: 'long',
    timeZone: 'America/New_York',
  };
  const formatter = new Intl.DateTimeFormat('en-US', formatOptions);

  const formattedDate = formatter.format(now).split(', ');
  const day = formattedDate[0];
  const hour = Number(formattedDate[1]);
  const isWeekend = ['Sunday', 'Saturday'].includes(day);

  if (hour >= context.SWITCHOVER_HOUR || hour < context.DAY_START_HOUR) {
    twiml.redirect({method: 'GET'}, context.EVE_ROSTER_TEXT_URL);
  } else {
    twiml.redirect({method: 'GET'}, context.DAY_ROSTER_TEXT_URL);
  }
  return callback(null, twiml);
}
