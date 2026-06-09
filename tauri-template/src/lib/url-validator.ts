import { isUrlAllowed } from './app-config';

export interface UrlValidationResult {
  isValid: boolean;
  normalizedUrl?: string;
  error?: string;
}

export function validateUrl(input: string): UrlValidationResult {
  const trimmed = input.trim();
  if (!trimmed) {
    return { isValid: false, error: 'Enter a server URL.' };
  }

  const withScheme = ensureScheme(trimmed);
  let parsed: URL;
  try {
    parsed = new URL(withScheme);
  } catch {
    return { isValid: false, error: 'Enter a valid URL (e.g. https://app.example.com).' };
  }

  if (!parsed.hostname) {
    return { isValid: false, error: 'Enter a valid URL (e.g. https://app.example.com).' };
  }

  if (parsed.protocol !== 'http:' && parsed.protocol !== 'https:') {
    return { isValid: false, error: 'Only http and https URLs are supported.' };
  }

  const normalized = normalizeUrl(parsed);
  if (!isUrlAllowed(normalized)) {
    return { isValid: false, error: 'This URL is not allowed for this app.' };
  }

  return { isValid: true, normalizedUrl: normalized };
}

export function displayHost(url: string): string {
  try {
    return new URL(url).hostname;
  } catch {
    return url;
  }
}

function ensureScheme(value: string): string {
  return value.includes('://') ? value : `https://${value}`;
}

function normalizeUrl(url: URL): string {
  const path = url.pathname || '/';
  const query = url.search ?? '';
  return `${url.protocol}//${url.host}${path}${query}`;
}
