'use client';

import { useState } from 'react';
import { motion } from 'motion/react';
import { Plus, Briefcase, Users, Eye, MoreVertical, CheckCircle2, PauseCircle, Edit2 } from 'lucide-react';

interface Vacancy {
  id: number;
  title: string;
  salary: number;
  status: 'active' | 'paused';
  matches: number;
  views: number;
}

export function EmployerDashboard({ onCreateNew, onEditVacancy, onViewCandidates }: { 
  onCreateNew: () => void,
  onEditVacancy: (vacancy: Vacancy) => void,
  onViewCandidates: (vacancy: Vacancy) => void
}) {
  const [vacancies] = useState<Vacancy[]>([
    { id: 1, title: 'Cajero Turno Vespertino', salary: 8500, status: 'active', matches: 12, views: 45 },
    { id: 2, title: 'Barista Experto', salary: 9000, status: 'paused', matches: 8, views: 22 },
    { id: 3, title: 'Auxiliar de Limpieza', salary: 6000, status: 'active', matches: 25, views: 110 },
  ]);

  return (
    <div className="h-full bg-slate-50 flex flex-col">
      <div className="p-6 flex justify-between items-center">
        <div>
          <h2 className="text-2xl font-bold text-slate-900">Mis Vacantes</h2>
          <p className="text-slate-500 text-sm">Gestiona tus ofertas activas</p>
        </div>
        <button 
          onClick={onCreateNew}
          className="w-12 h-12 bg-blue-600 text-white rounded-2xl flex items-center justify-center shadow-lg shadow-blue-200 hover:bg-blue-700 transition-all active:scale-95"
        >
          <Plus size={24} />
        </button>
      </div>

      <div className="flex-1 overflow-y-auto px-6 space-y-4 pb-24">
        {vacancies.map((job) => (
          <motion.div 
            key={job.id}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            className="bg-white p-5 rounded-[24px] border border-slate-100 shadow-sm relative group"
          >
            <div className="flex justify-between items-start mb-4">
              <div className="flex items-center gap-3">
                <div className={`w-10 h-10 rounded-xl flex items-center justify-center ${job.status === 'active' ? 'bg-green-100 text-green-600' : 'bg-slate-100 text-slate-400'}`}>
                  <Briefcase size={20} />
                </div>
                <div>
                  <h3 className="font-bold text-slate-900">{job.title}</h3>
                  <p className="text-xs font-bold text-blue-600">${job.salary.toLocaleString()} / mes</p>
                </div>
              </div>
              <button 
                onClick={() => onEditVacancy(job)}
                className="text-slate-300 hover:text-blue-600 transition-colors"
              >
                <Edit2 size={20} />
              </button>
            </div>

            <div className="grid grid-cols-3 gap-4 py-3 border-t border-slate-50">
              <div className="text-center">
                <p className="text-[10px] font-bold text-slate-400 uppercase">Matches</p>
                <div className="flex items-center justify-center gap-1 text-slate-900 font-bold">
                  <Users size={14} className="text-blue-500" />
                  {job.matches}
                </div>
              </div>
              <div className="text-center border-x border-slate-50">
                <p className="text-[10px] font-bold text-slate-400 uppercase">Vistas</p>
                <div className="flex items-center justify-center gap-1 text-slate-900 font-bold">
                  <Eye size={14} className="text-slate-400" />
                  {job.views}
                </div>
              </div>
              <div className="text-center">
                <p className="text-[10px] font-bold text-slate-400 uppercase">Estado</p>
                <div className={`flex items-center justify-center gap-1 font-bold text-[10px] uppercase ${job.status === 'active' ? 'text-green-600' : 'text-slate-400'}`}>
                  {job.status === 'active' ? <CheckCircle2 size={12} /> : <PauseCircle size={12} />}
                  {job.status === 'active' ? 'Activa' : 'Pausada'}
                </div>
              </div>
            </div>
            
            <button 
              onClick={() => onViewCandidates(job)}
              className="w-full mt-4 py-2.5 bg-slate-50 text-slate-600 rounded-xl text-xs font-bold hover:bg-slate-100 transition-colors"
            >
              Ver Candidatos
            </button>
          </motion.div>
        ))}
      </div>
    </div>
  );
}
