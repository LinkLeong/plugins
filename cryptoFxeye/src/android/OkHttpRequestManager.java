package cryptoFxeye;


import android.content.Context;
import android.os.Handler;
import android.util.Log;

import com.alibaba.fastjson.JSON;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.net.ConnectException;
import java.net.SocketTimeoutException;
import java.security.cert.CertificateException;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.SSLSocketFactory;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

/*
 okhttp 封装类
 */
public class OkHttpRequestManager {

    private static final MediaType MEDIA_TYPE_JSON = MediaType.parse("application/json; charset=utf-8");//mdiatype 这个需要和服务端保持一致
    private static final MediaType MEDIA_TYPE_STRING=MediaType.parse("application/x-www-form-urlencoded; charset=utf-8");

    private static volatile OkHttpRequestManager mInstance;//单利
    private OkHttpClient mOkHttpClient;//okhttpclient实例
    private Handler okHttpHandler;//全局处理子线程返回

    public static final int TYPE_GET=0;//get 请求
    public static final int TYPE_POST_JSON=1;//post请求参数为json
    public static final int TYPE_POST_STRING=2;//post请求参数为string

    private static final String TAG = "OkHttpRequestManager";

    private static   Context mContext;
    //公共请求参数


    /**
     * 初始化RequestManager
     */
    public OkHttpRequestManager(Context context) {
        //初始化OkHttpClient
        OkHttpClient.Builder builder = new OkHttpClient.Builder();
        try {
            // Create a trust manager that does not validate certificate chains
            final TrustManager[] trustAllCerts = new TrustManager[] {
                    new X509TrustManager() {
                        @Override
                        public void checkClientTrusted(java.security.cert.X509Certificate[] chain, String authType) throws CertificateException {
                        }

                        @Override
                        public void checkServerTrusted(java.security.cert.X509Certificate[] chain, String authType) throws CertificateException {
                        }

                        @Override
                        public java.security.cert.X509Certificate[] getAcceptedIssuers() {
                            return new java.security.cert.X509Certificate[]{};
                        }
                    }
            };

            // Install the all-trusting trust manager 跳过ssl
            final SSLContext sslContext = SSLContext.getInstance("SSL");
            sslContext.init(null, trustAllCerts, new java.security.SecureRandom());
            // Create an ssl socket factory with our all-trusting manager
            final SSLSocketFactory sslSocketFactory = sslContext.getSocketFactory();

            builder.sslSocketFactory(sslSocketFactory);
            builder.hostnameVerifier(new HostnameVerifier() {
                @Override
                public boolean verify(String hostname, SSLSession session) {
                    return true;
                }
            });

        } catch (Exception e) {
            throw new RuntimeException(e);
        }

        builder.connectTimeout(5, TimeUnit.SECONDS);
        builder.readTimeout(10, TimeUnit.SECONDS);//设置读取超时时间
        builder.writeTimeout(10, TimeUnit.SECONDS);//设置写入超时时间
        mOkHttpClient = builder.build();
        //初始化Handler
        okHttpHandler = new Handler(context.getMainLooper());
    }


    /**
     * 获取单例
     * @param context
     * @return
     */
    public static OkHttpRequestManager getInstance(Context context){
        mContext=context;
        OkHttpRequestManager inst=mInstance;
        if (inst == null) {
            synchronized (OkHttpRequestManager.class){
                inst=mInstance;
                if (inst == null) {
                    inst=new OkHttpRequestManager(context.getApplicationContext());
                    mInstance=inst;
                }
            }
        }
        return inst;
    }


    /**
     * 统一同步请求
     * @param actionUrl
     * @param requestType
     * @param paramsMap
     */
    public void requestSyn(String actionUrl, int requestType, Map<String,String> paramsMap){
        switch (requestType) {
            case TYPE_GET:
                requestGetBySyn(actionUrl, paramsMap);
                break;
            case TYPE_POST_JSON:
                requestPostBySyn(actionUrl, paramsMap);
                break;
        }
    }

