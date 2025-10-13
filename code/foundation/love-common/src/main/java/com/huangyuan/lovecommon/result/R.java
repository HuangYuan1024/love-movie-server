package com.huangyuan.lovecommon.result;

import com.huangyuan.lovecommon.PageDTO;

public class R<T> {
    private String code;
    private String msg;
    private T data;
    private PageDTO page;
    public R() {
    }
    public R(String code, String msg) {
        this.code = code;
        this.msg = msg;
    }
    public R(String code, String msg, T data) {
        this.code = code;
        this.msg = msg;
        this.data = data;
    }
    public R(String code, String msg, T data, PageDTO page) {
        this.code = code;
        this.msg = msg;
        this.data = data;
        this.page = page;
    }
    public static <T> R<T> success(T data) {
        return new R<T>(ResultCode.SUCCESS.getCode(), ResultCode.SUCCESS.getMessage(), data);
    }
    public static <T> R<T> success(T data, PageDTO page) {
        return new R<T>(ResultCode.SUCCESS.getCode(), ResultCode.SUCCESS.getMessage(), data, page);
    }
    public static <T> R<T> fail(ResultCode resultCode) {
        return new R<T>(resultCode.getCode(), resultCode.getMessage());
    }
    public static <T> R<T> fail(ResultCode resultCode, String msg) {
        return new R<T>(resultCode.getCode(), msg);
    }
    public static <T> R<T> fail(String code, String msg) {
        return new R<T>(code, msg);
    }
    public String getCode() {
        return code;
    }
    public void setCode(String code) {
        this.code = code;
    }
    public String getMsg() {
        return msg;
    }
    public void setMsg(String msg) {
        this.msg = msg;
    }
    public T getData() {
        return data;
    }
    public void setData(T data) {
        this.data = data;
    }
    public PageDTO getPage() {
        return page;
    }
    public void setPage(PageDTO page) {
        this.page = page;
    }
}
