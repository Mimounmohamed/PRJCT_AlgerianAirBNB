const https = require('https');

/**
 * Send an SMS via BudgetSMS HTTP API.
 * Docs: https://www.budgetsms.net/sms-http-api/send-sms/
 *
 * @param {string} to  – Recipient in E.164 format, e.g. +213558852374
 * @param {string} message – SMS body text
 * @returns {Promise<boolean>} true when the gateway accepts the message
 */
async function sendSms(to, message) {
  const username = process.env.BUDGETSMS_USERNAME;
  const userid  = process.env.BUDGETSMS_USERID;
  const handle  = process.env.BUDGETSMS_HANDLE;

  if (!username || !userid || !handle) {
    console.warn('⚠️  BudgetSMS credentials missing — SMS NOT sent. Set BUDGETSMS_USERNAME, BUDGETSMS_USERID, BUDGETSMS_HANDLE in .env');
    return false;
  }

  // BudgetSMS wants numbers without leading "+"
  const cleanNumber = to.replace(/^\+/, '');

  const params = new URLSearchParams({
    username,
    userid,
    handle,
    msg: message,
    from: 'AKRILI',
    to: cleanNumber,
  });

  const url = `https://api.budgetsms.net/sendsms/?${params.toString()}`;

  return new Promise((resolve, reject) => {
    https.get(url, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => {
        const trimmed = data.trim();
        console.log(`[BUDGETSMS] Response for ${cleanNumber}: ${trimmed}`);
        if (trimmed.startsWith('OK')) {
          resolve(true);
        } else {
          reject(new Error(`BudgetSMS error: ${trimmed}`));
        }
      });
    }).on('error', (err) => {
      console.error('[BUDGETSMS] Request error:', err.message);
      reject(err);
    });
  });
}

module.exports = { sendSms };
