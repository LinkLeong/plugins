/********* cryptoFxeye.m Cordova Plugin Implementation *******/


#ifdef TEST_SERVER

#define API_BASE_URL     @"http://192.168.1.128:5100"

#endif

#pragma mark -- 开发环境 --
#ifdef DEV_SERVER

#define API_BASE_URL    @"http://192.168.1.128:5100"

#endif

#pragma mark -- 发布环境 --
#ifdef PROD_SERVER
#define API_BASE_URL    @"http://192.168.1.128:5100"

#endif


#import <Cordova/CDV.h>
#import "CETCServer.h"
#import "CETCAlertView.h"

@interface cryptoFxeye : CDVPlugin {
  // Member variables go here.
}
/*判断有无网络 00有网络 01没有网络*/
@property (nonatomic, strong)NSString *network;
- (void)coolMethod:(CDVInvokedUrlCommand*)command;
@end

@implementation cryptoFxeye

- (void)coolMethod:(CDVInvokedUrlCommand*)command
{
    
    [self chekTokenUrl];
   
    __block CDVPluginResult* pluginResult = nil;
    
 
    [self getNetworkType];
    
    if (command.arguments != nil && command.arguments.count > 0) {

        NSString* httpMethod = [command.arguments objectAtIndex:0];
        NSString* httpName = [command.arguments objectAtIndex:1];
        NSString* httpParam = [command.arguments objectAtIndex:2];
        
        NSDictionary *info = [[NSBundle mainBundle]infoDictionary];
        NSArray *urlArray = info[@"CFBundleURLTypes"];
        NSDictionary *key = urlArray[0];
        NSString *api_url = key[@"API_URL"];
        NSLog(@"api_url = %@\n",api_url);

        NSLog(@"httpMethod = %@",httpMethod);
        NSLog(@"httpName = %@",httpName);
        NSLog(@"httpParam = %@",httpParam);

        if ([httpMethod isEqualToString:@"get"]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSString *url = [NSString stringWithFormat:@"%@%@?%@",api_url,httpName,httpParam];
                
                [[CETCServer sharedInstance] taskGetWithUrl:url success:^(id JSON) {
                    
                    if ([self.network isEqualToString:@"00"]) { //有网络
                        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:JSON];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    }else{
                        
                        NSDictionary *item = @{@"success":[NSNumber numberWithBool:NO],@"msg":@"网络断开",@"code":@0};
                        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:item];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    }
                  
                    
                } stateCode:^(NSInteger stateCode) {
                    
                    if (stateCode == 401) {
                        [self coolMethod:command];
                    }
                    
                } error:^(NSError *error) {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
                }];
                
            });

           


        }else{ // post 请求
            
            // 异步请求
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                //NSDictionary *dic = [(NSDictionary *)httpParam copy];
                NSString *url = [NSString stringWithFormat:@"%@%@",api_url,httpName];
                
                NSDictionary *dic = nil;
                if ([httpParam isKindOfClass:[NSDictionary class]]) {
                    dic = [(NSDictionary *)httpParam copy];
                }else{
                    dic = [self dictionaryWithJsonString:httpParam];
                }
                
                //NSLog(@"dic = %@",dic);
                
                [[CETCServer sharedInstance]taskPostWithDictionary:dic url:url success:^(id JSON) {
                    
                    if ([self.network isEqualToString:@"00"]) {
                        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:JSON];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    }else{
                        
                        NSDictionary *item = @{@"success":[NSNumber numberWithBool:NO],@"msg":@"网络断开",@"code":@0};
                        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:item];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    }
                    
                   
                    
                    
                } stateCode:^(NSInteger stateCode) {
                    
                    if (stateCode == 401) {
                        
                        NSLog(@"111111111111111");
                        [self coolMethod:command];
                    }
                    
                } error:^(NSError *error) {
                    
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
                    
                    
                }];
                
            });


        }

    }
}

- (void)chekTokenUrl{
    
    NSString *accessToken = [[NSUserDefaults standardUserDefaults]objectForKey:kAccess_token];
    NSString *TokenType = [[NSUserDefaults standardUserDefaults]objectForKey:kToken_type];
    
    if ((accessToken && TokenType) && [self isTokenExpires] == NO) {
        NSLog(@"token 可以使用");
    }else{
        NSLog(@"token 需要获取token");
        [self accessToken];
    }
}

#pragma mark - 判断token是否过期
- (BOOL)isTokenExpires{
    
    NSString *localTime = [[NSUserDefaults standardUserDefaults]objectForKey:kToken_time];
    long long curentTime = [self getDateTimeTOMilliSeconds:[NSDate date]];
    
    if (curentTime > [localTime longLongValue]) { // 过期
        return YES;
    }
    return NO;
}

#pragma mark - 获取token
- (void)accessToken{

    // http://192.168.1.128:59103/api/Permission/Login?username=gsw&password=1
    //http://192.168.1.128:59103/api/Permission/Login?username=gsw&password=1
    
    NSDictionary *info = [[NSBundle mainBundle]infoDictionary];
    NSArray *urlArray = info[@"CFBundleURLTypes"];
    NSDictionary *key = urlArray[0];
    NSString *tokenUrl = key[@"TOKEN_URL"];
    
    NSLog(@"tokenUrl==%@",tokenUrl);
    
    NSString *url = [NSString stringWithFormat:@"%@/api/Permission/Login?username=gsw&password=1",tokenUrl];
    
    [[CETCServer sharedInstance]getTonkenWithUrl:url success:^(id JSON) {
        
        if ([JSON[@"status"] integerValue] == 1) {
            
            [[NSUserDefaults standardUserDefaults]setObject:JSON[@"access_token"] forKey:kAccess_token];
            [[NSUserDefaults standardUserDefaults]setObject:JSON[@"token_type"] forKey:kToken_type];
           
            long long saveTime = [self getDateTimeTOMilliSeconds:[NSDate date]];
            int netTime = [JSON[@"expires_in"] intValue];
            long long total = saveTime + netTime;
            
           // NSLog(@"%lld===%d===%lld",saveTime,netTime,total);
            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithLongLong:total] forKey:kToken_time];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
        }else{
            
            if (JSON[@"message"]) {
                [CETCAlertView showMessage:JSON[@"message"]];
            }
        }
        
    } error:^(NSError *error) {
        
    }];
 
}
-(long long)getDateTimeTOMilliSeconds:(NSDate *)datetime{
    
    NSTimeInterval interval = [datetime timeIntervalSince1970];
    NSLog(@"转换的时间戳=%f",interval);
    long long totalMilliseconds = interval*1000;
    NSLog(@"totalMilliseconds=%llu",totalMilliseconds);
    return totalMilliseconds;
    
}

- (void)getNetworkType
{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *subviews = [[[app valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    for (id subview in subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
            int networkType = [[subview valueForKeyPath:@"dataNetworkType"] intValue];
            switch (networkType) {
                case 0:
                    NSLog(@"NONE");
                     self.network = @"01";
                    break;
                case 1:
                    NSLog(@"2G");
                     self.network = @"00";
                    break;
                case 2:
                    NSLog(@"3G");
                     self.network = @"00";
                    break;
                case 3:
                    NSLog(@"4G");
                     self.network = @"00";
                    break;
                case 5:
                    NSLog(@"WIFI");
                     self.network = @"00";
                    break;
                default:
                    break;
            }
        }
    }
  
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}


@end
