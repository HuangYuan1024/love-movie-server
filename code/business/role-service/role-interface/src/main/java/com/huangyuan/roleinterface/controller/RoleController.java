package com.huangyuan.roleinterface.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/admin/system/sysRole")
public class RoleController {

    @Autowired
    private SysRoleService sysRoleService;

    // http://localhost:8080/admin/system/sysRole/findAll

    // http://localhost:8080/admin/system/sysRole/findAll

    // 查询全部记录
    @ApiOperation("查询全部接口")
    @GetMapping("/findAll")
    public List<SysRole> findAll()
    {
        List<SysRole> list = this.sysRoleService.list();
        return list;
    }

    // 根据id 去逻辑删除
    @ApiOperation("逻辑删除接口")
    @DeleteMapping("/remove/{id}")
    public boolean removeRole(@PathVariable Long id)
    {
        boolean isSuccess = this.sysRoleService.removeById(id);
        return isSuccess;
    }
}
