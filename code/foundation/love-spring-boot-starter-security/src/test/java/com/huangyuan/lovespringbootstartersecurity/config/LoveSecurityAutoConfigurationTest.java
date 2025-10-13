package com.huangyuan.lovespringbootstartersecurity.config;

import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.ApplicationContext;

@SpringBootTest(classes = LoveSecurityAutoConfiguration.class)
public class LoveSecurityAutoConfigurationTest {

    @Autowired
    private ApplicationContext applicationContext;

    @Test
    public void contextLoads() {
        // 验证Spring容器能够正确加载
        org.assertj.core.api.Assertions.assertThat(applicationContext).isNotNull();
    }
}



