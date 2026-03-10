'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { 
  Mail, Lock, User, Briefcase, ArrowRight, UserPlus, Building, 
  Phone, Camera, MapPin, DollarSign, Tag, Plus, Trash2, Video,
  CheckCircle2, Globe
} from 'lucide-react';

interface SignUpProps {
  onSignUp: (role: 'employer' | 'candidate') => void;
  onGoToLogin: () => void;
  onBack: () => void;
}

export function SignUp({ onSignUp, onGoToLogin, onBack }: SignUpProps) {
  const [role, setRole] = useState<'employer' | 'candidate' | null>(null);
  const [step, setStep] = useState(1);
  
  // Form State
  const [formData, setFormData] = useState({
    // Step 1: Basic
    name: '',
    email: '',
    password: '',
    whatsapp: '',
    // Step 2: Profile/Corporate
    photo: '',
    headline: '',
    location: '',
    minSalary: '',
    sector: '',
    // Step 3: Deep Dive
    skills: [] as string[],
    experience: [] as { company: string; duration: string; role: string }[],
    videoUrl: '',
  });

  const [newSkill, setNewSkill] = useState('');
  const [newExp, setNewExp] = useState({ company: '', duration: '', role: '' });
  const [editingExpIndex, setEditingExpIndex] = useState<number | null>(null);

  const handleNext = () => {
    if (role === 'candidate' && step < 3) {
      setStep(step + 1);
    } else if (role === 'employer' && step < 1) { // For employer, Phase 1 is the signup
      setStep(step + 1);
    } else {
      onSignUp(role!);
    }
  };

  const addSkill = () => {
    if (newSkill && !formData.skills.includes(newSkill)) {
      setFormData({ ...formData, skills: [...formData.skills, newSkill] });
      setNewSkill('');
    }
  };

  const addExperience = () => {
    if (newExp.company && newExp.role) {
      if (editingExpIndex !== null) {
        const updatedExp = [...formData.experience];
        updatedExp[editingExpIndex] = newExp;
        setFormData({ ...formData, experience: updatedExp });
        setEditingExpIndex(null);
      } else {
        setFormData({ ...formData, experience: [...formData.experience, newExp] });
      }
      setNewExp({ company: '', duration: '', role: '' });
    }
  };

  const editExperience = (index: number) => {
    setNewExp(formData.experience[index]);
    setEditingExpIndex(index);
  };

  const removeExperience = (index: number) => {
    setFormData({ ...formData, experience: formData.experience.filter((_, i) => i !== index) });
    if (editingExpIndex === index) {
      setEditingExpIndex(null);
      setNewExp({ company: '', duration: '', role: '' });
    }
  };

  const removeSkill = (skill: string) => {
    setFormData({ ...formData, skills: formData.skills.filter(s => s !== skill) });
  };

  if (!role) {
    return (
      <motion.div 
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="flex-1 flex flex-col p-8 bg-white"
      >
        <button onClick={onBack} className="self-start text-slate-400 hover:text-slate-600 mb-8">
          ← Volver
        </button>
        <h2 className="text-3xl font-bold text-slate-900 mb-2 text-center">Únete a Chamby</h2>
        <p className="text-slate-500 mb-12 text-center">Selecciona tu rol para comenzar</p>
        
        <div className="space-y-4">
          <button
            onClick={() => setRole('candidate')}
            className="w-full p-6 rounded-[32px] border-2 border-slate-100 hover:border-blue-600 hover:bg-blue-50 transition-all group flex flex-col items-center gap-4"
          >
            <div className="w-16 h-16 bg-blue-100 rounded-2xl flex items-center justify-center text-blue-600 group-hover:scale-110 transition-transform">
              <User size={32} />
            </div>
            <div className="text-center">
              <h3 className="font-bold text-xl text-slate-900">Soy Candidato</h3>
              <p className="text-slate-500 text-sm">Busco mi próximo gran empleo</p>
            </div>
          </button>

          <button
            onClick={() => setRole('employer')}
            className="w-full p-6 rounded-[32px] border-2 border-slate-100 hover:border-blue-600 hover:bg-blue-50 transition-all group flex flex-col items-center gap-4"
          >
            <div className="w-16 h-16 bg-blue-100 rounded-2xl flex items-center justify-center text-blue-600 group-hover:scale-110 transition-transform">
              <Briefcase size={32} />
            </div>
            <div className="text-center">
              <h3 className="font-bold text-xl text-slate-900">Soy Empresa</h3>
              <p className="text-slate-500 text-sm">Busco el mejor talento local</p>
            </div>
          </button>
        </div>
        
        <div className="mt-auto pt-8 text-center">
          <p className="text-slate-500">
            ¿Ya tienes cuenta?{' '}
            <button onClick={onGoToLogin} className="text-blue-600 font-bold hover:underline">
              Inicia sesión
            </button>
          </p>
        </div>
      </motion.div>
    );
  }

  return (
    <div className="flex-1 flex flex-col bg-white overflow-hidden">
      {/* Progress Bar */}
      <div className="h-1.5 w-full bg-slate-100 flex">
        <motion.div 
          className="h-full bg-blue-600"
          initial={{ width: 0 }}
          animate={{ width: `${(step / (role === 'candidate' ? 3 : 1)) * 100}%` }}
        />
      </div>

      <div className="flex-1 overflow-y-auto p-8">
        <button onClick={() => step === 1 ? setRole(null) : setStep(step - 1)} className="text-slate-400 hover:text-slate-600 mb-6">
          ← Atrás
        </button>

        <AnimatePresence mode="wait">
          {role === 'candidate' ? (
            <motion.div
              key={`step-${step}`}
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -20 }}
              className="space-y-6"
            >
              {step === 1 && (
                <>
                  <div>
                    <h2 className="text-2xl font-bold text-slate-900">Identidad Básica</h2>
                    <p className="text-slate-500">Comencemos con lo esencial</p>
                  </div>
                  <div className="space-y-4">
                    <div className="relative">
                      <User className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" size={20} />
                      <input 
                        type="text" placeholder="Nombre completo" 
                        className="w-full pl-12 pr-4 py-4 bg-slate-50 border border-slate-100 rounded-2xl focus:ring-2 focus:ring-blue-500 outline-none"
                        value={formData.name} onChange={e => setFormData({...formData, name: e.target.value})}
                      />
                    </div>
                    <div className="relative">
                      <Mail className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" size={20} />
                      <input 
                        type="email" placeholder="Email" 
                        className="w-full pl-12 pr-4 py-4 bg-slate-50 border border-slate-100 rounded-2xl focus:ring-2 focus:ring-blue-500 outline-none"
                        value={formData.email} onChange={e => setFormData({...formData, email: e.target.value})}
                      />
                    </div>
                    <div className="relative">
                      <Lock className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" size={20} />
                      <input 
                        type="password" placeholder="Contraseña" 
                        className="w-full pl-12 pr-4 py-4 bg-slate-50 border border-slate-100 rounded-2xl focus:ring-2 focus:ring-blue-500 outline-none"
                        value={formData.password} onChange={e => setFormData({...formData, password: e.target.value})}
                      />
                    </div>
                    <div className="relative">
                      <Phone className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" size={20} />
                      <input 
                        type="tel" placeholder="WhatsApp" 
                        className="w-full pl-12 pr-4 py-4 bg-slate-50 border border-slate-100 rounded-2xl focus:ring-2 focus:ring-blue-500 outline-none"
                        value={formData.whatsapp} onChange={e => setFormData({...formData, whatsapp: e.target.value})}
                      />
                    </div>
                  </div>
                </>
              )}

              {step === 2 && (
                <>
                  <div>
                    <h2 className="text-2xl font-bold text-slate-900">Tu Match Card</h2>
                    <p className="text-slate-500">Así te verán las empresas</p>
                  </div>
                  <div className="space-y-4">
                    <div className="flex justify-center mb-4">
                      <div className="w-24 h-24 bg-slate-100 rounded-3xl border-2 border-dashed border-slate-300 flex flex-col items-center justify-center text-slate-400 cursor-pointer hover:bg-slate-50 transition-colors">
                        <Camera size={24} />
                        <span className="text-[10px] mt-1 font-bold uppercase">Foto</span>
                      </div>
                    </div>
                    <div className="space-y-2">
                      <label className="text-xs font-bold text-slate-500 uppercase ml-1">Headline (Max 140)</label>
                      <textarea 
                        placeholder="Ej: Mesero con 5 años de experiencia, bilingüe y proactivo." 
                        maxLength={140}
                        className="w-full p-4 bg-slate-50 border border-slate-100 rounded-2xl focus:ring-2 focus:ring-blue-500 outline-none h-24 resize-none"
                        value={formData.headline} onChange={e => setFormData({...formData, headline: e.target.value})}
                      />
                    </div>
                    <div className="relative">
                      <MapPin className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" size={20} />
                      <input 
                        type="text" placeholder="Ubicación o Código Postal" 
                        className="w-full pl-12 pr-4 py-4 bg-slate-50 border border-slate-100 rounded-2xl focus:ring-2 focus:ring-blue-500 outline-none"
                        value={formData.location} onChange={e => setFormData({...formData, location: e.target.value})}
                      />
                    </div>
                    <div className="relative">
                      <DollarSign className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" size={20} />
                      <input 
                        type="number" placeholder="Rango salarial mínimo" 
                        className="w-full pl-12 pr-4 py-4 bg-slate-50 border border-slate-100 rounded-2xl focus:ring-2 focus:ring-blue-500 outline-none"
                        value={formData.minSalary} onChange={e => setFormData({...formData, minSalary: e.target.value})}
                      />
                    </div>
                  </div>
                </>
              )}

              {step === 3 && (
                <>
                  <div>
                    <h2 className="text-2xl font-bold text-slate-900">Deep Dive</h2>
                    <p className="text-slate-500">Detalla tu experiencia y habilidades</p>
                  </div>
                  <div className="space-y-6">
                    <div className="space-y-3">
                      <label className="text-xs font-bold text-slate-500 uppercase ml-1">Habilidades</label>
                      <div className="flex gap-2">
                        <input 
                          type="text" placeholder="Ej: Ventas" 
                          className="flex-1 px-4 py-3 bg-slate-50 border border-slate-100 rounded-xl focus:ring-2 focus:ring-blue-500 outline-none"
                          value={newSkill} onChange={e => setNewSkill(e.target.value)}
                          onKeyPress={e => e.key === 'Enter' && addSkill()}
                        />
                        <button onClick={addSkill} className="p-3 bg-blue-600 text-white rounded-xl"><Plus size={20} /></button>
                      </div>
                      <div className="flex flex-wrap gap-2">
                        {formData.skills.map(s => (
                          <span key={s} className="px-3 py-1.5 bg-blue-50 text-blue-600 rounded-lg text-sm font-bold flex items-center gap-1">
                            {s} <Trash2 size={14} className="cursor-pointer" onClick={() => removeSkill(s)} />
                          </span>
                        ))}
                      </div>
                    </div>

                    <div className="space-y-3">
                      <label className="text-xs font-bold text-slate-500 uppercase ml-1">Experiencia Laboral</label>
                      <div className="p-4 bg-slate-50 rounded-2xl border border-slate-100 space-y-3">
                        <input placeholder="Empresa" className="w-full p-2 bg-transparent border-b border-slate-200 outline-none" value={newExp.company} onChange={e => setNewExp({...newExp, company: e.target.value})} />
                        <input placeholder="Cargo" className="w-full p-2 bg-transparent border-b border-slate-200 outline-none" value={newExp.role} onChange={e => setNewExp({...newExp, role: e.target.value})} />
                        <input placeholder="Duración (Ej: 2 años)" className="w-full p-2 bg-transparent border-b border-slate-200 outline-none" value={newExp.duration} onChange={e => setNewExp({...newExp, duration: e.target.value})} />
                        <div className="flex gap-2">
                          <button onClick={addExperience} className="flex-1 py-2 bg-blue-600 text-white rounded-lg font-bold text-sm">
                            {editingExpIndex !== null ? 'Guardar Cambios' : 'Añadir Experiencia'}
                          </button>
                          {editingExpIndex !== null && (
                            <button onClick={() => { setEditingExpIndex(null); setNewExp({ company: '', duration: '', role: '' }); }} className="px-4 py-2 bg-slate-200 text-slate-600 rounded-lg font-bold text-sm">
                              Cancelar
                            </button>
                          )}
                        </div>
                      </div>
                      {formData.experience.map((exp, i) => (
                        <div 
                          key={i} 
                          onClick={() => editExperience(i)}
                          className="p-3 bg-white border border-slate-100 rounded-xl flex justify-between items-center cursor-pointer hover:border-blue-200 transition-colors group"
                        >
                          <div>
                            <p className="font-bold text-sm group-hover:text-blue-600 transition-colors">{exp.role} @ {exp.company}</p>
                            <p className="text-xs text-slate-400">{exp.duration}</p>
                          </div>
                          <button 
                            onClick={(e) => { e.stopPropagation(); removeExperience(i); }}
                            className="p-2 text-slate-300 hover:text-red-500 transition-colors"
                          >
                            <Trash2 size={16} />
                          </button>
                        </div>
                      ))}
                    </div>

                    <div className="space-y-2">
                      <label className="text-xs font-bold text-slate-500 uppercase ml-1">Video Pitch (URL)</label>
                      <div className="relative">
                        <Video className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" size={20} />
                        <input 
                          type="url" placeholder="Link a tu video de presentación" 
                          className="w-full pl-12 pr-4 py-4 bg-slate-50 border border-slate-100 rounded-2xl focus:ring-2 focus:ring-blue-500 outline-none"
                          value={formData.videoUrl} onChange={e => setFormData({...formData, videoUrl: e.target.value})}
                        />
                      </div>
                    </div>
                  </div>
                </>
              )}
            </motion.div>
          ) : (
            <motion.div
              key="employer-step"
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              className="space-y-6"
            >
              <div>
                <h2 className="text-2xl font-bold text-slate-900">Registro Corporativo</h2>
                <p className="text-slate-500">Únete como reclutador</p>
              </div>
              <div className="space-y-4">
                <div className="flex justify-center mb-4">
                  <div className="w-24 h-24 bg-slate-100 rounded-3xl border-2 border-dashed border-slate-300 flex flex-col items-center justify-center text-slate-400 cursor-pointer hover:bg-slate-50 transition-colors">
                    <Building size={24} />
                    <span className="text-[10px] mt-1 font-bold uppercase">Logo</span>
                  </div>
                </div>
                <div className="relative">
                  <Building className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" size={20} />
                  <input 
                    type="text" placeholder="Nombre de la empresa" 
                    className="w-full pl-12 pr-4 py-4 bg-slate-50 border border-slate-100 rounded-2xl focus:ring-2 focus:ring-blue-500 outline-none"
                    value={formData.name} onChange={e => setFormData({...formData, name: e.target.value})}
                  />
                </div>
                <div className="relative">
                  <Mail className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" size={20} />
                  <input 
                    type="email" placeholder="Email corporativo" 
                    className="w-full pl-12 pr-4 py-4 bg-slate-50 border border-slate-100 rounded-2xl focus:ring-2 focus:ring-blue-500 outline-none"
                    value={formData.email} onChange={e => setFormData({...formData, email: e.target.value})}
                  />
                </div>
                <div className="relative">
                  <Lock className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" size={20} />
                  <input 
                    type="password" placeholder="Contraseña" 
                    className="w-full pl-12 pr-4 py-4 bg-slate-50 border border-slate-100 rounded-2xl focus:ring-2 focus:ring-blue-500 outline-none"
                    value={formData.password} onChange={e => setFormData({...formData, password: e.target.value})}
                  />
                </div>
                <div className="relative">
                  <Globe className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" size={20} />
                  <select 
                    className="w-full pl-12 pr-4 py-4 bg-slate-50 border border-slate-100 rounded-2xl focus:ring-2 focus:ring-blue-500 outline-none appearance-none"
                    value={formData.sector} onChange={e => setFormData({...formData, sector: e.target.value})}
                  >
                    <option value="">Sector Industrial</option>
                    <option value="tecnologia">Tecnología</option>
                    <option value="servicios">Servicios</option>
                    <option value="retail">Retail</option>
                    <option value="manufactura">Manufactura</option>
                  </select>
                </div>
              </div>
            </motion.div>
          )}
        </AnimatePresence>

        <button
          onClick={handleNext}
          className="w-full py-4 bg-blue-600 text-white rounded-2xl font-bold text-lg shadow-lg shadow-blue-200 hover:bg-blue-700 transition-all active:scale-95 flex items-center justify-center gap-2 mt-12"
        >
          {step === (role === 'candidate' ? 3 : 1) ? 'Finalizar Registro' : 'Siguiente Paso'}
          <ArrowRight size={20} />
        </button>
      </div>
    </div>
  );
}
