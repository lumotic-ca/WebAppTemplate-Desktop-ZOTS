import { invoke } from '@tauri-apps/api/core';
import type { ActiveSession, AppSettings, SavedConnection, ThemeMode } from './types';

export function listConnections(): Promise<SavedConnection[]> {
  return invoke('list_connections');
}

export function addConnection(displayName: string, url: string): Promise<SavedConnection> {
  return invoke('add_connection', { displayName, url });
}

export function updateConnection(connection: SavedConnection): Promise<SavedConnection> {
  return invoke('update_connection', { connection });
}

export function deleteConnection(id: string): Promise<void> {
  return invoke('delete_connection', { id });
}

export function clearConnections(): Promise<void> {
  return invoke('clear_connections');
}

export function getLastUsedConnection(): Promise<SavedConnection | null> {
  return invoke('get_last_used_connection');
}

export function getSettings(): Promise<AppSettings> {
  return invoke('get_settings');
}

export function updateSettings(settings: AppSettings): Promise<AppSettings> {
  return invoke('update_settings', { settings });
}

export function setThemeMode(themeMode: ThemeMode): Promise<AppSettings> {
  return invoke('set_theme_mode', { themeMode });
}

export function setAutoReconnect(autoReconnectOnLaunch: boolean): Promise<AppSettings> {
  return invoke('set_auto_reconnect', { autoReconnectOnLaunch });
}

export function connect(id: string): Promise<ActiveSession> {
  return invoke('connect', { id });
}

export function disconnect(): Promise<void> {
  return invoke('disconnect');
}

export function getActiveSession(): Promise<ActiveSession | null> {
  return invoke('get_active_session');
}
