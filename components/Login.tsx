'use client';

import { useState } from 'react';
import { motion } from 'motion/react';
import { Mail, Lock, ArrowRight, Briefcase, User } from 'lucide-react';

interface LoginProps {
  onLogin: (role: 'employer' | 'candidate') => void;
  onGoToSignUp: () => void;
  onBack: () => void;
}

export function Login({ onLogin, onGoToSignUp, onBack }: LoginProps) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [role, setRole] = useState<'employer' | 'candidate'>('candidate');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // En un mockup funcional, simplemente llamamos a onLogin
    onLogin(role);
  };

  return (
    <motion.div 
      initial={{ opacity: 0, x: 20 }}
      animate={{ opacity: 1, x: 0 }}
      exit={{ opacity: 0, x: -20 }}
      className="flex-1 flex flex-col p-8 bg-white"
    >
      <button onClick={onBack} className="self-start text-slate-400 hover:text-slate-600 mb-8">
        ← Volver
      </button>

      <div className="mb-8">
        <h2 className="text-3xl font-bold text-slate-900">Bienvenido</h2>
        <p className="text-slate-500 mt-2">Ingresa tus credenciales para continuar</p>
      </div>

      <form onSubmit={handleSubmit} className="space-y-6">
        <div className="space-y-2">
          <label className="text-sm font-bold text-slate-700 ml-1">Tipo de cuenta</label>
          <div className="flex gap-3">
            <button
              type="button"
              onClick={() => setRole('candidate')}
              className={`flex-1 py-3 rounded-2xl border-2 transition-all flex items-center justify-center gap-2 font-bold ${
                role === 'candidate' 
                  ? 'border-blue-600 bg-blue-50 text-blue-600' 
                  : 'border-slate-100 text-slate-400'
              }`}
            >
              <User size={18} />
              Candidato
            </button>
            <button
              type="button"
              onClick={() => setRole('employer')}
              className={`flex-1 py-3 rounded-2xl border-2 transition-all flex items-center justify-center gap-2 font-bold ${
                role === 'employer' 
                  ? 'border-blue-600 bg-blue-50 text-blue-600' 
                  : 'border-slate-100 text-slate-400'
              }`}
            >
              <Briefcase size={18} />
              Empresa
            </button>
          </div>
        </div>

        <div className="space-y-4">
          <div className="relative">
            <Mail className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" size={20} />
            <input
              type="email"
              placeholder="Correo electrónico"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full pl-12 pr-4 py-4 bg-slate-50 border border-slate-100 rounded-2xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all text-slate-900"
              required
            />
          </div>
          <div className="relative">
            <Lock className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" size={20} />
            <input
              type="password"
              placeholder="Contraseña"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full pl-12 pr-4 py-4 bg-slate-50 border border-slate-100 rounded-2xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all text-slate-900"
              required
            />
          </div>
        </div>

        <button
          type="submit"
          className="w-full py-4 bg-blue-600 text-white rounded-2xl font-bold text-lg shadow-lg shadow-blue-200 hover:bg-blue-700 transition-all active:scale-95 flex items-center justify-center gap-2"
        >
          Iniciar Sesión
          <ArrowRight size={20} />
        </button>
      </form>

      <div className="mt-auto pt-8 text-center">
        <p className="text-slate-500">
          ¿No tienes cuenta?{' '}
          <button onClick={onGoToSignUp} className="text-blue-600 font-bold hover:underline">
            Regístrate aquí
          </button>
        </p>
      </div>
    </motion.div>
  );
}
