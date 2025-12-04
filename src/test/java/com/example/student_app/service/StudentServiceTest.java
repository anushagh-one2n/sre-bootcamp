package com.example.student_app.service;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.*;

import com.example.student_app.dto.StudentRequest;
import com.example.student_app.dto.StudentResponse;
import com.example.student_app.entity.Student;
import com.example.student_app.exception.StudentNotFoundException;
import com.example.student_app.repository.StudentRepository;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class StudentServiceTest {

    @Mock private StudentRepository repository;

    @InjectMocks private StudentService service;

    @Test
    void create_shouldSaveStudentAndReturnResponse() {
        StudentRequest request = new StudentRequest("Alice", "alice@example.com", 9);
        Student saved = new Student("Alice", "alice@example.com", 9);

        when(repository.save(any(Student.class))).thenReturn(saved);

        StudentResponse response = service.create(request);

        ArgumentCaptor<Student> studentCaptor = ArgumentCaptor.forClass(Student.class);
        verify(repository, times(1)).save(studentCaptor.capture());

        Student toSave = studentCaptor.getValue();
        assertEquals("Alice", toSave.getName());
        assertEquals("alice@example.com", toSave.getEmail());
        assertEquals(9, toSave.getGrade());

        assertEquals("Alice", response.name());
        assertEquals("alice@example.com", response.email());
        assertEquals(9, response.grade());
    }

    @Test
    void getAll_shouldReturnListOfResponses() {
        Student s1 = new Student("A", "a@example.com", 7);
        Student s2 = new Student("B", "b@example.com", 8);

        when(repository.findAll()).thenReturn(List.of(s1, s2));

        List<StudentResponse> responses = service.getAll();

        verify(repository, times(1)).findAll();
        assertEquals(2, responses.size());
        assertEquals("A", responses.get(0).name());
        assertEquals("b@example.com", responses.get(1).email());
    }

    @Test
    void getById_shouldReturnResponseWhenStudentExists() {
        Student s = new Student("Charlie", "charlie@example.com", 10);
        when(repository.findById(1L)).thenReturn(Optional.of(s));

        StudentResponse response = service.getById(1L);

        verify(repository, times(1)).findById(1L);
        assertEquals("Charlie", response.name());
        assertEquals("charlie@example.com", response.email());
        assertEquals(10, response.grade());
    }

    @Test
    void getById_shouldThrowWhenStudentDoesNotExist() {
        when(repository.findById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.getById(99L))
                .isInstanceOf(StudentNotFoundException.class)
                .hasMessageContaining("Student not found with id 99");

        verify(repository, times(1)).findById(99L);
    }

    @Test
    void update_shouldModifyExistingStudentAndReturnResponse() {
        Student existing = new Student("Old Name", "old@example.com", 5);
        when(repository.findById(1L)).thenReturn(Optional.of(existing));

        Student updatedEntity = new Student("New Name", "new@example.com", 9);
        when(repository.save(existing)).thenReturn(updatedEntity);

        StudentRequest request = new StudentRequest("New Name", "new@example.com", 9);

        StudentResponse response = service.update(1L, request);

        verify(repository, times(1)).findById(1L);
        verify(repository, times(1)).save(existing);

        assertEquals("New Name", existing.getName());
        assertEquals("new@example.com", existing.getEmail());
        assertEquals(9, existing.getGrade());

        assertEquals("New Name", response.name());
        assertEquals("new@example.com", response.email());
        assertEquals(9, response.grade());
    }

    @Test
    void update_shouldThrowWhenStudentDoesNotExist() {
        StudentRequest request = new StudentRequest("X", "x@example.com", 1);
        when(repository.findById(42L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.update(42L, request))
                .isInstanceOf(StudentNotFoundException.class)
                .hasMessageContaining("Student not found with id 42");

        verify(repository, times(1)).findById(42L);
        verify(repository, never()).save(any());
    }

    @Test
    void delete_shouldCallRepositoryDeleteById() {
        service.delete(5L);

        verify(repository, times(1)).deleteById(5L);
    }
}
