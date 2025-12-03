package com.example.student_app.entity;


import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Student {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private String email;
    private Integer grade;

    public Student(String name, String email, Integer grade) {
        this.name = name;
        this.email = email;
        this.grade = grade;
    }

    public void update(String name, String email, Integer grade) {
        this.name = name;
        this.email = email;
        this.grade = grade;
    }
}
