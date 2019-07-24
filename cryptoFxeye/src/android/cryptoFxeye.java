package cryptoFxeye;

import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.widget.Toast;

import com.alibaba.fastjson.JSON;



import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

import okhttp3.Call;

/**
 * This class echoes a string called from JavaScript.
 */
public class cryptoFxeye extends CordovaPlugin {

//    private ThreadLocal<CallbackContext> contextThreadLocal=new ThreadLocal<>();
//    private ThreadLocal<JSONArray> arrayThreadLocal=new ThreadLocal<>();

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("coolMethod")) {


            cordova.getThreadPool().execute(new Runnable() {
                @Override
                public void run() {

                    if (MyString.itNet(cordova.getContext())) {
                        coolMethod(args, callbackContext);
                    }else {
                        Map<String,Object> map =new HashMap<>();
                        map.put("success",false);
                        map.put("code",0);
                        map.put("msg","网络断网");
                        JSONObject jsonObject = new JSONObject(map);
                        callbackContext.success(jsonObject);
                    }

                }
            });

            return true;
        }
        return false;
    }

    private void coolMethod(JSONArray args, CallbackContext callbackContext) {

        try {
            isFirst=true;
            String tokenString = (String) SPUtils.get(cordova.getContext(),
                    "tokenString", "");
            if (tokenString!=null&&tokenString.length()>5){
                if ("get".equals(args.get(0))) {
                    getHttp(args,callbackContext);
                }else {
                    postHttp(args,callbackContext);
                }
            }else {
                getToken(args,callbackContext);
            }


        } catch (JSONException e) {
            e.printStackTrace();
            callbackContext.error("onFailed");
        }

    }

    private void postHttp(final JSONArray args,final CallbackContext callbackContext) {

        String url= "";
        String param="";
        try {
            url = getMetaValue(cordova.getContext(), "api_url")+args.getString(1);
            param=args.getString(2);
        } catch (JSONException e) {
            e.printStackTrace();
        }

//        String url= MyString.BASE_URL+"app/feedback";
//        Map<String,Object> map=new HashMap<>();
//        map.put("TraderCode","9731833838");
//        map.put("UserName","阿里巴巴");
//        map.put("Mobile","13333333333");
//        map.put("Content","太垃圾了");
//        String param = JSON.toJSONString(map);
        Call call = OkHttpRequestManager.getInstance(cordova.getContext()).postAsynHeader(url, param,
                new OkHttpRequestManager.ReqCallBack<String>() {
                    @Override
                    public void onSuccess(String result) {

                        try {
                            JSONObject jsonObject = new JSONObject(result);
                            callbackContext.success(jsonObject);
                        } catch (JSONException e) {
                            e.printStackTrace();
                            callbackContext.error("onFailed");
                        }


                        Log.e("TAG", "onReqSuccess: "+result );
                    }

                    @Override
                    public void onFailed(String errorMsg) {
                        if ("401".equals(errorMsg)){
                            if (isFirst){
                                isFirst=false;
                                getToken(args,callbackContext);
                            }else {
                                callbackContext.error("onFailed"+errorMsg);
                            }

                        }else {
                            if ("0".equals(errorMsg)) {
                                Map<String,Object> map =new HashMap<>();
                                map.put("success",false);
                                map.put("code",0);
                                map.put("msg","网络断网");
                                JSONObject jsonObject = new JSONObject(map);
                                callbackContext.success(jsonObject);
                            }else if ("1".equals(errorMsg)){
                                Map<String,Object> map =new HashMap<>();
                                map.put("success",false);
                                map.put("code",1);
                                map.put("msg","网络超时");
                                JSONObject jsonObject = new JSONObject(map);
                                callbackContext.success(jsonObject);
                            }else {
                                callbackContext.error("onFailed"+errorMsg);
                            }
                            Log.e("TAG", "onFailed: "+errorMsg );
                        }
                    }
                });
    }

    private static final String TAG = "cryptoFxeye";
    private void getHttp(final JSONArray args,final CallbackContext callbackContext) {

//        String url= MyString.BASE_URL +"app/getofflinerank";

        String url= "";
        String param="";
        try {
            url =getMetaValue(cordova.getContext(), "api_url")+args.getString(1);
            param=args.getString(2);
        } catch (JSONException e) {
            e.printStackTrace();
        }

//         url="http://192.168.1.128:5100/business/"+"app/getofflinerank";
//         param="top=10&dt=2019-05";
//        Log.e(TAG, "getHttp: "+url );
//        Log.e(TAG, "getHttp: "+param );

        Call call = OkHttpRequestManager.getInstance(cordova.getContext()).getByASyn(url,param,
                new OkHttpRequestManager.ReqCallBack<String>() {
                    @Override
                    public void onSuccess(String result) {
                        try {
                            JSONObject jsonObject = new JSONObject(result);
                            callbackContext.success(jsonObject);
                        } catch (JSONException e) {
                            e.printStackTrace();
                            callbackContext.error("onFailed");
                        }
                    }

                    @Override
                    public void onFailed(String errorMsg) {
                        if ("401".equals(errorMsg)){
                            if (isFirst){
                                isFirst=false;
                                getToken(args,callbackContext);
                            }else {
                                callbackContext.error("onFailed"+errorMsg);
                            }

                        }else {

                            if ("0".equals(errorMsg)) {
                                Map<String,Object> map =new HashMap<>();
                                map.put("success",false);
                                map.put("code",0);
                                map.put("msg","网络断网");
                                JSONObject jsonObject = new JSONObject(map);
                                callbackContext.success(jsonObject);
                            }else if ("1".equals(errorMsg)){
                                Map<String,Object> map =new HashMap<>();
                                map.put("success",false);
                                map.put("code",1);
                                map.put("msg","网络超时");
                                JSONObject jsonObject = new JSONObject(map);
                                callbackContext.success(jsonObject);
                            }else {
                                callbackContext.error("onFailed"+errorMsg);
                            }

                            Log.e("TAG", "onFailed: "+errorMsg );
                        }
                    }
                });

    }

    private boolean isFirst=true;

    private void getToken(final JSONArray args,final CallbackContext callbackContext){

        String url=getMetaValue(cordova.getContext(), "token_url")+"/api/Permission/Login";
        Map<String,Object> map=new HashMap<>();
        map.put("username","gsw");
        map.put("password","1");

        OkHttpRequestManager.getInstance(cordova.getContext()).requestGetByASynNo(url, map, new OkHttpRequestManager.ReqCallBack<String>() {
            @Override
            public void onSuccess(String result) {

                try {

                    JSONObject jsonObject = new JSONObject(result);
                    if (jsonObject.getBoolean("status")) {
                        GetTokenBean getTokenBean = JSON.parseObject(result, GetTokenBean.class);
                        String tokenString=getTokenBean.getToken_type()+" "+getTokenBean.getAccess_token();
                        SPUtils.put(cordova.getContext(),"tokenString",tokenString);

                        try {
                            isFirst=true;
                            if ("get".equals(args.get(0))) {
                                getHttp(args,callbackContext);
                            }else {
                                postHttp(args,callbackContext);
                            }
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                    }

                } catch (Exception e) {
                    e.printStackTrace();
                    Log.e("TAG", "onFailed: "+e.toString() );
                }
            }

            @Override
            public void onFailed(String errorMsg) {
                if ("0".equals(errorMsg)) {
                    Map<String,Object> map =new HashMap<>();
                    map.put("success",false);
                    map.put("code",0);
                    map.put("msg","网络断网");
                    JSONObject jsonObject = new JSONObject(map);
                    callbackContext.success(jsonObject);
                }else if ("1".equals(errorMsg)){
                    Map<String,Object> map =new HashMap<>();
                    map.put("success",false);
                    map.put("code",1);
                    map.put("msg","网络超时");
                    JSONObject jsonObject = new JSONObject(map);
                    callbackContext.success(jsonObject);
                }



                Log.e("TAG", "onFailed: "+errorMsg );
            }
        });

    }

    public static String getMetaValue(Context context, String metaKey) {
        Bundle metaData = null;
        String metaValue = null;
        if (context == null || metaKey == null) {
            return null;
        }
        try {
            ApplicationInfo ai = context.getPackageManager().getApplicationInfo(
                    context.getPackageName(), PackageManager.GET_META_DATA);
            if (null != ai) {
                metaData = ai.metaData;
            }
            if (null != metaData) {
                metaValue = metaData.getString(metaKey);
            }
        } catch (PackageManager.NameNotFoundException e) {
        }
        return metaValue;// xxx
    }

}
