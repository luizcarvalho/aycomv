export type StreamStatus = 'online' | 'offline' | 'starting' | 'error';

export interface Client {
  id: string;
  name: string;
  email: string;
  password?: string; // Mocked password for display/simulation
  notifyOnGenerate: boolean;
  createdAt: string;
}

export interface Stream {
  id: string;
  clientId: string; // Link to Client
  name: string;
  url: string;
  status: StreamStatus;
  previewUrl?: string | null;
  errorMessage?: string;
  createdAt?: string;
}

export interface Video {
  id: string;
  streamId: string;
  streamName: string;
  date: string;
  generatedAt: string;
  duration: number; // in seconds
  filePath: string;
  thumbnailUrl: string;
  shareLink: string;
  note?: string;
}

export interface Metrics {
  activeStreams: number;
  capturingNow: number;
  videosGenerated: number;
  offlineStreams: number;
}

export interface Notification {
  id: string;
  type: 'success' | 'error' | 'info';
  message: string;
  timestamp: string;
}