package com.huangyuan.orderboot;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication
@ComponentScan(basePackages = {"com.huangyuan.orderboot", "com.huangyuan.orderinterface", "com.huangyuan.lovespringbootstarterweb"})
public class OrderBootApplication {

    public static void main(String[] args) {
        SpringApplication.run(OrderBootApplication.class, args);
    }

}
