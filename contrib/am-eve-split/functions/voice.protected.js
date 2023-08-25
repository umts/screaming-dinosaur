exports.handler = (context, event, callback) => {
  const assets = Runtime.getAssets();
  const redirect = require(assets['/redirect.js'].path);

  const twiml = new Twilio.twiml.VoiceResponse();

  redirect(twiml, context, 'voice');
  return callback(null, twiml);
};
