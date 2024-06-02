package com.example.backend.service;


import com.example.backend.model.Course;
import com.example.backend.repository.CourseRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Objects;
import java.util.UUID;

@Service
public class CourseService {

    private final CourseRepository courseRepository;

    private final NotifyService notifyService;

    @Autowired
    public CourseService(CourseRepository courseRepository, NotifyService notifyService) {
        this.courseRepository = courseRepository;
        this.notifyService = notifyService;
    }

    public List<Course> getAllCourses() {
        return courseRepository.findAll();
    }

    public Course getCourse(int id) {
        return courseRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Course not found with id: " + id));
    }

    public Course createCourse(Course course) {
        return courseRepository.save(course);
    }

    @Transactional
    public void deleteCourse(UUID id) {
        List<Course> courses = courseRepository.findAll();
        for(Course course: courses){
            if(Objects.equals(course.getId().toString(), id.toString())) {
                courseRepository.delete(course);
                notifyService.email(course.getTitle());
            }
        }
    }
}