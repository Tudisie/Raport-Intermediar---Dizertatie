package com.example.backend.repository;

import com.example.backend.model.Course;
import com.example.backend.model.Step;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StepRepository extends JpaRepository<Step, Integer> {}
