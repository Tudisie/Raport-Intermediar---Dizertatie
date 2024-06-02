import React, { useState } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';
import '../styles/AddCourse.css';

function AddCourse() {
    const navigate = useNavigate();
  
    const [formData, setFormData] = useState({
      title: '',
      description: '',
      instructor: '',
      duration: 0,
      rating: 0,
      steps: [],
    });
  
    const handleChange = e => {
      const { name, value } = e.target;
      setFormData(prevState => ({
        ...prevState,
        [name]: value,
      }));
    };
  
    const handleSubmit = e => {
      e.preventDefault();
      axios.post('http://52.45.45.87:8080/courses', formData)
        .then(response => {
          console.log('Course created:', response.data);
          // Optionally, you can redirect the user or show a success message here
          navigate('/'); // Redirect to the default route '/'
        })
        .catch(error => {
          console.error('Error creating course:', error);
          // Handle error, show error message, etc.
        });
    };
  
    return (
      <div className="add-course-container">
        <h1>Add New Course</h1>
        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label>Title:</label>
            <input type="text" name="title" value={formData.title} onChange={handleChange} required />
          </div>
          <div className="form-group">
            <label>Description:</label>
            <textarea name="description" value={formData.description} onChange={handleChange} required />
          </div>
          <div className="form-group">
            <label>Instructor:</label>
            <input type="text" name="instructor" value={formData.instructor} onChange={handleChange} required />
          </div>
          <div className="form-group">
            <label>Duration (hours):</label>
            <input type="number" name="duration" value={formData.duration} onChange={handleChange} required />
          </div>
          <div className="form-group">
            <label>Rating:</label>
            <input type="number" name="rating" value={formData.rating} onChange={handleChange} required />
          </div>
          <div className="button-group">
            <button type="submit" className="btn-submit">Add Course</button>
            <button type="button" className="btn-home" onClick={() => navigate('/')}>Home</button>
          </div>
        </form>
      </div>
    );
  }
  
  export default AddCourse;