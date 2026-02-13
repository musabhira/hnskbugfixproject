import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import ProfilePage from './pages/ProfilePage';
import LandingPage from './pages/LandingPage';

function App() {
  return (
    <Router>
      <div className="min-h-screen bg-premium-black">
        <Routes>
          <Route path="/" element={<LandingPage />} />
          <Route path="/:slug" element={<ProfilePage />} />
        </Routes>
      </div>
    </Router>
  );
}

export default App;
