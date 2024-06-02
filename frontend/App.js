import { Link } from 'react-router-dom';
import './App.css';

function App() {
  return (
    <div className="App">
      <h1>Learning Platform test</h1>
      <nav>
        <Link to="/courses">Courses</Link>
      </nav>
    </div>
  );
}

export default App;
