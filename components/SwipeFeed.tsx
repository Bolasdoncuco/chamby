'use client';

import { useState, useEffect, useMemo } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { MapPin, Clock, X, Heart, RotateCcw } from 'lucide-react';

const MOCK_CANDIDATES = [
  {
    id: 1,
    name: 'Alex, 22',
    role: 'Barista / Cajero',
    experience: '2 años',
    location: 'Centro',
    availability: 'Tiempo completo',
    tags: ['Dinámico', 'Arte Latte', 'Sistemas POS'],
    videoPlaceholder: 'https://picsum.photos/seed/alex/400/600',
    bio: 'Barista energético buscando un ambiente de café concurrido. ¡Prospero bajo presión!'
  },
  {
    id: 2,
    name: 'Sarah, 25',
    role: 'Asesora de Ventas',
    experience: '3 años',
    location: 'Zona Norte',
    availability: 'Medio tiempo',
    tags: ['Servicio al Cliente', 'Visual Merchandising', 'Bilingüe'],
    videoPlaceholder: 'https://picsum.photos/seed/sarah/400/600',
    bio: 'Asesora de ventas amable y accesible con facilidad para las ventas.'
  },
  {
    id: 3,
    name: 'Mike, 20',
    role: 'Mesero / Server',
    experience: '1 año',
    location: 'Distrito Gastronómico',
    availability: 'Flexible',
    tags: ['Trabajo en Equipo', 'Alto Volumen', 'Seguridad Alimentaria'],
    videoPlaceholder: 'https://picsum.photos/seed/mike/400/600',
    bio: 'Rápido y siempre sonriente. Listo para unirme a un equipo dinámico.'
  }
];

const MOCK_JOBS = [
  {
    id: 101,
    name: 'Café Central',
    role: 'Barista Principal',
    experience: '1+ año',
    location: 'Centro Histórico',
    availability: 'Mañana/Tarde',
    tags: ['Sueldo Base + Propinas', 'Seguro Médico', 'Capacitación'],
    videoPlaceholder: 'https://picsum.photos/seed/cafe/400/600',
    bio: 'Buscamos un barista apasionado para unirse a nuestra familia. Ambiente vibrante y el mejor café de la ciudad.'
  },
  {
    id: 102,
    name: 'Moda Urbana',
    role: 'Vendedor de Tienda',
    experience: 'Sin experiencia',
    location: 'Centro Comercial',
    availability: 'Fines de semana',
    tags: ['Comisiones', 'Descuento Empleado', 'Crecimiento'],
    videoPlaceholder: 'https://picsum.photos/seed/fashion/400/600',
    bio: '¿Te apasiona la moda? Únete a nuestro equipo de ventas. Buscamos gente con actitud y ganas de aprender.'
  },
  {
    id: 103,
    name: 'Restaurante El Faro',
    role: 'Ayudante de Cocina',
    experience: '6 meses',
    location: 'Puerto Madero',
    availability: 'Turno Noche',
    tags: ['Comida incluida', 'Transporte', 'Bonos'],
    videoPlaceholder: 'https://picsum.photos/seed/kitchen/400/600',
    bio: 'Equipo de cocina profesional busca ayudante comprometido. Oportunidad de aprender de los mejores chefs.'
  }
];

