package com.example.backend.controller;


import com.example.backend.model.Step;
import com.example.backend.service.StepService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@CrossOrigin(maxAge = 3600)
@RestController
public class StepController {
    @Autowired
    private StepService stepService;


    @PostMapping("/steps")
    public Step createCourse(@RequestBody Step step) {
        return stepService.createStep(step);
    }
}