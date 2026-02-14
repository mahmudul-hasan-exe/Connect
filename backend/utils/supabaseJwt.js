const JWT_ERROR_CODES = [
  'ERR_JWT_EXPIRED',
  'ERR_JWS_SIGNATURE_VERIFICATION_FAILED',
  'ERR_JWT_CLAIM_VALIDATION_FAILED',
];

let jwksClient = null;

async function getJwksClient() {
  if (jwksClient) return jwksClient;
  const jose = await import('jose');
  const { SUPABASE_URL } = require('../config/constants');
  const jwksUri = `${SUPABASE_URL}/auth/v1/.well-known/jwks.json`;
  jwksClient = jose.createRemoteJWKSet(new URL(jwksUri));
  return jwksClient;
}

async function verifySupabaseToken(accessToken) {
  if (typeof accessToken !== 'string' || accessToken.length < 50) {
    throw new Error('Invalid token format');
  }
  const parts = accessToken.split('.');
  if (parts.length !== 3) {
    throw new Error('Invalid token format');
  }
  const jose = await import('jose');
  const jwks = await getJwksClient();
  const { payload } = await jose.jwtVerify(accessToken, jwks);
  return payload;
}

function isJwtVerificationError(err) {
  return err.code && JWT_ERROR_CODES.includes(err.code);
}

module.exports = {
  verifySupabaseToken,
  isJwtVerificationError,
};
