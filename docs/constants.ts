import { Metrics, Stream, Video, Client } from "./types";

export const MOCK_CLIENTS: Client[] = [
  {
    id: "client-001",
    name: "Construtora Horizonte",
    email: "contato@horizonte.com.br",
    notifyOnGenerate: true,
    createdAt: "2025-12-10",
  },
  {
    id: "client-002",
    name: "Energisa Monitoramento",
    email: "ops@energisa.com.br",
    notifyOnGenerate: true,
    createdAt: "2026-01-05",
  }
];

export const MOCK_METRICS: Metrics = {
  activeStreams: 4,
  capturingNow: 3,
  videosGenerated: 156,
  offlineStreams: 1,
};

export const MOCK_STREAMS: Stream[] = [
  {
    id: "stream-001",
    clientId: "client-001",
    name: "Camera Torre",
    url: "rtmp://stream01.example.com/live/torre",
    status: "online",
    previewUrl: "https://picsum.photos/400/225?random=1",
    createdAt: "2026-01-15",
  },
  {
    id: "stream-002",
    clientId: "client-002",
    name: "Camera Energisa",
    url: "rtmp://stream02.example.com/live/energisa",
    status: "online",
    previewUrl: "https://picsum.photos/400/225?random=2",
    createdAt: "2026-01-15",
  },
  {
    id: "stream-003",
    clientId: "client-002",
    name: "Camera Energisa 2",
    url: "rtmp://stream03.example.com/live/energisa2",
    status: "offline",
    errorMessage: "Falha na conexão - Tentando (Tentativa 3/10)",
    previewUrl: null,
    createdAt: "2026-02-01",
  },
  {
    id: "stream-004",
    clientId: "client-001",
    name: "Camera Obra 51",
    url: "rtmp://stream04.example.com/live/obra51",
    status: "online",
    previewUrl: "https://picsum.photos/400/225?random=3",
    createdAt: "2026-02-05",
  },
];

export const MOCK_VIDEOS: Video[] = [
  {
    id: "video-001",
    streamId: "stream-001",
    streamName: "Camera Torre",
    date: "2026-02-08",
    generatedAt: "2026-02-08T23:59:00Z",
    duration: 84,
    filePath: "/videos/stream-001/timelapse_20260208.mp4",
    thumbnailUrl: "https://picsum.photos/400/225?random=4",
    shareLink: "https://AYCOM.videos/share/v/xyz123",
  },
  {
    id: "video-002",
    streamId: "stream-002",
    streamName: "Camera Energisa",
    date: "2026-02-08",
    generatedAt: "2026-02-08T23:59:00Z",
    duration: 82,
    filePath: "/videos/stream-002/timelapse_20260208.mp4",
    thumbnailUrl: "https://picsum.photos/400/225?random=5",
    shareLink: "https://AYCOM.videos/share/v/abc987",
  },
  {
    id: "video-003",
    streamId: "stream-003",
    streamName: "Camera Energisa 2",
    date: "2026-02-07",
    generatedAt: "2026-02-07T23:59:00Z",
    duration: 45,
    filePath: "/videos/stream-003/timelapse_20260207.mp4",
    thumbnailUrl: "https://picsum.photos/400/225?random=6",
    shareLink: "https://AYCOM.videos/share/v/def456",
    note: "Dia parcial - stream teve problemas de conexão",
  },
];