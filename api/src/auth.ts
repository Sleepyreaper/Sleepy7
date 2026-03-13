import { jwtVerify, importJWK, JWTPayload } from 'jose';

const issuer = process.env.B2C_ISSUER ?? '';
const audience = process.env.B2C_AUDIENCE ?? '';

if (!issuer || !audience) {
  throw new Error('B2C_ISSUER or B2C_AUDIENCE not configured');
}

// Ideally cache this per kid; simplified here:
async function getSigningKey(kid: string) {
  const jwksUri = `${issuer}.well-known/openid-configuration`;
  const { jwks_uri } = await fetch(jwksUri).then((r) => r.json());
  const { keys } = await fetch(jwks_uri).then((r) => r.json());
  const jwk = keys.find((k: any) => k.kid === kid);
  if (!jwk) throw new Error('Signing key not found');
  return await importJWK(jwk);
}

export async function verifyAuthHeader(authHeader?: string): Promise<JWTPayload> {
  if (!authHeader?.startsWith('Bearer ')) {
    throw new Error('Missing bearer token');
  }
  const token = authHeader.slice(7);
  const { payload, protectedHeader } = await jwtVerify(token, await getSigningKey(JSON.parse(atob(token.split('.')[0])).kid), {
    issuer,
    audience
  });
  return payload;
}