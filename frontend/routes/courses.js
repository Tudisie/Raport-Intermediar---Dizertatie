import React, { useEffect, useState } from 'react';
import axios from 'axios';
import '../styles/Courses.css';
import { Link, useNavigate} from 'react-router-dom';

function Courses() {
  const navigate = useNavigate();
  const [courses, setCourses] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    axios.get('http://52.45.45.87:8080/courses')
      .then(response => {
        setCourses(response.data);
        setLoading(false);
      })
      .catch(error => {
        setError(error);
        setLoading(false);
      });
  }, []);

  const handleDelete = async (id) => {
    try {
      await axios.delete(`http://52.45.45.87:8080/courses/${id}`);
      setCourses(courses.filter(course => course.id !== id));
    } catch (error) {
      console.error('Error deleting course:', error);
    }
  };

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;

  return (
    <div className="courses-container">
      <h1>Courses:</h1>
      <div className="button-group">
        <Link to="/add-course"><button className="btn-submit">Add New Course</button></Link>
        <button type="button" className="btn-home" onClick={() => navigate('/')}>Home</button>
      </div>
      <hr/>
      <div className="courses-list">
        {courses.map(course => (
          <div key={course.id} className="course-card">
            <h2>{course.title}</h2>
            <p><strong>Instructor:</strong> {course.instructor}</p>
            <p><strong>Duration:</strong> {course.duration} hours</p>
            <p><strong>Rating:</strong> {course.rating}</p>
            <p>{course.description}</p>
            <div className="course-steps">
              <h3>Steps:</h3>
              <ul>
                {course.steps.map((step, index) => (
                  <li key={index}>
                    <strong>{step.title}:</strong> {step.content}
                  </li>
                ))}
              </ul>
            </div>
            <button className="delete-btn" onClick={() => handleDelete(course.id)}>Delete</button>
          </div>
        ))}
      </div>
    </div>
  );
}

export default Courses;
