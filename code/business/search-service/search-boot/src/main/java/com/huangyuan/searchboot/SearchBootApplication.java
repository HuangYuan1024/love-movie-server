package com.huangyuan.searchboot;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication
@ComponentScan(basePackages = {"com.huangyuan.searchboot", "com.huangyuan.searchinterface", "com.huangyuan.lovespringbootstarterweb"})
public class SearchBootApplication {

    public static void main(String[] args) {
        SpringApplication.run(SearchBootApplication.class, args);
    }

}