    /**
     * 同步请求POST JSON
     * @param actionUrl
     * @param paramsMap
     */
    private void requestPostBySyn(String actionUrl, Map<String, String> paramsMap) {

        StringBuilder tempParams=new StringBuilder();

        try {
            int pos=0;
            for (String key : paramsMap.keySet()) {
                if (pos>0){
                    tempParams.append("&");
                }

                tempParams.append(String.format("%s=%s",key,paramsMap.get(key)));
                pos++;
            }

            //生成参数
            String params = tempParams.toString();

            RequestBody body = RequestBody.create(MEDIA_TYPE_JSON, params);
            final Request request = addHeaders().url(actionUrl).post(body).build();
            final Call call = mOkHttpClient.newCall(request);
            Response response = call.execute();

            if (response.isSuccessful()) {
                //获取返回数据 可以是String，bytes ,byteStream
                Log.e(TAG, "response ----->" + response.body().string());
            }

        } catch (Exception e) {
            e.printStackTrace();
            Log.e(TAG, "requestGetBySyn: "+e.toString() );
        }

    }

    /**
     * 同步请求GET
     * @param actionUrl
     * @param paramsMap
     */
    private void requestGetBySyn(String actionUrl, Map<String, String> paramsMap) {

        StringBuilder tempParams=new StringBuilder();

        try {
            int pos=0;
            for (String key : paramsMap.keySet()) {
                if (pos>0){
                    tempParams.append("&");
                }

                tempParams.append(String.format("%s=%s",key,paramsMap.get(key)));
                pos++;
            }

            //补全请求地址
            String requestUrl = String.format("%s?%s", actionUrl, tempParams.toString());
            Logger.getLogger(getClass()).d("mOkHttpRequest GET =%s", requestUrl);
            //创建一个请求
            Request request = addHeaders().url(requestUrl).build();
            //创建一个call
            final Call call=mOkHttpClient.newCall(request);
            //执行请求
            Response response = call.execute();
            String result = request.body().toString();
        } catch (Exception e) {
            e.printStackTrace();
            Log.e(TAG, "requestGetBySyn: "+e.toString() );
        }

    }

    /**
     * 异步请求统一管理
     * @param actionUrl
     * @param requestType
     * @param paramsMap
     * @param callBack
     * @param <T>
     * @return
     */
    public <T> Call requestAsyn(String actionUrl,int requestType,Map<String,Object> paramsMap,ReqCallBack<T> callBack){
        Call call=null;
        switch (requestType) {
            case TYPE_GET:
                call=requestGetByASyn(actionUrl,paramsMap,callBack);
                break;
            case TYPE_POST_JSON:
                call = requestPostByAsyn(actionUrl, paramsMap, callBack);
                break;
            case TYPE_POST_STRING:
                call=requestPostStingAsyn(actionUrl,paramsMap,callBack);
                break;
        }
        return call;
    }

    /**
     * get 异步请求
     * @param actionUrl
     * @param paramsMap
     * @param callBack
     * @param <T>
     * @return
     */
    private <T> Call requestGetByASyn(String actionUrl, Map<String, Object> paramsMap, final ReqCallBack<T> callBack) {
        StringBuilder tempParams = new StringBuilder();
        try {
            int pos = 0;
            for (String key : paramsMap.keySet()) {
                if (pos > 0) {
                    tempParams.append("&");
                }
//                tempParams.append( URLEncoder.encode(key,"UTF-8") + "=" +
//                        URLEncoder.encode(paramsMap.get(key),"UTF-8"));
                tempParams.append( key+ "=" +
                        paramsMap.get(key));
                pos++;
            }
            String queryString =  tempParams.toString();
            String requestUrl = String.format("%s?%s",  actionUrl, queryString);
            Logger.getLogger(getClass()).d("mOkHttpRequest GET =%s", requestUrl);
            final Request request = addHeaders().url(requestUrl).build();
            final Call call = mOkHttpClient.newCall(request);

            call.enqueue(new Callback() {
                @Override
                public void onFailure(Call call, IOException e) {
                    failedCallBack("访问失败", callBack);
                    Log.e(TAG, e.toString());
                }

                @Override
                public void onResponse(Call call, Response response) throws IOException {
                    String string = response.body().string();
                    Logger.getLogger(getClass()).d("mOkHttpRequest GET =%s", string);
                    if (response.isSuccessful()) {

                        successCallBack((T) string, callBack);
                    } else {
                        failedCallBack("服务器错误", callBack);
                    }
                }
            });
            return call;
        } catch (Exception e) {
            Log.e(TAG, e.toString());
        }
        return null;
    }

