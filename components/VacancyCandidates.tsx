'use client';

import { motion } from 'motion/react';
import { User, MessageCircle, MapPin, Clock, ArrowLeft, Phone } from 'lucide-react';

interface Candidate {
  id: number;
  name: string;
  role: string;
  location: string;
  availability: string;
  photo: string;
}

const MOCK_CANDIDATES: Candidate[] = [
  { id: 1, name: 'Alex, 22', role: 'Barista / Cajero', location: 'Centro', availability: 'Tiempo completo', photo: 'https://picsum.photos/seed/alex/200/200' },
  { id: 2, name: 'Sarah, 25', role: 'Asesora de Ventas', location: 'Zona Norte', availability: 'Medio tiempo', photo: 'https://picsum.photos/seed/sarah/200/200' },
  { id: 3, name: 'Mike, 20', role: 'Mesero / Server', location: 'Distrito Gastronómico', availability: 'Flexible', photo: 'https://picsum.photos/seed/mike/200/200' },
];

export function VacancyCandidates({ vacancyTitle, onBack }: { vacancyTitle: string, onBack: () => void }) {
  return (
    <motion.div 
      initial={{ opacity: 0, x: 20 }}
      animate={{ opacity: 1, x: 0 }}
      className="h-full bg-slate-50 flex flex-col"
    >
      <div className="px-6 py-4 border-b border-slate-100 flex items-center gap-4 bg-white sticky top-0 z-10">
        <button onClick={onBack} className="text-slate-400 hover:text-slate-600">
          <ArrowLeft size={24} />
        </button>
        <div>
          <h2 className="text-xl font-bold text-slate-900">Candidatos</h2>
          <p className="text-xs text-blue-600 font-bold uppercase">{vacancyTitle}</p>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto p-6 space-y-4 pb-24">
        {MOCK_CANDIDATES.map((candidate) => (
          <motion.div 
            key={candidate.id}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            className="bg-white p-4 rounded-3xl border border-slate-100 shadow-sm flex items-center gap-4"
          >
            <div className="w-16 h-16 rounded-2xl overflow-hidden bg-slate-100 flex-shrink-0">
              <img src={candidate.photo} alt={candidate.name} className="w-full h-full object-cover" />
            </div>
            <div className="flex-1 min-w-0">
              <h3 className="font-bold text-slate-900 truncate">{candidate.name}</h3>
              <p className="text-xs text-blue-600 font-bold mb-2">{candidate.role}</p>
              <div className="flex items-center gap-3 text-[10px] text-slate-500 font-medium">
                <span className="flex items-center gap-1"><MapPin size={10} /> {candidate.location}</span>
                <span className="flex items-center gap-1"><Clock size={10} /> {candidate.availability}</span>
              </div>
            </div>
            <div className="flex flex-col gap-2">
              <button className="p-2 bg-green-50 text-green-600 rounded-xl hover:bg-green-100 transition-colors">
                <Phone size={18} />
              </button>
              <button className="p-2 bg-blue-50 text-blue-600 rounded-xl hover:bg-blue-100 transition-colors">
                <MessageCircle size={18} />
              </button>
            </div>
          </motion.div>
        ))}
      </div>
    </motion.div>
  );
}
