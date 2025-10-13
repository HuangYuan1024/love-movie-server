package com.huangyuan.promotionboot;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication
@ComponentScan(basePackages = {"com.huangyuan.promotionboot", "com.huangyuan.promotioninterface", "com.huangyuan.lovespringbootstarterweb"})
public class PromotionBootApplication {

    public static void main(String[] args) {
        SpringApplication.run(PromotionBootApplication.class, args);
    }

}
