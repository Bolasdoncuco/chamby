'use client';

import { motion } from 'motion/react';
import { MessageCircle, CheckCircle2 } from 'lucide-react';

export function MatchScreen({ user, onContinue }: { user: any, onContinue: () => void }) {
  return (
    <motion.div 
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      className="absolute inset-0 bg-gradient-to-br from-blue-600 to-blue-900 z-50 flex flex-col items-center justify-center p-6 text-center"
    >
      <motion.div
        initial={{ scale: 0.5, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        transition={{ delay: 0.2, type: 'spring' }}
        className="mb-8"
      >
        <div className="w-20 h-20 bg-white/20 backdrop-blur-md rounded-full flex items-center justify-center mx-auto mb-6 border border-white/30 shadow-2xl">
          <CheckCircle2 className="text-white" size={48} />
        </div>
        <h1 className="text-4xl font-bold text-white tracking-tight mb-2">CONEXIÓN ESTABLECIDA</h1>
        <p className="text-blue-100 text-lg font-medium">Se ha generado un interés mutuo.</p>
      </motion.div>

      <div className="flex gap-4 mb-12 relative">
        <motion.div 
          initial={{ x: -50, opacity: 0 }}
          animate={{ x: 0, opacity: 1 }}
          transition={{ delay: 0.4 }}
          className="w-24 h-24 rounded-full border-4 border-white overflow-hidden shadow-2xl z-10"
        >
          <img src="https://picsum.photos/seed/employer/200/200" alt="Empresa" className="w-full h-full object-cover" />
        </motion.div>
        <motion.div 
          initial={{ x: 50, opacity: 0 }}
          animate={{ x: 0, opacity: 1 }}
          transition={{ delay: 0.4 }}
          className="w-24 h-24 rounded-full border-4 border-white overflow-hidden shadow-2xl -ml-8"
        >
          <img src={user?.videoPlaceholder} alt={user?.name} className="w-full h-full object-cover" />
        </motion.div>
      </div>

      <motion.div 
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.6 }}
        className="w-full space-y-4"
      >
        <button className="w-full py-4 bg-white text-blue-700 rounded-2xl font-bold text-lg transition-transform hover:scale-105 active:scale-95 flex items-center justify-center gap-2 shadow-xl">
          <MessageCircle size={24} />
          Contactar por WhatsApp
        </button>
        
        <button 
          onClick={onContinue}
          className="w-full py-4 bg-transparent text-white border-2 border-white/30 rounded-2xl font-bold text-lg transition-colors hover:bg-white/10 active:scale-95"
        >
          Seguir Explorando
        </button>
      </motion.div>
    </motion.div>
  );
}
