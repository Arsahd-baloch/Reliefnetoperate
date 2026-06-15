import React from 'react';
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import L from 'leaflet';

// Fix for default Leaflet icon paths
delete (L.Icon.Default.prototype as any)._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon-2x.png',
  iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png',
});

interface MapViewProps {
  tasks: any[];
  volunteers: any[];
}

const MapView: React.FC<MapViewProps> = ({ tasks, volunteers }) => {
  const validTasks = (tasks ?? []).filter(t => t.latitude != null && t.longitude != null);
  const validVols = (volunteers ?? []).filter(v => v.latitude != null && v.longitude != null);

  return (
    <MapContainer center={[24.8607, 67.0011]} zoom={11} style={{ height: '500px', width: '100%' }}>
      <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />

      {validTasks.map(task => (
        <Marker key={task.id} position={[task.latitude, task.longitude]}>
          <Popup>
            <strong>{task.title}</strong><br/>
            Status: {task.status}<br/>
            Urgency: {task.urgency}
          </Popup>
        </Marker>
      ))}

      {validVols.map(vol => (
        <Marker key={vol.user_id} position={[vol.latitude, vol.longitude]} icon={new L.Icon({
          iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-blue.png',
          shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png',
          iconSize: [25, 41],
          iconAnchor: [12, 41],
        })}>
          <Popup>Volunteer: Active</Popup>
        </Marker>
      ))}
    </MapContainer>
  );
};

export default MapView;
