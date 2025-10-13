package com.huangyuan.movieboot;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication
@ComponentScan(basePackages = {"com.huangyuan.movieboot", "com.huangyuan.movieinterface", "com.huangyuan.lovespringbootstarterweb"})
public class MovieBootApplication {

    public static void main(String[] args) {
        SpringApplication.run(MovieBootApplication.class, args);
    }

}
