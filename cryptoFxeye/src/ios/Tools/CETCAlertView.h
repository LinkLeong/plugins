//
//  CETCAlertView.h
//  CETCPartyBuilding
//
//  Created by Aaron Yu on 2017/2/16.
//  Copyright © 2017年 Aaron Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@class CETCAlertView;

@protocol CETCAlertViewDelegate <NSObject>

- (void)alertView:(CETCAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
@optional
- (BOOL)alertView:(CETCAlertView *)alertView canDismissAtIndex:(NSInteger)buttonIndex;

@end

@interface CETCAlertView : UIView

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *message;
@property (weak, nonatomic) id<CETCAlertViewDelegate> delegate;
@property (copy) void (^clickIndex) (NSInteger index);

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id<CETCAlertViewDelegate>)delegate buttonTitles:(NSString *)buttonTitles, ... NS_REQUIRES_NIL_TERMINATION;

- (void)show;

- (void)hide;

#pragma mark - MBProgressHUD
+ (void)showMessage:(NSString *)text;
+ (void)showMessage:(NSString *)text afterDelay:(NSTimeInterval)delay;

@end

