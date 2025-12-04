package com.example.student_app.service;

import com.example.student_app.dto.StudentRequest;
import com.example.student_app.dto.StudentResponse;
import com.example.student_app.entity.Student;
import com.example.student_app.exception.StudentNotFoundException;
import com.example.student_app.repository.StudentRepository;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

@Service
public class StudentService {

    private final StudentRepository repository;
    private final Logger logger = LoggerFactory.getLogger(this.getClass());

    public StudentService(StudentRepository repository) {
        this.repository = repository;
    }

    public StudentResponse create(StudentRequest request) {
        Student student = new Student(request.name(), request.email(), request.grade());
        Student saved = repository.save(student);
        logger.debug("Saved new student with id- {}", saved.getId());
        return new StudentResponse(
                saved.getId(), saved.getName(), saved.getEmail(), saved.getGrade());
    }

    public List<StudentResponse> getAll() {
        return repository.findAll().stream()
                .map(s -> new StudentResponse(s.getId(), s.getName(), s.getEmail(), s.getGrade()))
                .toList();
    }

    public StudentResponse getById(Long id) {
        Student student =
                repository.findById(id).orElseThrow(() -> new StudentNotFoundException(id));
        return new StudentResponse(
                student.getId(), student.getName(), student.getEmail(), student.getGrade());
    }

    public StudentResponse update(Long id, StudentRequest request) {
        Student existing =
                repository.findById(id).orElseThrow(() -> new StudentNotFoundException(id));

        existing.update(request.name(), request.email(), request.grade());
        Student updated = repository.save(existing);

        logger.debug("Updated student with id- {}", updated.getId());

        return new StudentResponse(
                updated.getId(), updated.getName(), updated.getEmail(), updated.getGrade());
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
}
