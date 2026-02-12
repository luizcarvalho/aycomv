import React, { useState, useCallback, useEffect } from 'react';
import { Layout } from './components/Layout';
import { Dashboard } from './components/Dashboard';
import { StreamsManager } from './components/StreamsManager';
import { VideoLibrary } from './components/VideoLibrary';
import { ClientsManager } from './components/ClientsManager';
import { ClientPortal } from './components/ClientPortal';
import { MOCK_STREAMS, MOCK_METRICS, MOCK_VIDEOS, MOCK_CLIENTS } from './constants';
import { Stream, Video, Metrics, Notification, Client } from './types';
import { CheckCircle, AlertTriangle, X } from 'lucide-react';

function App() {
  const [activeTab, setActiveTab] = useState<'dashboard' | 'streams' | 'videos' | 'clients'>('dashboard');
  
  // App State
  const [streams, setStreams] = useState<Stream[]>(MOCK_STREAMS);
  const [videos, setVideos] = useState<Video[]>(MOCK_VIDEOS);
  const [metrics, setMetrics] = useState<Metrics>(MOCK_METRICS);
  const [clients, setClients] = useState<Client[]>(MOCK_CLIENTS);
  const [notifications, setNotifications] = useState<Notification[]>([]);
  
  // Client Portal State
  const [currentClient, setCurrentClient] = useState<Client | null>(null);

  // Helpers
  const addNotification = (type: Notification['type'], message: string) => {
    const id = Date.now().toString();
    setNotifications(prev => [...prev, { id, type, message, timestamp: new Date().toISOString() }]);
    setTimeout(() => {
        setNotifications(prev => prev.filter(n => n.id !== id));
    }, 4000);
  };

  // --- CLIENT LOGIC ---

  const handleAddClient = (newClientData: Omit<Client, 'id' | 'createdAt' | 'password'>) => {
    const newId = `client-${Date.now()}`;
    const generatedPassword = Math.random().toString(36).slice(-8); // Generate random password
    const newClient: Client = {
      id: newId,
      ...newClientData,
      password: generatedPassword,
      createdAt: new Date().toISOString()
    };
    
    setClients(prev => [...prev, newClient]);
    addNotification('success', `Cliente cadastrado! Senha enviada para ${newClientData.email}`);
  };

  const handleDeleteClient = (id: string) => {
      setClients(prev => prev.filter(c => c.id !== id));
      addNotification('success', 'Cliente removido.');
  };

  const handleLoginAsClient = (client: Client) => {
      setCurrentClient(client);
      addNotification('info', `Acessando como ${client.name}...`);
  };

  const handleLogoutClient = () => {
      setCurrentClient(null);
  };

  // --- STREAM LOGIC ---

  const handleAddStream = (newStreamData: Omit<Stream, 'id' | 'createdAt' | 'status'>) => {
    const newId = `stream-${Date.now()}`;
    const newStream: Stream = {
      id: newId,
      ...newStreamData,
      status: 'starting', // Start with 'starting' status
      createdAt: new Date().toISOString(),
      previewUrl: `https://picsum.photos/400/225?random=${Date.now()}` // Mock preview
    };

    setStreams(prev => [newStream, ...prev]);
    // Update metrics
    setMetrics(prev => ({
        ...prev,
        activeStreams: prev.activeStreams + 1
    }));

    addNotification('success', 'Stream adicionado com sucesso. Inicializando captura...');

    // Simulate connection success after 3 seconds
    setTimeout(() => {
        setStreams(prev => prev.map(s => s.id === newId ? { ...s, status: 'online' } : s));
        setMetrics(prev => ({ ...prev, capturingNow: prev.capturingNow + 1 }));
        addNotification('info', `Stream "${newStreamData.name}" agora está ONLINE.`);
    }, 3000);
  };

  const handleDeleteStream = (id: string) => {
    const stream = streams.find(s => s.id === id);
    setStreams(prev => prev.filter(s => s.id !== id));
    if (stream?.status === 'online') {
        setMetrics(prev => ({ ...prev, activeStreams: prev.activeStreams - 1, capturingNow: prev.capturingNow - 1 }));
    } else {
        setMetrics(prev => ({ ...prev, activeStreams: prev.activeStreams - 1 }));
    }
    addNotification('success', `Stream "${stream?.name}" excluído.`);
  };

  const handleEditStream = (id: string, updates: Partial<Stream>) => {
    setStreams(prev => prev.map(s => s.id === id ? { ...s, ...updates } : s));
    addNotification('success', 'Alterações salvas com sucesso.');
  };

  const handleToggleStatus = (id: string) => {
    setStreams(prev => prev.map(s => {
        if (s.id === id) {
            const newStatus = s.status === 'online' ? 'offline' : 'online';
            // Update metrics based on change
            setMetrics(m => ({
                ...m,
                capturingNow: newStatus === 'online' ? m.capturingNow + 1 : m.capturingNow - 1,
                offlineStreams: newStatus === 'offline' ? m.offlineStreams + 1 : m.offlineStreams - 1
            }));
            return { ...s, status: newStatus, errorMessage: newStatus === 'offline' ? 'Parado manualmente' : undefined };
        }
        return s;
    }));
  };

  // --- VIDEO LOGIC ---

  const handleShareVideo = (link: string) => {
    navigator.clipboard.writeText(link).then(() => {
        addNotification('success', 'Link copiado para a área de transferência!');
    }).catch(() => {
        addNotification('info', 'Link copiado!');
    });
  };

  const handleDeleteVideo = (id: string) => {
      setVideos(prev => prev.filter(v => v.id !== id));
      setMetrics(prev => ({ ...prev, videosGenerated: prev.videosGenerated - 1 }));
      addNotification('success', 'Vídeo excluído.');
  };

  // Mock Video Generation Interval to simulate Email Notification
  useEffect(() => {
    // This effect mocks the backend process of generating videos and notifying clients
    const interval = setInterval(() => {
        // Randomly decide to "generate" a video for a random stream
        if (Math.random() > 0.8) { 
            const onlineStreams = streams.filter(s => s.status === 'online');
            if (onlineStreams.length > 0) {
                const randomStream = onlineStreams[Math.floor(Math.random() * onlineStreams.length)];
                const client = clients.find(c => c.id === randomStream.clientId);
                
                if (client && client.notifyOnGenerate) {
                    console.log(`[MOCK EMAIL SERVICE] Sending email to ${client.email}: New video generated for ${randomStream.name}`);
                    // Only show toast if we are admin, otherwise it might look weird
                    if (!currentClient) {
                         // Optional: show a small toast for admin to know background tasks are running
                         // addNotification('info', `Novo vídeo gerado para ${client.name}. E-mail de notificação enviado.`);
                    }
                }
            }
        }
    }, 15000); // Check every 15 seconds

    return () => clearInterval(interval);
  }, [streams, clients, currentClient]);

  const activeStreamsList = streams.filter(s => s.status === 'online' || s.status === 'starting');

  // Filter videos for the logged in client
  const clientVideos = currentClient 
    ? videos.filter(v => {
        const stream = streams.find(s => s.id === v.streamId);
        return stream && stream.clientId === currentClient.id;
    })
    : [];

  return (
    <Layout 
        activeTab={activeTab} 
        onTabChange={setActiveTab}
        notificationCount={notifications.length}
        isClientView={!!currentClient}
    >
      <div className="animate-in fade-in duration-300">
        
        {/* VIEW: ADMIN */}
        {!currentClient && (
            <>
                {activeTab === 'dashboard' && (
                    <Dashboard 
                        metrics={metrics} 
                        activeStreams={activeStreamsList}
                        clients={clients} 
                        onViewAllStreams={() => setActiveTab('streams')}
                    />
                )}
                
                {activeTab === 'streams' && (
                    <StreamsManager 
                        streams={streams}
                        clients={clients}
                        onAddStream={handleAddStream}
                        onDeleteStream={handleDeleteStream}
                        onEditStream={handleEditStream}
                        onToggleStatus={handleToggleStatus}
                    />
                )}

                {activeTab === 'videos' && (
                    <VideoLibrary 
                        videos={videos}
                        streams={streams}
                        clients={clients}
                        onDeleteVideo={handleDeleteVideo}
                        onShareVideo={handleShareVideo}
                    />
                )}

                {activeTab === 'clients' && (
                    <ClientsManager 
                        clients={clients}
                        streams={streams}
                        onAddClient={handleAddClient}
                        onDeleteClient={handleDeleteClient}
                        onLoginAsClient={handleLoginAsClient}
                    />
                )}
            </>
        )}

        {/* VIEW: CLIENT PORTAL */}
        {currentClient && (
            <ClientPortal 
                client={currentClient}
                videos={clientVideos}
                onLogout={handleLogoutClient}
                onShareVideo={handleShareVideo}
            />
        )}

      </div>

      {/* Toast Notification Container */}
      <div className="fixed bottom-4 right-4 z-[150] space-y-2 pointer-events-none">
        {notifications.map(note => (
            <div key={note.id} className={`
                flex items-center gap-3 px-4 py-3 rounded-lg shadow-lg border w-80 pointer-events-auto transform transition-all duration-300 translate-y-0
                ${note.type === 'success' ? 'bg-white border-green-200 text-slate-800' : 
                  note.type === 'error' ? 'bg-white border-red-200 text-slate-800' : 
                  'bg-slate-800 text-white border-slate-700'}
            `}>
                {note.type === 'success' && <CheckCircle className="text-green-500" size={20} />}
                {note.type === 'error' && <AlertTriangle className="text-red-500" size={20} />}
                {note.type === 'info' && <div className="w-5 h-5 rounded-full border-2 border-white/30 border-t-white animate-spin"></div>}
                
                <p className="text-sm font-medium flex-1">{note.message}</p>
                <button onClick={() => setNotifications(prev => prev.filter(n => n.id !== note.id))} className="opacity-50 hover:opacity-100">
                    <X size={14} />
                </button>
            </div>
        ))}
      </div>
    </Layout>
  );
}

export default App;