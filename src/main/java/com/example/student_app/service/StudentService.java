package com.example.student_app.service;

import com.example.student_app.dto.StudentRequest;
import com.example.student_app.dto.StudentResponse;
import com.example.student_app.entity.Student;
import com.example.student_app.repository.StudentRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class StudentService {

    private final StudentRepository repository;

    public StudentService(StudentRepository repository) {
        this.repository = repository;
    }

    public StudentResponse create(StudentRequest request) {
        Student student = new Student(request.name(), request.email(), request.grade());
        Student saved = repository.save(student);
        return new StudentResponse(saved.getId(), saved.getName(), saved.getEmail(), saved.getGrade());
    }

    public List<StudentResponse> getAll() {
        return repository.findAll()
                .stream()
                .map(s -> new StudentResponse(s.getId(), s.getName(), s.getEmail(), s.getGrade()))
                .toList();
    }

    public StudentResponse getById(Long id) {
        Student student = repository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Student not found with id " + id));
        return new StudentResponse(student.getId(), student.getName(), student.getEmail(), student.getGrade());
    }

    public StudentResponse update(Long id, StudentRequest request) {
        Student existing = repository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Student not found with id " + id));

        existing.update(request.name(), request.email(), request.grade());
        Student updated = repository.save(existing);

        return new StudentResponse(updated.getId(), updated.getName(), updated.getEmail(), updated.getGrade());
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
}
