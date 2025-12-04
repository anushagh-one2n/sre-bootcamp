package com.example.student_app.controller;

import com.example.student_app.dto.StudentRequest;
import com.example.student_app.dto.StudentResponse;
import com.example.student_app.service.StudentService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.BDDMockito.given;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;


@ExtendWith(SpringExtension.class)
@WebMvcTest(StudentController.class)
@SuppressWarnings("unused")
class StudentControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private StudentService service;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void create_shouldReturnCreatedStudent() throws Exception {
        StudentRequest request = new StudentRequest("Alice", "alice@example.com", 9);
        StudentResponse response = new StudentResponse(1L, "Alice", "alice@example.com", 9);

        given(service.create(any(StudentRequest.class))).willReturn(response);

        mockMvc.perform(post("/api/v1/students")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").value(1L))
                .andExpect(jsonPath("$.name").value("Alice"))
                .andExpect(jsonPath("$.email").value("alice@example.com"))
                .andExpect(jsonPath("$.grade").value(9));
    }

    @Test
    void getAll_shouldReturnListOfStudents() throws Exception {
        List<StudentResponse> responses = List.of(
                new StudentResponse(1L, "A", "a@example.com", 7),
                new StudentResponse(2L, "B", "b@example.com", 8)
        );

        given(service.getAll()).willReturn(responses);

        mockMvc.perform(get("/api/v1/students"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(2))
                .andExpect(jsonPath("$[0].name").value("A"))
                .andExpect(jsonPath("$[1].email").value("b@example.com"));
    }

    @Test
    void getById_shouldReturnStudent() throws Exception {
        StudentResponse response = new StudentResponse(1L, "Charlie", "charlie@example.com", 10);

        given(service.getById(1L)).willReturn(response);

        mockMvc.perform(get("/api/v1/students/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1L))
                .andExpect(jsonPath("$.name").value("Charlie"))
                .andExpect(jsonPath("$.email").value("charlie@example.com"))
                .andExpect(jsonPath("$.grade").value(10));
    }

    @Test
    void update_shouldReturnUpdatedStudent() throws Exception {
        StudentRequest request = new StudentRequest("Updated", "updated@example.com", 11);
        StudentResponse response = new StudentResponse(1L, "Updated", "updated@example.com", 11);

        given(service.update(eq(1L), any(StudentRequest.class))).willReturn(response);

        mockMvc.perform(put("/api/v1/students/1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1L))
                .andExpect(jsonPath("$.name").value("Updated"))
                .andExpect(jsonPath("$.email").value("updated@example.com"))
                .andExpect(jsonPath("$.grade").value(11));
    }

    @Test
    void delete_shouldReturnNoContent() throws Exception {
        mockMvc.perform(delete("/api/v1/students/1"))
                .andExpect(status().isNoContent());

        Mockito.verify(service).delete(1L);
    }
}
