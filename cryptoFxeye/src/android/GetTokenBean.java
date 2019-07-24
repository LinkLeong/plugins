package cryptoFxeye;

/**
 * Create by ake on 2019/7/8
 * Describe:
 */
public class GetTokenBean {


    /**
     * status : true
     * access_token : eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiZ3N3IiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiYWRtaW4iLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL2V4cGlyYXRpb24iOiIyMDE5LzcvOCAxNzoxODozMyIsIm5iZiI6MTU2MjU3NzIxMywiZXhwIjoxNTYyNTc3NTEzLCJpc3MiOiJnc3ciLCJhdWQiOiJnc3cifQ.mp1sfItnBEaku96p86hkoHylGb7401D_k13wBMfHDqc
     * expires_in : 300000.0
     * token_type : Bearer
     */

    private boolean status;
    private String access_token;
    private double expires_in;
    private String token_type;

    public boolean isStatus() {
        return status;
    }

    public void setStatus(boolean status) {
        this.status = status;
    }

    public String getAccess_token() {
        return access_token;
    }

    public void setAccess_token(String access_token) {
        this.access_token = access_token;
    }

    public double getExpires_in() {
        return expires_in;
    }

    public void setExpires_in(double expires_in) {
        this.expires_in = expires_in;
    }

    public String getToken_type() {
        return token_type;
    }

    public void setToken_type(String token_type) {
        this.token_type = token_type;
    }
}