    /**
     * get 异步请求
     * @param actionUrl
     * @param paramsMap
     * @param callBack
     * @param <T>
     * @return
     */
    public  <T> Call getByASyn(String actionUrl, String paramsMap, final ReqCallBack<T> callBack) {
          try {
            String requestUrl = String.format("%s?%s",  actionUrl, paramsMap);
            Logger.getLogger(getClass()).d("mOkHttpRequest GET =%s", requestUrl);
            final Request request = addHeaders().url(requestUrl).build();
            final Call call = mOkHttpClient.newCall(request);

            call.enqueue(new Callback() {
                @Override
                public void onFailure(Call call, IOException e) {
                    if (e instanceof SocketTimeoutException) {
                        //超时
                        failedCallBack("1", callBack);
                    }else if (e instanceof ConnectException){
                        //连接
                        failedCallBack("0", callBack);
                    }else {
                        failedCallBack("访问失败", callBack);
                    }
                    Log.e(TAG, e.toString());
                }

                @Override
                public void onResponse(Call call, Response response) throws IOException {
                    try {
                        String string = response.body().string();
                        Logger.getLogger(getClass()).d("mOkHttpRequest GET =%s", string);
                        if (response.isSuccessful()) {

                            JSONObject jsonObject = new JSONObject(string);
                            if (jsonObject.has("Success")&&jsonObject.has("code")) {
                                if ("401".equals(jsonObject.getString("code"))){
                                    failedCallBack("401", callBack);
                                }else if ("200".equals(jsonObject.getString("code"))){
                                    successCallBack((T) jsonObject.getString("Data"), callBack);
                                }else {
                                    failedCallBack("服务器错误", callBack);
                                }
                            }else {
                                failedCallBack("服务器错误", callBack);
                            }
                        } else {
//                            int code = response.code();
//                            if (401==code){
//                                failedCallBack("401", callBack);
//                            }else {
                                failedCallBack("服务器错误", callBack);
//                            }
                        }
                    } catch (JSONException e) {
                        e.printStackTrace();
                        failedCallBack("服务器错误", callBack);
                    }
                }
            });
            return call;
        } catch (Exception e) {
            Log.e(TAG, e.toString());
        }
        return null;
    }



    /**
     * get 异步请求 noToken
     * @param actionUrl
     * @param paramsMap
     * @param callBack
     * @param <T>
     * @return
     */
    public  <T> Call requestGetByASynNo(String actionUrl, Map<String, Object> paramsMap, final ReqCallBack<T> callBack) {
        StringBuilder tempParams = new StringBuilder();
        try {
            int pos = 0;
            for (String key : paramsMap.keySet()) {
                if (pos > 0) {
                    tempParams.append("&");
                }
//                tempParams.append( URLEncoder.encode(key,"UTF-8") + "=" +
//                        URLEncoder.encode(paramsMap.get(key),"UTF-8"));
                tempParams.append( key+ "=" +
                        paramsMap.get(key));
                pos++;
            }
            String queryString =  tempParams.toString();
            String requestUrl = String.format("%s?%s",  actionUrl, queryString);
            Request.Builder builder=new Request.Builder()
                    .addHeader("Content-Type","application/json;charset=UTF-8");
            final Request request = builder.url(requestUrl).build();
            final Call call = mOkHttpClient.newCall(request);

            call.enqueue(new Callback() {
                @Override
                public void onFailure(Call call, IOException e) {

                    if (e instanceof SocketTimeoutException) {
                        //超时
                        failedCallBack("1", callBack);
                    }else if (e instanceof ConnectException){
                        //连接
                        failedCallBack("0", callBack);
                    }else {
                        failedCallBack("访问失败", callBack);
                    }
                    Log.e(TAG, e.toString());
                }

                @Override
                public void onResponse(Call call, Response response) throws IOException {
                    String string = response.body().string();
                    Logger.getLogger(getClass()).d("mOkHttpRequest GET =%s", string);
                    if (response.isSuccessful()) {

                        successCallBack((T) string, callBack);
                    } else {
                        failedCallBack("服务器错误", callBack);
                    }
                }
            });
            return call;
        } catch (Exception e) {
            Log.e(TAG, e.toString());
        }
        return null;
    }


