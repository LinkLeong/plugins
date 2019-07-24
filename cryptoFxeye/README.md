# 插件目录

## cryptoFxeye

### 功能

插件cryptoFxey为请求数据的方法,主要功能为对接口的加密和解密操作.

### 安装

```javascript
cordova plugin add FILEURL --variable API_URL=DNS --variable TOKEN_URL=TOKEN
```

该插件包含两个参数:

* API_URL实际请求的网关地址,和调用时传入的URL拼接成一个完成的请求地址.
* TOKEN_URL获取token的地址,不包括实际获取token的地址.

### 使用

#### 异步

```javascript
cordova.plugins.cryptoFxeye.coolMethod("post","/app/getuser","userId=03675").then((result,err)=>{
    //这是成功的返回
    console.log(result)
    //这是失败的返回
    console.log(err)
})
```

#### 回调

```javascript
cordova.plugins.cryptoFxeye.coolMethod("post","/app/getuser","userId=03675",function(result){
    //这是成功的回调
    console.log(result);
},function(error){
    //这是失败的回调
    console.log(error);
}))
```

调用形式为cordova.plugins.cryptoFxeye.coolMethod(method, action, dataStr, success, error);

* method请求类型post/get(需要转小写)
* action请求的实际地址
* dataStr请求的参数,插件内部不做任何处理,传参的格式参照实际请求地址要求的参数格式.
* 成功的回调
* 失败的回调
