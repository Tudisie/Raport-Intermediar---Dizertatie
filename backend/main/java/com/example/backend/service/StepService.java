package com.example.backend.service;


import com.example.backend.model.Step;
import com.example.backend.repository.StepRepository;
import org.springframework.stereotype.Service;

@Service
public class StepService {

    private final StepRepository stepRepository;

    public StepService(StepRepository stepRepository) {
        this.stepRepository = stepRepository;
    }

    public Step createStep(Step step) {
        return stepRepository.save(step);
    }

}