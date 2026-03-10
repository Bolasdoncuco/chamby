'use client';

import { useState, useEffect } from 'react';
import { SwipeFeed } from '../components/SwipeFeed';
import { JobCreation } from '../components/JobCreation';
import { MatchScreen } from '../components/MatchScreen';
import { CandidateProfile } from '../components/CandidateProfile';
import { Login } from '../components/Login';
import { SignUp } from '../components/SignUp';
import { EmployerDashboard } from '../components/EmployerDashboard';
import { VacancyCandidates } from '../components/VacancyCandidates';
import { Settings } from '../components/Settings';
import { Briefcase, User, LogOut, Settings as SettingsIcon, LayoutDashboard } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';

export default function App() {
  const [mounted, setMounted] = useState(false);
  const [appState, setAppState] = useState<'welcome' | 'login' | 'signup' | 'app'>('welcome');
  const [userRole, setUserRole] = useState<'employer' | 'candidate' | null>(null);
  const [currentView, setCurrentView] = useState<'feed' | 'create' | 'match' | 'profile' | 'dashboard' | 'candidates' | 'settings' | 'edit-vacancy'>('feed');
  const [matchedUser, setMatchedUser] = useState<any>(null);
  const [selectedVacancy, setSelectedVacancy] = useState<any>(null);

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setMounted(true);
  }, []);

  const handleMatch = (user: any) => {
    setMatchedUser(user);
    setCurrentView('match');
  };

  const handleAuthSuccess = (role: 'employer' | 'candidate') => {
    setUserRole(role);
    setAppState('app');
    setCurrentView(role === 'employer' ? 'dashboard' : 'feed');
  };

  const handleLogout = () => {
    setAppState('welcome');
    setUserRole(null);
  };

  if (!mounted) return null;

  return (
    <div className="min-h-screen bg-slate-100 flex items-center justify-center p-4 font-sans">
      {/* Mobile Device Simulator */}
      <div className="w-full max-w-[400px] h-[800px] bg-white rounded-[40px] shadow-2xl overflow-hidden relative flex flex-col border-[8px] border-slate-900">
        
        <AnimatePresence mode="wait">
          {appState === 'welcome' && (
            <motion.div 
              key="welcome"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="flex-1 flex flex-col items-center justify-center p-8 bg-gradient-to-b from-blue-600 to-blue-800 text-white"
            >
              <div className="mb-12 text-center">
                <div className="w-20 h-20 bg-white rounded-2xl flex items-center justify-center mx-auto mb-4 shadow-lg">
                  <Briefcase className="text-blue-600" size={40} />
                </div>
                <h1 className="text-3xl font-bold tracking-tight">Chamby</h1>
                <p className="text-blue-100 mt-2">Encuentra tu próximo paso</p>
              </div>

              <div className="w-full space-y-4">
                <button 
                  onClick={() => setAppState('login')}
                  className="w-full py-4 bg-white text-blue-700 rounded-2xl font-bold text-lg shadow-xl hover:bg-blue-50 transition-all active:scale-95 flex items-center justify-center gap-3"
                >
                  Iniciar Sesión
                </button>
                <button 
                  onClick={() => setAppState('signup')}
                  className="w-full py-4 bg-blue-500 text-white border-2 border-blue-400 rounded-2xl font-bold text-lg shadow-xl hover:bg-blue-400 transition-all active:scale-95 flex items-center justify-center gap-3"
                >
                  Crear Cuenta
                </button>
              </div>
              
              <p className="mt-12 text-blue-200 text-sm">Versión MVP Prototype</p>
            </motion.div>
          )}

          {appState === 'login' && (
            <Login 
              onLogin={handleAuthSuccess} 
              onGoToSignUp={() => setAppState('signup')} 
              onBack={() => setAppState('welcome')}
            />
          )}

          {appState === 'signup' && (
            <SignUp 
              onSignUp={handleAuthSuccess} 
              onGoToLogin={() => setAppState('login')} 
              onBack={() => setAppState('welcome')}
            />
          )}

          {appState === 'app' && (
            <motion.div 
              key="app"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              className="flex-1 flex flex-col h-full"
            >
              {/* Header */}
              <header className="px-6 py-4 flex justify-between items-center z-10 bg-white/90 backdrop-blur-md border-b border-slate-100">
                <h1 className="text-xl font-bold tracking-tight text-blue-600">Chamby</h1>
                <div className="flex gap-4 text-slate-400">
                  {userRole === 'employer' ? (
                    <>
                      <button onClick={() => setCurrentView('dashboard')} className={`transition-colors ${currentView === 'dashboard' ? 'text-blue-600' : 'hover:text-slate-600'}`}>
                        <LayoutDashboard size={24} />
                      </button>
                      <button onClick={() => setCurrentView('settings')} className={`transition-colors ${currentView === 'settings' ? 'text-blue-600' : 'hover:text-slate-600'}`}>
                        <SettingsIcon size={24} />
                      </button>
                    </>
                  ) : (
                    <>
                      <button onClick={() => setCurrentView('feed')} className={`transition-colors ${currentView === 'feed' ? 'text-blue-600' : 'hover:text-slate-600'}`}>
                        <Briefcase size={24} />
                      </button>
                      <button onClick={() => setCurrentView('profile')} className={`transition-colors ${currentView === 'profile' ? 'text-blue-600' : 'hover:text-slate-600'}`}>
                        <User size={24} />
                      </button>
                      <button onClick={() => setCurrentView('settings')} className={`transition-colors ${currentView === 'settings' ? 'text-blue-600' : 'hover:text-slate-600'}`}>
                        <SettingsIcon size={24} />
                      </button>
                    </>
                  )}
                </div>
              </header>

              {/* Main Content Area */}
              <main className="flex-1 relative overflow-hidden bg-slate-50 flex flex-col">
                {currentView === 'feed' && <SwipeFeed onMatch={handleMatch} userRole={userRole} />}
                {currentView === 'dashboard' && (
                  <EmployerDashboard 
                    onCreateNew={() => setCurrentView('create')} 
                    onEditVacancy={(v) => { setSelectedVacancy(v); setCurrentView('edit-vacancy'); }}
                    onViewCandidates={(v) => { setSelectedVacancy(v); setCurrentView('candidates'); }}
                  />
                )}
                {currentView === 'create' && <JobCreation onComplete={() => setCurrentView('dashboard')} />}
                {currentView === 'edit-vacancy' && <JobCreation onComplete={() => setCurrentView('dashboard')} />}
                {currentView === 'candidates' && <VacancyCandidates vacancyTitle={selectedVacancy?.title} onBack={() => setCurrentView('dashboard')} />}
                {currentView === 'match' && <MatchScreen user={matchedUser} onContinue={() => setCurrentView('feed')} />}
                {currentView === 'profile' && <CandidateProfile />}
                {currentView === 'settings' && (
                  <Settings 
                    userRole={userRole} 
                    onBack={() => setCurrentView(userRole === 'employer' ? 'dashboard' : 'feed')} 
                    onLogout={handleLogout}
                    onEditProfile={() => setCurrentView(userRole === 'employer' ? 'create' : 'profile')}
                  />
                )}
              </main>
            </motion.div>
          )}
        </AnimatePresence>

      </div>
    </div>
  );
}
