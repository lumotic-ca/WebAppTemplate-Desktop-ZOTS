import { describe, expect, it } from 'vitest';
import { displayHost, validateUrl } from '../src/lib/url-validator';

describe('validateUrl', () => {
  it('accepts https URL', () => {
    const result = validateUrl('https://app.example.com');
    expect(result.isValid).toBe(true);
    expect(result.normalizedUrl).toBe('https://app.example.com/');
  });

  it('adds https scheme when missing', () => {
    const result = validateUrl('app.example.com');
    expect(result.isValid).toBe(true);
    expect(result.normalizedUrl).toBe('https://app.example.com/');
  });

  it('rejects empty input', () => {
    const result = validateUrl('   ');
    expect(result.isValid).toBe(false);
  });

  it('rejects unsupported scheme', () => {
    const result = validateUrl('ftp://app.example.com');
    expect(result.isValid).toBe(false);
  });
});

describe('displayHost', () => {
  it('returns hostname', () => {
    expect(displayHost('https://app.example.com/path')).toBe('app.example.com');
  });
});
