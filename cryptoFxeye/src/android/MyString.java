package cryptoFxeye;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;

/**
 * Create by ake on 2019/7/5
 * Describe:
 */
public class MyString {

//    public static String BASE_URL="https://192.168.1.180:434/";//business/
   // public static String BASE_URL="http://192.168.1.128:5100";
    public static final String PATH = "eyeBusiness/"; //根目录

    public static boolean isShowLog=true;

    // 判断手机是否联网
    public static boolean itNet( Context context ) {
        boolean bool = false;
        ConnectivityManager connectivityManager = (ConnectivityManager)
                context.getSystemService(Context.CONNECTIVITY_SERVICE);
        if (connectivityManager!=null) {
            NetworkInfo[] networkInfos=connectivityManager.getAllNetworkInfo();
            for (int i = 0; i < networkInfos.length; i++) {
                NetworkInfo.State state=networkInfos[i].getState();
                if (NetworkInfo.State.CONNECTED == state) {
                    bool = true;
                    break;
                }
            }
        }
        return bool;
    }


}
