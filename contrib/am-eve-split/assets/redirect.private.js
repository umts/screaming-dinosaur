const redirect = (twiml, context, type) => {
  const now = new Date();
  const formatOptions = {
    hour: 'numeric',
    hour12: false,
    weekday: 'long',
    timeZone: 'America/New_York',
  };
  const formatter = new Intl.DateTimeFormat('en-US', formatOptions);

  const formattedDate = formatter.format(now).split(', ');
  const hour = Number(formattedDate[1]);
  const isEve = (hour >= context.SWITCHOVER_HOUR || hour < context.DAY_START_HOUR);
  const rosterId = isEve ? context.EVE_ROSTER_ID : context.DAY_ROSTER_ID

  twiml.redirect({method: 'GET'}, context.ROSTER_URL.replace(":id:", rosterId).replace(":type:", type));
};

module.exports = redirect;
