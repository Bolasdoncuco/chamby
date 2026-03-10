'use client';

import { useState } from 'react';
import { motion } from 'motion/react';
import { 
  Briefcase, MapPin, DollarSign, Tag, Plus, Trash2, 
  CheckCircle2, Image as ImageIcon, X, Map as MapIcon
} from 'lucide-react';

export function JobCreation({ onComplete }: { onComplete: () => void }) {
  const [tags, setTags] = useState<string[]>([]);
  const [newTag, setNewTag] = useState('');
  const [benefits, setBenefits] = useState<string[]>([]);
  
  const benefitOptions = [
    { id: 'seguro', label: 'Seguro Social', icon: '🏥' },
    { id: 'comida', label: 'Comida Incluida', icon: '🍱' },
    { id: 'transporte', label: 'Transporte', icon: '🚌' },
    { id: 'bonos', label: 'Bonos', icon: '💰' },
  ];

  const addTag = () => {
    if (newTag && !tags.includes(newTag)) {
      setTags([...tags, newTag]);
      setNewTag('');
    }
  };

  const toggleBenefit = (id: string) => {
    setBenefits(prev => 
      prev.includes(id) ? prev.filter(b => b !== id) : [...prev, id]
    );
  };

  return (
    <motion.div 
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="h-full bg-white flex flex-col"
    >
      <div className="px-6 py-4 border-b border-slate-100 flex items-center justify-between bg-white sticky top-0 z-10">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-blue-100 rounded-xl flex items-center justify-center text-blue-600">
            <Briefcase size={24} />
          </div>
          <h2 className="text-xl font-bold text-slate-900">Nueva Vacante</h2>
        </div>
        <button onClick={onComplete} className="text-slate-400 hover:text-slate-600">
          <X size={24} />
        </button>
      </div>

      <form className="flex-1 overflow-y-auto p-6 space-y-6 pb-24" onSubmit={(e) => { e.preventDefault(); onComplete(); }}>
        {/* Identidad de la Vacante */}
        <div className="space-y-4">
          <div>
            <label className="block text-xs font-bold text-slate-500 uppercase mb-1.5 ml-1">Título del Puesto</label>
            <input 
              type="text" 
              placeholder="Ej. Cajero Turno Vespertino"
              className="w-full px-4 py-3.5 rounded-2xl border border-slate-200 focus:ring-2 focus:ring-blue-500 outline-none transition-all bg-slate-50"
              required
            />
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-500 uppercase mb-1.5 ml-1">Sueldo Ofertado</label>
            <div className="flex gap-2">
              <div className="relative flex-1">
                <span className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400">
                  <DollarSign size={18} />
                </span>
                <input 
                  type="number" 
                  placeholder="Ej. 8000"
                  className="w-full pl-10 pr-4 py-3.5 rounded-2xl border border-slate-200 focus:ring-2 focus:ring-blue-500 outline-none transition-all bg-slate-50"
                  required
                />
              </div>
              <select className="px-4 py-3.5 rounded-2xl border border-slate-200 focus:ring-2 focus:ring-blue-500 outline-none transition-all bg-slate-50 text-sm font-bold text-slate-700">
                <option value="mensual">Mensual</option>
                <option value="quincenal">Quincenal</option>
                <option value="semanal">Semanal</option>
              </select>
            </div>
          </div>
        </div>

        {/* Ubicación con Mapa (Mockup) */}
        <div>
          <label className="block text-xs font-bold text-slate-500 uppercase mb-1.5 ml-1">Ubicación del Puesto</label>
          <div className="relative group">
            <div className="w-full h-32 bg-slate-200 rounded-2xl overflow-hidden relative border border-slate-200">
              <div className="absolute inset-0 flex items-center justify-center text-slate-400 flex-col gap-1">
                <MapIcon size={32} />
                <span className="text-[10px] font-bold uppercase">Pinpoint en Mapa</span>
              </div>
              <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 text-red-500">
                <MapPin size={24} fill="currentColor" fillOpacity={0.3} />
              </div>
            </div>
            <input 
              type="text" 
              placeholder="Dirección exacta"
              className="mt-2 w-full px-4 py-3 rounded-xl border border-slate-200 focus:ring-2 focus:ring-blue-500 outline-none transition-all bg-white text-sm"
              required
            />
          </div>
        </div>

        {/* Requisitos (Tags) */}
        <div className="space-y-3">
          <label className="block text-xs font-bold text-slate-500 uppercase mb-1.5 ml-1">Requisitos (Skills)</label>
          <div className="flex gap-2">
            <input 
              type="text" 
              placeholder="Ej. Atención al cliente"
              className="flex-1 px-4 py-3 rounded-xl border border-slate-200 focus:ring-2 focus:ring-blue-500 outline-none transition-all bg-slate-50"
              value={newTag}
              onChange={(e) => setNewTag(e.target.value)}
              onKeyPress={(e) => e.key === 'Enter' && (e.preventDefault(), addTag())}
            />
            <button 
              type="button"
              onClick={addTag}
              className="p-3 bg-blue-600 text-white rounded-xl hover:bg-blue-700 transition-colors"
            >
              <Plus size={20} />
            </button>
          </div>
          <div className="flex flex-wrap gap-2">
            {tags.map(tag => (
              <span key={tag} className="px-3 py-1.5 bg-blue-50 text-blue-600 rounded-lg text-xs font-bold flex items-center gap-1.5">
                {tag}
                <Trash2 size={14} className="cursor-pointer opacity-60 hover:opacity-100" onClick={() => setTags(tags.filter(t => t !== tag))} />
              </span>
            ))}
          </div>
        </div>

        {/* Beneficios (Checkboxes) */}
        <div className="space-y-3">
          <label className="block text-xs font-bold text-slate-500 uppercase mb-1.5 ml-1">Beneficios</label>
          <div className="grid grid-cols-2 gap-3">
            {benefitOptions.map(opt => (
              <button
                key={opt.id}
                type="button"
                onClick={() => toggleBenefit(opt.id)}
                className={`flex items-center gap-2 p-3 rounded-xl border transition-all text-left ${
                  benefits.includes(opt.id)
                    ? 'border-green-500 bg-green-50 text-green-700'
                    : 'border-slate-100 bg-slate-50 text-slate-500'
                }`}
              >
                <span className="text-lg">{opt.icon}</span>
                <span className="text-xs font-bold">{opt.label}</span>
                {benefits.includes(opt.id) && <CheckCircle2 size={14} className="ml-auto" />}
              </button>
            ))}
          </div>
        </div>

        {/* Galería del Lugar */}
        <div className="space-y-3">
          <label className="block text-xs font-bold text-slate-500 uppercase mb-1.5 ml-1">Galería del Lugar</label>
          <div className="flex gap-3 overflow-x-auto pb-2 scrollbar-hide">
            <div className="min-w-[100px] h-[100px] bg-slate-100 rounded-2xl border-2 border-dashed border-slate-300 flex flex-col items-center justify-center text-slate-400 cursor-pointer hover:bg-slate-50 transition-colors">
              <Plus size={20} />
              <span className="text-[8px] font-bold uppercase mt-1">Añadir Foto</span>
            </div>
            {[1, 2].map(i => (
              <div key={i} className="min-w-[100px] h-[100px] bg-slate-200 rounded-2xl relative group overflow-hidden">
                <img 
                  src={`https://picsum.photos/seed/office${i}/200/200`} 
                  alt="Office" 
                  className="w-full h-full object-cover"
                />
                <button className="absolute top-1 right-1 p-1 bg-black/50 text-white rounded-full opacity-0 group-hover:opacity-100 transition-opacity">
                  <Trash2 size={12} />
                </button>
              </div>
            ))}
          </div>
        </div>

        <button 
          type="submit"
          className="w-full py-4 bg-blue-600 hover:bg-blue-700 text-white rounded-2xl font-bold text-lg transition-all active:scale-95 shadow-lg shadow-blue-200"
        >
          Publicar Vacante
        </button>
      </form>
    </motion.div>
  );
}