    /**
     * okHttp post异步请求
     * @param requestUrl 接口地址
     * @param paramsMap 请求参数
     * @param callBack 请求返回数据回调
     * @param <T> 数据泛型
     * @return
     */
    private <T> Call requestPostByAsyn(String requestUrl, Map<String, Object> paramsMap, final ReqCallBack<T> callBack) {
        try {
            StringBuilder tempParams = new StringBuilder();
//            int pos = 0;
//            for (String key : paramsMap.keySet()) {
//                if (pos > 0) {
//                    tempParams.append("&");
//                }
//                tempParams.append(String.format("%s=%s", key, paramsMap.get(key)));
//                pos++;
//            }

            String params =JSON.toJSONString(paramsMap);// HttpSignUtil.mapToJson(paramsMap, tempParams);
//            String params = tempParams.toString();
            Logger.getLogger(getClass()).d("mOkHttpRequest Post =%s?%s", requestUrl,params);
            RequestBody body = RequestBody.create(MEDIA_TYPE_JSON, params);
            final Request request = addHeaders().url(requestUrl).post(body).build();
            final Call call = mOkHttpClient.newCall(request);
            call.enqueue(new Callback() {
                @Override
                public void onFailure(Call call, IOException e) {
                    failedCallBack("访问失败", callBack);
                    Log.e(TAG, e.toString());
                }

                @Override
                public void onResponse(Call call, Response response) throws IOException {
                    String string = response.body().string();
                    Logger.getLogger(getClass()).d("mOkHttpRequest POST =%s", string);
                    if (response.isSuccessful()) {

                        successCallBack((T) string, callBack);
                    } else {
                        failedCallBack("服务器错误", callBack);
                    }
                }
            });
            return call;
        } catch (Exception e) {
            Log.e(TAG, e.toString());
        }
        return null;
    }


    /**
     * okHttp post 改个请求头异步请求
     * @param requestUrl 接口地址
     * @param paramsMap 请求参数
     * @param callBack 请求返回数据回调
     * @param <T> 数据泛型
     * @return
     */
    public  <T> Call postAsynHeader(String requestUrl, String paramsMap, final ReqCallBack<T> callBack) {
        try {
            StringBuilder tempParams = new StringBuilder();
//            int pos = 0;
//            for (String key : paramsMap.keySet()) {
//                if (pos > 0) {
//                    tempParams.append("&");
//                }
//                tempParams.append(String.format("%s=%s", key, paramsMap.get(key)));
//                pos++;
//            }

//            String params =JSON.toJSONString(paramsMap);// HttpSignUtil.mapToJson(paramsMap, tempParams);
            String params = paramsMap;
            Logger.getLogger(getClass()).d("mOkHttpRequest Post =%s?%s", requestUrl,params);
            String tokenString = (String) SPUtils.get(mContext, "tokenString", "1");
            RequestBody body = RequestBody.create(MEDIA_TYPE_JSON, params);
            Request.Builder builder=new Request.Builder()
                    .addHeader("Content-Type","application/x-www-form-urlencoded")
                    .addHeader("Authorization",tokenString )
                    ;
            final Request request = builder.url(requestUrl).post(body).build();
            final Call call = mOkHttpClient.newCall(request);
            call.enqueue(new Callback() {
                @Override
                public void onFailure(Call call, IOException e) {
                    if (e instanceof SocketTimeoutException) {
                        //超时
                        failedCallBack("1", callBack);
                    }else if (e instanceof ConnectException){
                        //连接
                        failedCallBack("0", callBack);
                    }else {
                        failedCallBack("访问失败", callBack);
                    }
                    Log.e(TAG, e.toString());
                }

                @Override
                public void onResponse(Call call, Response response) throws IOException {
                    try {
                        String string = response.body().string();
                        Logger.getLogger(getClass()).d("mOkHttpRequest GET =%s", string);
                        if (response.isSuccessful()) {

                            JSONObject jsonObject = new JSONObject(string);
                            if (jsonObject.has("Success")&&jsonObject.has("code")) {
                                if ("401".equals(jsonObject.getString("code"))){
                                    failedCallBack("401", callBack);
                                }else if ("200".equals(jsonObject.getString("code"))){
                                    successCallBack((T) jsonObject.getString("Data"), callBack);
                                }else {
                                    failedCallBack("服务器错误", callBack);
                                }
                            }else {
                                failedCallBack("服务器错误", callBack);
                            }

                        } else {
//                            int code = response.code();
//                            if (401==code){
//                                failedCallBack("401", callBack);
//                            }else {
                            failedCallBack("服务器错误", callBack);
//                            }
                        }
                    } catch (JSONException e) {
                        e.printStackTrace();
                        failedCallBack("服务器错误", callBack);
                    }
                }
            });
            return call;
        } catch (Exception e) {
            Log.e(TAG, e.toString());
        }
        return null;
    }

