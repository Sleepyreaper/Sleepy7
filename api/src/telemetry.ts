if (req.headers.get('content-length') && Number(req.headers.get('content-length')) > 16384) {
  return json(413, { error: 'Payload too large' });
}

const safeLog = JSON.stringify(body).slice(0, 2048); // truncate
ctx.log('Telemetry received', safeLog);