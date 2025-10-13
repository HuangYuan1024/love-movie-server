package com.huangyuan.userboot;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication
@ComponentScan(basePackages = {"com.huangyuan.userboot", "com.huangyuan.userinterface"})
public class UserBootApplication {

    public static void main(String[] args) {
        SpringApplication.run(UserBootApplication.class, args);
    }

}
