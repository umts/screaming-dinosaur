exports.handler = (context, event, callback) => {
  const assets = Runtime.getAssets();
  const redirect = require(assets['/redirect.js'].path);

  let twiml = new Twilio.twiml.MessagingResponse();

  redirect(twiml, context, 'text');
  return callback(null, twiml);
}
