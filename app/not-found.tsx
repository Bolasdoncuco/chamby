import Link from 'next/link';

export default function NotFound() {
  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-slate-50 text-slate-900 p-4">
      <h1 className="text-4xl font-bold mb-2">404</h1>
      <p className="text-lg text-slate-600 mb-6">Página no encontrada</p>
      <Link 
        href="/"
        className="px-6 py-3 bg-blue-600 text-white rounded-2xl font-bold shadow-lg hover:bg-blue-700 transition-all"
      >
        Volver al inicio
      </Link>
    </div>
  );
}
