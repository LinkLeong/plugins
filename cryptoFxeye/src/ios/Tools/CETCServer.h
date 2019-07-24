//
//  CETCServer.h
//  CETCYunHis
//
//  Created by imac on 2018/4/10.
//  Copyright © 2018年 洪晓杰. All rights reserved.
//


#define kToken @"http://192.168.1.128:59103/api/Permission/Login?username=gsw&password=1"
#define API_BASE_URL     @"http://192.168.1.128:5100"

#define kAccess_token  @"access_token"
#define kToken_type    @"token_type"
#define kMessage       @"message"
#define kToken_time    @"kToken_time"
#define kAuthorization @"Authorization"


#define APP_SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define APP_SCREEN_WIDTH  [[UIScreen mainScreen] bounds].size.width

#define APP_SCREEN_HEIGHT_ExNav (APP_SCREEN_HEIGHT - APP_NavBarH)


//状态栏高度
#define     APP_StatusBarH     [[UIApplication sharedApplication] statusBarFrame].size.height
//标题的高度
#define     APP_NavTitleH         self.navigationController.navigationBar.frame.size.height
//导航栏高度
#define     APP_NavBarH     (APP_StatusBarH > 20 ? 88 : 64)
// (APP_StatusBarH + APP_NavTitleH)

//底栏高度
#define APP_TabbarHeight    (APP_StatusBarH > 20 ? 83 : 49)

//适配iPhone X 底部空隙
#define APP_TabBottomGap     (APP_TabbarHeight - 49)



#import <Foundation/Foundation.h>


@interface CETCServer : NSObject


+ (CETCServer *)sharedInstance;
+ (NSString *)imageUrlWithPath:(NSString *)path;

/*NSURLSessionDataTask 封装的get和post请求*/
- (void)taskGetWithUrl:(NSString *)url success:(void (^)(id JSON))success error:(void (^)(NSError *error))errorBlock;
- (void)taskPostWithDictionary:(NSDictionary *)dic url:(NSString *)url success:(void (^)(id JSON))success error:(void (^)(NSError *error))errorBlock;

// 获取token
- (void)getTonkenWithUrl:(NSString *)url success:(void (^)(id JSON))success error:(void (^)(NSError *error))errorBlock;

/*NSURLSessionDataTask 处理401的get和post请求*/
- (void)taskGetWithUrl:(NSString *)url success:(void (^)(id JSON))success stateCode:(void (^)(NSInteger stateCode))stateCode error:(void (^)(NSError *error))errorBlock;
- (void)taskPostWithDictionary:(NSDictionary *)dic url:(NSString *)url success:(void (^)(id JSON))success stateCode:(void (^)(NSInteger stateCode))stateCode error:(void (^)(NSError *error))errorBlock;

/*取消网络请求*/
- (void)taskCancelSingle;


@end