    private <T> Call requestPostStingAsyn(String requestUrl, Map<String, Object> paramsMap, final ReqCallBack<T> callBack) {
        try {
            StringBuilder tempParams = new StringBuilder();
            int pos = 0;
            for (String key : paramsMap.keySet()) {
                if (pos > 0) {
                    tempParams.append("&");
                }
                tempParams.append(String.format("%s=%s", key, paramsMap.get(key)));
                pos++;
            }

            String params = tempParams.toString();
            Logger.getLogger(getClass()).d("mOkHttpRequest Post =%s?%s", requestUrl,params);
            RequestBody body = RequestBody.create(MEDIA_TYPE_STRING, params);
            final Request request = addHeaders().url(requestUrl).post(body).build();
            final Call call = mOkHttpClient.newCall(request);
            call.enqueue(new Callback() {
                @Override
                public void onFailure(Call call, IOException e) {
                    failedCallBack("访问失败", callBack);
                    Log.e(TAG, e.toString());
                }

                @Override
                public void onResponse(Call call, Response response) throws IOException {
                    String string = response.body().string();
                    Logger.getLogger(getClass()).d("mOkHttpRequest POST =%s", string);
                    if (response.isSuccessful()) {

                        successCallBack((T) string, callBack);
                    } else {
                        int code = response.code();
                        if (401==code){
                            failedCallBack("401", callBack);
                        }else {
                            failedCallBack("服务器错误", callBack);
                        }

                    }
                }
            });
            return call;
        } catch (Exception e) {
            Log.e(TAG, e.toString());
        }
        return null;
    }



    /**
     * 统一添加请求头
     * @return
     */
    private Request.Builder addHeaders(){

        StringBuilder sb=new StringBuilder();
        //        sb.append("uid=android")
//                .append(UpdateTool.getVerName(ImportApplication.getAppContext()))
//                .append("##")
//                .append(Shoputils.getDeviceInfo(ImportApplication.getAppContext()))
//                .append("; yiwugouid=")
//                .append(User.userId)
        ;
        String tokenString = (String) SPUtils.get(mContext, "tokenString", "1");
        Log.e(TAG, "addHeaders: "+tokenString );
        Request.Builder builder=new Request.Builder()
                .addHeader("Authorization",tokenString )
                .addHeader("Content-Type","application/json;charset=UTF-8")
//                        .addHeader("Connection", "keep-alive")
//                .addHeader("platform", "2")
//                .addHeader("phoneModel", Build.MODEL)
//                .addHeader("systemVersion", Build.VERSION.RELEASE)
//                .addHeader("Cookie", sb.toString())
                 ;
        return builder;
    }


    /**
     * 统一处理成功信息
     * @param result
     * @param callBack
     * @param <T>
     */
    private <T> void successCallBack(final T result,final ReqCallBack<T> callBack){
        okHttpHandler.post(new Runnable() {
            @Override
            public void run() {
                if (callBack != null) {
                    callBack.onSuccess(result);
                }
            }
        });
    }


    /**
     * 统一处理失败信息
     * @param msg
     * @param callBack
     * @param <T>
     */
    private <T> void failedCallBack(final String msg,final ReqCallBack<T> callBack){
        okHttpHandler.post(new Runnable() {
            @Override
            public void run() {
                if (callBack != null) {
                    callBack.onFailed(msg);
                }
            }
        });
    }


    public interface ReqCallBack<T>{

        /**
         * 相映成功
         * @param result
         */
        void onSuccess(T result);

        /**
         * 响应失败
         * @param errorMsg
         */
        void onFailed(String errorMsg);

    }

}
