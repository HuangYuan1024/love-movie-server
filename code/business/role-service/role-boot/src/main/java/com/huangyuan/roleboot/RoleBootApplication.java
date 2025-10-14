package com.huangyuan.roleboot;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication
@ComponentScan(basePackages = {"com.huangyuan.roleboot", "com.huangyuan.roleinterface", "com.huangyuan.lovespringbootstarterweb"})
public class RoleBootApplication {

    public static void main(String[] args) {
        SpringApplication.run(RoleBootApplication.class, args);
    }

}
