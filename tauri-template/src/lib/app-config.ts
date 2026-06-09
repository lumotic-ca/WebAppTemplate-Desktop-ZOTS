/** Fork customization point — keep in sync with `src-tauri/src/config.rs`. */
export const appConfig = {
  appName: 'WebApp Template',
  identifier: 'com.lumotic.webapptemplate',
  allowedUrlPatterns: [] as string[],
  userAgentSuffix: 'WebAppTemplate-Tauri/1.0',
};

export function isUrlAllowed(url: string): boolean {
  if (appConfig.allowedUrlPatterns.length === 0) {
    return true;
  }
  return appConfig.allowedUrlPatterns.some((pattern) => url.startsWith(pattern));
}
