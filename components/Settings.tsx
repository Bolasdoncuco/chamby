'use client';

import { motion } from 'motion/react';
import { 
  Settings as SettingsIcon, Bell, Shield, HelpCircle, 
  LogOut, ChevronRight, Moon, Globe, User, Briefcase
} from 'lucide-react';

export function Settings({ userRole, onBack, onLogout, onEditProfile }: { 
  userRole: 'employer' | 'candidate' | null, 
  onBack: () => void,
  onLogout: () => void,
  onEditProfile: () => void
}) {
  const sections = [
    {
      title: 'Cuenta',
      items: [
        { id: 'profile', label: 'Editar Perfil', icon: User, action: onEditProfile },
        { id: 'notifications', label: 'Notificaciones', icon: Bell },
        { id: 'privacy', label: 'Privacidad y Seguridad', icon: Shield },
      ]
    },
    {
      title: 'Preferencias',
      items: [
        { id: 'theme', label: 'Modo Oscuro', icon: Moon, toggle: true },
        { id: 'language', label: 'Idioma', icon: Globe, value: 'Español' },
      ]
    },
    {
      title: 'Soporte',
      items: [
        { id: 'help', label: 'Centro de Ayuda', icon: HelpCircle },
        { id: 'about', label: 'Acerca de Chamby', icon: SettingsIcon },
      ]
    }
  ];

  return (
    <motion.div 
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="h-full bg-slate-50 flex flex-col"
    >
      <div className="px-6 py-4 border-b border-slate-100 flex items-center gap-4 bg-white sticky top-0 z-10">
        <button onClick={onBack} className="text-slate-400 hover:text-slate-600">
          <ChevronRight className="rotate-180" size={24} />
        </button>
        <h2 className="text-xl font-bold text-slate-900">Configuración</h2>
      </div>

      <div className="flex-1 overflow-y-auto p-6 space-y-8 pb-24">
        {/* User Info Card */}
        <div className="bg-white p-4 rounded-3xl border border-slate-100 shadow-sm flex items-center gap-4">
          <div className="w-16 h-16 bg-blue-100 rounded-2xl flex items-center justify-center text-blue-600">
            {userRole === 'employer' ? <Briefcase size={32} /> : <User size={32} />}
          </div>
          <div>
            <h3 className="font-bold text-slate-900">Alex Chamby</h3>
            <p className="text-xs text-slate-500">{userRole === 'employer' ? 'Empresa Verificada' : 'Candidato Premium'}</p>
          </div>
        </div>

        {sections.map((section) => (
          <div key={section.title} className="space-y-3">
            <h3 className="text-xs font-bold text-slate-400 uppercase tracking-wider ml-1">{section.title}</h3>
            <div className="bg-white rounded-3xl border border-slate-100 shadow-sm overflow-hidden">
              {section.items.map((item, idx) => (
                <button
                  key={item.id}
                  onClick={item.action}
                  className={`w-full flex items-center gap-4 p-4 hover:bg-slate-50 transition-colors ${
                    idx !== section.items.length - 1 ? 'border-b border-slate-50' : ''
                  }`}
                >
                  <div className="w-10 h-10 bg-slate-50 rounded-xl flex items-center justify-center text-slate-400">
                    <item.icon size={20} />
                  </div>
                  <span className="flex-1 text-left font-bold text-slate-700">{item.label}</span>
                  {item.value && <span className="text-xs font-bold text-slate-400">{item.value}</span>}
                  {item.toggle ? (
                    <div className="w-10 h-5 bg-slate-200 rounded-full relative">
                      <div className="absolute left-1 top-1 w-3 h-3 bg-white rounded-full" />
                    </div>
                  ) : (
                    <ChevronRight size={18} className="text-slate-300" />
                  )}
                </button>
              ))}
            </div>
          </div>
        ))}

        <button 
          onClick={onLogout}
          className="w-full py-4 bg-red-50 text-red-600 rounded-2xl font-bold text-lg flex items-center justify-center gap-2 hover:bg-red-100 transition-colors"
        >
          <LogOut size={20} />
          Cerrar Sesión
        </button>
      </div>
    </motion.div>
  );
}
