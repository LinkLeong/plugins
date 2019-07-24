//
//  CETCServer.m
//  CETCYunHis
//
//  Created by imac on 2018/4/10.
//  Copyright © 2018年 洪晓杰. All rights reserved.
//

#import "CETCServer.h"
#import "CETCAlertView.h"

#import "sys/utsname.h"
#import <AdSupport/AdSupport.h>

#import <ifaddrs.h>
#import <arpa/inet.h>
#import <sys/sockio.h>
#import <sys/ioctl.h>

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>




@interface CETCServer ()

/*系统网络*/
@property (strong, nonatomic)NSURLSessionDataTask *dataTast;


@end

@implementation CETCServer


static CETCServer *sharedServer;

+ (CETCServer *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedServer=[[CETCServer alloc]init];
    });
    
    return sharedServer;
}
+ (NSString *)imageUrlWithPath:(NSString *)path
{
    return path;
}
/****************************处理401的get和post请求********************************/
- (void)taskGetWithUrl:(NSString *)url success:(void (^)(id JSON))success stateCode:(void (^)(NSInteger stateCode))stateCode error:(void (^)(NSError *error))errorBlock{
    
    NSLog(@"\n⭐⭐⭐⭐⭐\n⭐请求URL:%@\n⭐⭐⭐⭐⭐",url);
    
    NSString *tonken = [[NSUserDefaults standardUserDefaults] objectForKey:kAccess_token];
    NSString *tokenType = [[NSUserDefaults standardUserDefaults] objectForKey:kToken_type];
    NSString *authorization = [NSString stringWithFormat:@"%@ %@",tokenType,tonken];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
    request.HTTPMethod = @"GET";
    
    [request addValue:authorization forHTTPHeaderField:kAuthorization];
    //content-type类型
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    
    //    [request addValue:@"1" forHTTPHeaderField:@"dt"];
    //    [request addValue:@"10" forHTTPHeaderField:@"top"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    _dataTast = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data == nil) {
            return;
        }
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSLog(@"dict = %@",dict);
        
        if (!error) {
            
            if ([[dict allKeys] containsObject:@"code"] && [[dict allKeys] containsObject:@"Success"]) {
                
                if ([dict[@"code"] integerValue] == 200 && [dict[@"Success"] intValue] == 1) { // 请求成功
                    
                    if (success) {
                        success(dict[@"Data"]);
                    }
                    
                }else if ([dict[@"code"] integerValue] == 401 && [dict[@"Success"] intValue] == 0){ // 处理401 token失效的问题
                    if (stateCode) {
                        stateCode([dict[@"code"] integerValue]);
                    }
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [CETCAlertView showMessage:dict[@"msg"]];
                    });
                    
                }
                
            }
            
        }
        
    }];
    [_dataTast resume];
    
}
- (void)taskPostWithDictionary:(NSDictionary *)dic url:(NSString *)url success:(void (^)(id JSON))success stateCode:(void (^)(NSInteger stateCode))stateCode error:(void (^)(NSError *error))errorBlock{
    
    NSLog(@"\n⭐⭐⭐⭐⭐\n⭐请求URL:%@\n⭐⭐⭐⭐⭐",url);
    
    NSString *tonken = [[NSUserDefaults standardUserDefaults] objectForKey:kAccess_token];
    NSString *tokenType = [[NSUserDefaults standardUserDefaults] objectForKey:kToken_type];
    NSString *authorization = [NSString stringWithFormat:@"%@ %@",tokenType,tonken];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
    request.HTTPMethod = @"POST";
    
    [request addValue:authorization forHTTPHeaderField:kAuthorization];
    // 不设置content-type 请求失败
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];  // content-type类型
    
    // 第一种方法
    //    NSData * bodyData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    //    [request setHTTPBody:bodyData];
    
    // 第二种方法
    NSData * bodyData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString * jsonBody = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
    [request setHTTPBody:[jsonBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    // 第三种 字符串作为请求体参数
    
//    NSString *bodyStr = @"username=123&pwd=123";
//    request.HTTPBody = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"jsonBody = %@",jsonBody);
    
    // 401
    NSURLSession *session = [NSURLSession sharedSession];
    _dataTast = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data == nil) {
            return ;
        }
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSLog(@"dict = %@",dict);
   
        if (!error) {
            
            if ([[dict allKeys] containsObject:@"code"] && [[dict allKeys] containsObject:@"Success"]) {
                
                if ([dict[@"code"] integerValue] == 200 && [dict[@"Success"] intValue] == 1) {
                    
                    if (success) {
                        success(dict[@"Data"]);
                    }
                    
                }else if ([dict[@"code"] integerValue] == 401 && [dict[@"Success"] intValue] == 0){
                    if (stateCode) {
                        stateCode([dict[@"code"] integerValue]);
                    }
                }else{
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [CETCAlertView showMessage:dict[@"msg"]];
                    });
                    
                }
                
            }
           
        }
        
    }];
    [_dataTast resume];
    
}
/***************************获取token******************************/
- (void)getTonkenWithUrl:(NSString *)url success:(void (^)(id JSON))success error:(void (^)(NSError *error))errorBlock{
    
    NSLog(@"\n⭐⭐⭐⭐⭐\n⭐请求URL:%@\n⭐⭐⭐⭐⭐",url);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
    request.HTTPMethod = @"GET";
    
    //content-type类型
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    
    //    [request addValue:@"1" forHTTPHeaderField:@"dt"];
    //    [request addValue:@"10" forHTTPHeaderField:@"top"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    _dataTast = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data == nil) {
            return;
        }
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSLog(@"gettoken = %@",dict);
        if (!error) {
            if (success) {
                success(dict);
            }
        }
        
    }];
    [_dataTast resume];
    
    
}
/*********************NSURLSessionDataTask 封装的get和post请求**********************/
- (void)taskGetWithUrl:(NSString *)url success:(void (^)(id JSON))success error:(void (^)(NSError *error))errorBlock{
    
    
    NSString *tonken = [[NSUserDefaults standardUserDefaults] objectForKey:kAccess_token];
    NSString *tokenType = [[NSUserDefaults standardUserDefaults] objectForKey:kToken_type];
    NSString *authorization = [NSString stringWithFormat:@"%@ %@",tokenType,tonken];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
    request.HTTPMethod = @"GET";
    
    [request addValue:authorization forHTTPHeaderField:kAuthorization];
    //content-type类型
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    
    //    [request addValue:@"1" forHTTPHeaderField:@"dt"];
    //    [request addValue:@"10" forHTTPHeaderField:@"top"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    _dataTast = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data == nil) {
            return ;
        }
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        NSInteger responseStatusCode = [httpResponse statusCode];
        NSLog(@"responseStatusCode = %ld", (long)responseStatusCode);
     
        NSLog(@"dict1 = %@",dict);
        
        if (!error) {
            if (success) {
                success(dict);
            }
        }else{
            //子线程与主线程通信
            dispatch_async(dispatch_get_main_queue(), ^{
                //主线程界面刷新
                [CETCAlertView showMessage:dict[@"Message"] afterDelay:1];
            });
            
            if (errorBlock) {
                errorBlock(error);
            }
            
        }
        
    }];
    
    [_dataTast resume];
    
}
- (void)taskPostWithDictionary:(NSDictionary *)dic url:(NSString *)url success:(void (^)(id JSON))success error:(void (^)(NSError *error))errorBlock{
    
    NSString *tonken = [[NSUserDefaults standardUserDefaults] objectForKey:kAccess_token];
    NSString *tokenType = [[NSUserDefaults standardUserDefaults] objectForKey:kToken_type];
    NSString *authorization = [NSString stringWithFormat:@"%@ %@",tokenType,tonken];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
    request.HTTPMethod = @"POST";
    
    [request addValue:authorization forHTTPHeaderField:kAuthorization];
    // 不设置content-type 请求失败
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];  // content-type类型
    
    // 第一种方法
    //    NSData * bodyData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    //    [request setHTTPBody:bodyData];
    
    NSData * bodyData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString * jsonBody = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
    [request setHTTPBody:[jsonBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"jsonBody = %@",jsonBody);
    
    // 401
    NSURLSession *session = [NSURLSession sharedSession];
    _dataTast = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data == nil) {
            return ;
        }
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];

        NSLog(@"dict1 = %@",dict);
        
        if (!error) {
            if (success) {
                success(dict);
            }
        }else{
            
            //子线程与主线程通信
            dispatch_async(dispatch_get_main_queue(), ^{
                //主线程界面刷新
                [CETCAlertView showMessage:dict[@"Message"] afterDelay:1];
            });
            
            if (errorBlock) {
                errorBlock(error);
            }
            
        }
        
    }];
    
    [_dataTast resume];
    
    
}
- (void)taskCancelSingle{
    [self.dataTast cancel];
}





#pragma mark - mac地址
- (NSString *) macaddress
{
    
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1/n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    
    //    NSString *outstring = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    
    // NSLog(@"outString:%@", outstring);
    
    free(buf);
    
    return [outstring uppercaseString];
}


@end
