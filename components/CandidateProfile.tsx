'use client';

import { User, MapPin, Clock, Award, Edit2 } from 'lucide-react';
import { motion } from 'motion/react';

export function CandidateProfile() {
  return (
    <div className="flex-1 overflow-y-auto bg-slate-50 p-6">
      <div className="bg-white rounded-3xl shadow-sm border border-slate-100 overflow-hidden mb-6">
        <div className="relative h-48 bg-blue-600">
          <img 
            src="https://picsum.photos/seed/alex/400/300" 
            alt="Profile" 
            className="w-full h-full object-cover opacity-80"
          />
          <button className="absolute top-4 right-4 w-10 h-10 bg-white/20 backdrop-blur-md rounded-full flex items-center justify-center text-white border border-white/30">
            <Edit2 size={18} />
          </button>
        </div>
        
        <div className="p-6 -mt-12 relative">
          <div className="w-24 h-24 bg-white rounded-2xl shadow-lg p-1 mb-4">
            <div className="w-full h-full bg-blue-50 rounded-xl flex items-center justify-center text-blue-600">
              <User size={48} />
            </div>
          </div>
          
          <h2 className="text-2xl font-bold text-slate-900">Alex, 22</h2>
          <p className="text-blue-600 font-semibold">Barista / Cajero</p>
          
          <div className="mt-6 space-y-4">
            <div className="flex items-center gap-3 text-slate-600">
              <MapPin size={18} className="text-slate-400" />
              <span>Centro, Ciudad</span>
            </div>
            <div className="flex items-center gap-3 text-slate-600">
              <Clock size={18} className="text-slate-400" />
              <span>Tiempo completo</span>
            </div>
            <div className="flex items-center gap-3 text-slate-600">
              <Award size={18} className="text-slate-400" />
              <span>2 años de experiencia</span>
            </div>
          </div>
        </div>
      </div>

      <div className="space-y-6">
        <section>
          <h3 className="text-sm font-bold text-slate-400 uppercase tracking-wider mb-3">Sobre mí</h3>
          <div className="bg-white p-4 rounded-2xl border border-slate-100 text-slate-600 leading-relaxed">
            Barista energético buscando un ambiente de café concurrido. ¡Prospero bajo presión y me encanta el arte latte!
          </div>
        </section>

        <section>
          <h3 className="text-sm font-bold text-slate-400 uppercase tracking-wider mb-3">Habilidades</h3>
          <div className="flex flex-wrap gap-2">
            {['Dinámico', 'Arte Latte', 'Sistemas POS', 'Atención al Cliente', 'Inglés Básico'].map(skill => (
              <span key={skill} className="px-4 py-2 bg-white border border-slate-100 rounded-xl text-sm font-medium text-slate-700 shadow-sm">
                {skill}
              </span>
            ))}
          </div>
        </section>
        
        <section className="pb-8">
          <h3 className="text-sm font-bold text-slate-400 uppercase tracking-wider mb-3">Mi Video Pitch</h3>
          <div className="aspect-video bg-slate-200 rounded-2xl flex items-center justify-center overflow-hidden relative group cursor-pointer">
             <img 
              src="https://picsum.photos/seed/alex/600/400" 
              alt="Video Thumbnail" 
              className="w-full h-full object-cover"
            />
            <div className="absolute inset-0 bg-black/20 group-hover:bg-black/40 transition-colors flex items-center justify-center">
              <div className="w-12 h-12 bg-white rounded-full flex items-center justify-center text-blue-600 shadow-lg">
                <div className="w-0 h-0 border-t-[8px] border-t-transparent border-l-[12px] border-l-current border-b-[8px] border-b-transparent ml-1" />
              </div>
            </div>
          </div>
        </section>
      </div>
    </div>
  );
}
