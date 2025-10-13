package com.huangyuan.lovespringbootstartermybatis.config;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConditionalOnProperty(name = "love.mybatis.enabled", matchIfMissing = true)
public class MybatisAutoConfiguration {

    @Bean
    public MybatisPlusConfig mybatisPlusConfig() {
        return new MybatisPlusConfig();   // 里面配分页、多租户、链路ID
    }
}
