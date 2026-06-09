export type ThemeMode = 'system' | 'light' | 'dark';

export interface SavedConnection {
  id: string;
  display_name: string;
  url: string;
  last_used_at?: string | null;
}

export interface AppSettings {
  theme_mode: ThemeMode;
  auto_reconnect_on_launch: boolean;
}

export interface ActiveSession {
  connection: SavedConnection;
}