export function SwipeFeed({ onMatch, userRole }: { onMatch: (user: any) => void, userRole: 'employer' | 'candidate' | null }) {
  const initialCards = useMemo(() => userRole === 'employer' ? MOCK_CANDIDATES : MOCK_JOBS, [userRole]);
  const [cards, setCards] = useState(initialCards);

  useEffect(() => {
    setCards(initialCards);
  }, [initialCards]);

  const handleSwipe = (direction: 'left' | 'right', id: number) => {
    const swipedUser = cards.find(c => c.id === id);
    setCards(prev => prev.filter(c => c.id !== id));
    
    if (direction === 'right' && swipedUser) {
      setTimeout(() => onMatch(swipedUser), 300);
    }
  };

  return (
    <div className="relative w-full h-full flex items-center justify-center p-4">
      {cards.length === 0 ? (
        <div className="text-center p-8">
          <div className="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4 text-blue-600">
            <RotateCcw size={32} />
          </div>
          <p className="text-lg font-bold text-slate-800">
            {userRole === 'employer' ? 'No hay más candidatos' : 'No hay más vacantes'}
          </p>
          <p className="text-sm text-slate-500 mt-1">Vuelve a revisar más tarde o ajusta tus filtros.</p>
          <button 
            onClick={() => setCards(initialCards)}
            className="mt-6 px-8 py-3 bg-blue-600 text-white rounded-2xl font-bold shadow-lg shadow-blue-200 active:scale-95 transition-all"
          >
            Reiniciar Demo
          </button>
        </div>
      ) : (
        <AnimatePresence>
          {cards.map((item, index) => {
            const isTop = index === cards.length - 1;
            return (
              <motion.div
                key={item.id}
                className="absolute w-full h-full max-h-[620px] max-w-[360px] bg-white rounded-[32px] shadow-2xl overflow-hidden origin-bottom border border-slate-100"
                style={{
                  zIndex: index,
                }}
                initial={{ scale: 0.95, y: 20, opacity: 0 }}
                animate={{ 
                  scale: isTop ? 1 : 0.95, 
                  y: isTop ? 0 : 20,
                  opacity: 1
                }}
                exit={{ opacity: 0, scale: 0.9, x: isTop ? 200 : 0 }}
                transition={{ duration: 0.3 }}
                drag={isTop ? "x" : false}
                dragConstraints={{ left: 0, right: 0 }}
                onDragEnd={(e, info) => {
                  if (info.offset.x > 100) handleSwipe('right', item.id);
                  else if (info.offset.x < -100) handleSwipe('left', item.id);
                }}
              >
                {/* Video/Image Placeholder */}
                <div className="relative w-full h-[60%] bg-slate-200">
                  <img 
                    src={item.videoPlaceholder} 
                    alt={item.name}
                    className="w-full h-full object-cover"
                  />
                  <div className="absolute inset-0 bg-gradient-to-t from-slate-900/90 via-slate-900/20 to-transparent" />
                  
                  {/* Info Overlay */}
                  <div className="absolute bottom-0 left-0 w-full p-6 text-white">
                    <div className="flex items-center gap-2 mb-1">
                      <h2 className="text-3xl font-bold">{item.name}</h2>
                      <div className="w-2 h-2 bg-emerald-400 rounded-full animate-pulse" />
                    </div>
                    <p className="text-lg font-medium text-blue-100">{item.role}</p>
                  </div>
                  
                  {/* Indicator */}
                  <div className="absolute top-4 right-4 bg-white/20 backdrop-blur-md px-3 py-1.5 rounded-full text-[10px] uppercase tracking-widest font-bold text-white border border-white/30">
                    {userRole === 'employer' ? 'Pitch 15s' : 'Vacante'}
                  </div>
                </div>

                {/* Details Section */}
                <div className="p-6 h-[40%] flex flex-col bg-white">
                  <div className="flex flex-wrap gap-2 mb-4">
                    {item.tags.map(tag => (
                      <span key={tag} className="px-3 py-1 bg-blue-50 text-blue-700 rounded-lg text-[11px] font-bold uppercase tracking-wider">
                        {tag}
                      </span>
                    ))}
                  </div>
                  
                  <div className="space-y-2.5 text-sm text-slate-600 mb-4 flex-1">
                    <div className="flex items-center gap-2.5">
                      <MapPin size={16} className="text-slate-400" />
                      <span className="font-medium">{item.location}</span>
                    </div>
                    <div className="flex items-center gap-2.5">
                      <Clock size={16} className="text-slate-400" />
                      <span className="font-medium">{item.availability}</span>
                    </div>
                  </div>

                  {/* Action Buttons */}
                  <div className="flex justify-center gap-8 mt-auto">
                    <button 
                      onClick={() => handleSwipe('left', item.id)}
                      className="w-14 h-14 rounded-full bg-white border border-slate-100 flex items-center justify-center text-slate-400 hover:text-red-500 hover:border-red-100 hover:bg-red-50 transition-all shadow-lg active:scale-90"
                    >
                      <X size={28} strokeWidth={2.5} />
                    </button>
                    <button 
                      onClick={() => handleSwipe('right', item.id)}
                      className="w-14 h-14 rounded-full bg-blue-600 flex items-center justify-center text-white hover:bg-blue-700 transition-all shadow-lg shadow-blue-200 active:scale-90"
                    >
                      <Heart size={28} strokeWidth={2.5} fill="currentColor" />
                    </button>
                  </div>
                </div>
              </motion.div>
            );
          })}
        </AnimatePresence>
      )}
    </div>
  );
}
