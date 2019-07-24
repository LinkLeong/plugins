//
//  CETCAlertView.m
//  CETCPartyBuilding
//
//  Created by Aaron Yu on 2017/2/16.
//  Copyright © 2017年 Aaron Yu. All rights reserved.
//

#define kScreeHeight [[UIScreen mainScreen] bounds].size.height
#define kScreeWidth  [[UIScreen mainScreen] bounds].size.width

#import "CETCAlertView.h"

@interface CETCAlertView ()

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *messageLabel;
 
@property (strong, nonatomic) NSMutableArray *buttonArray;
@property (strong, nonatomic) NSMutableArray *buttonTitleArray;

@end


@implementation CETCAlertView

- (instancetype)init
{
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds])
    {
        self.backgroundColor = [UIColor clearColor];
        
        _backgroundView = [[UIView alloc] initWithFrame:self.frame];
        _backgroundView.backgroundColor = [UIColor blackColor];
        [self addSubview:_backgroundView];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id<CETCAlertViewDelegate>)delegate buttonTitles:(NSString *)buttonTitles, ...
{
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds])
    {
        _title = title;
        _message = message;
        _delegate = delegate;
        _buttonArray = [NSMutableArray array];
        _buttonTitleArray = [NSMutableArray array];
        
        va_list args;
        va_start(args, buttonTitles);
        if (buttonTitles)
        {
            [_buttonTitleArray addObject:buttonTitles];
            while (1)
            {
                NSString *  otherButtonTitle = va_arg(args, NSString *);
                if(otherButtonTitle == nil)
                {
                    break;
                }
                else
                {
                    [_buttonTitleArray addObject:otherButtonTitle];
                }
            }
        }
        va_end(args);
        
        self.backgroundColor = [UIColor clearColor];
        
        _backgroundView = [[UIView alloc] initWithFrame:self.frame];
        _backgroundView.backgroundColor = [UIColor blackColor];
        [self addSubview:_backgroundView];

        [self initContentView];
    }
    return self;
}

- (void)setContentView:(UIView *)contentView
{
    if (_contentView && _contentView.superview)
    {
        [_contentView removeFromSuperview];
    }
    _contentView = contentView;
    _contentView.center = self.center;
    [self addSubview:_contentView];
}

- (void)initContentView
{
    _contentView = [[UIView alloc] init];
    _contentView.backgroundColor = [UIColor whiteColor];
    _contentView.layer.cornerRadius = 5.0;
    _contentView.layer.masksToBounds = YES;
    
    CGFloat viewWidth = kScreeWidth * 5.0 / 7.0;
    
    CGFloat sideWidth = 8;
    
    CGFloat verticalSideWidth = 44;
    
    CGFloat originY = 0;
    
    _contentView.frame = CGRectMake(0, 0, viewWidth, 0);

    if (_title)
    {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, originY, viewWidth, 44)];
        
        _titleLabel.font = [UIFont systemFontOfSize: 15.0];
        
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        
        _titleLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.9];
        
        _titleLabel.text = _title;
        
        [_contentView addSubview:_titleLabel];
        
        originY += 44;
    }
    
    if (_message)
    {
        if (_titleLabel)
        {
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(sideWidth, CGRectGetMaxY(_titleLabel.frame), viewWidth - 2 * sideWidth, 1)];
            line.backgroundColor = [UIColor lightGrayColor]; //[UIColor lightGrayColor];
            
            [_contentView addSubview:line];
        }
        
        CGSize stringSize = [_message boundingRectWithSize:CGSizeMake(viewWidth - 2 * sideWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0]} context:nil].size;
        
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(sideWidth, originY, viewWidth - 2 * sideWidth, stringSize.height + 2 * verticalSideWidth)];
        
        _messageLabel.font = [UIFont systemFontOfSize: 14.0];
        
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.numberOfLines = 0;
        _messageLabel.textColor = [UIColor grayColor];
        
        _messageLabel.text = _message;
        
        [_contentView addSubview:_messageLabel];

        
        originY += stringSize.height + 2 * verticalSideWidth;
    }
    
    if (_buttonTitleArray.count > 0)
    {
        
        if (_messageLabel || _titleLabel)
        {
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(sideWidth, CGRectGetMaxY(_messageLabel.frame), viewWidth - 2 * sideWidth, 1)];
            line.backgroundColor = [UIColor lightGrayColor];
            
            [_contentView addSubview:line];
        }
        
        CGFloat buttonWidth = (viewWidth - 2 * sideWidth) / _buttonTitleArray.count;
        for (NSString *buttonTitle in _buttonTitleArray)
        {
            NSInteger index = [_buttonTitleArray indexOfObject:buttonTitle];
            
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(sideWidth + index * buttonWidth,originY, buttonWidth, 44)];
            
            button.titleLabel.font = [UIFont systemFontOfSize:15.5];
            [button setTitle:buttonTitle forState:UIControlStateNormal];
            [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(buttonWithPressed:) forControlEvents:UIControlEventTouchUpInside];
            [_buttonArray addObject:button];
            [_contentView addSubview:button];
            
            if (index < _buttonTitleArray.count - 1)
            {
                UIView *verticalLineView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(button.frame), CGRectGetMinY(button.frame), 1, CGRectGetHeight(button.frame))];
                verticalLineView.backgroundColor = [UIColor lightGrayColor];
                [_contentView addSubview:verticalLineView];
            }
        }
        
        originY += 44;
    }
    
    _contentView.frame = CGRectMake(0, 0, viewWidth, originY);
    
    _contentView.center = self.center;
    [self addSubview:_contentView];
}

- (void)buttonWithPressed:(UIButton *)button
{
    NSInteger index = [_buttonTitleArray indexOfObject:button.titleLabel.text];
    if (_delegate && [_delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)])
    {
        [_delegate alertView:self clickedButtonAtIndex:index];
    }
    
    if (self.clickIndex) {
        self.clickIndex(index);
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(alertView:canDismissAtIndex:)]) {
        BOOL canDismiss = [_delegate alertView:self canDismissAtIndex:index];
        if (canDismiss) {
            [self hide];
        }
    }else{
       [self hide];
    }
    
}

- (void)show
{
    
//    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
//    NSArray *windowViews = [window subviews];
//    if(windowViews && [windowViews count] > 0){
//        UIView *subView = [windowViews objectAtIndex:[windowViews count]-1];
//        for(UIView *aSubView in subView.subviews)
//        {
//            [aSubView.layer removeAllAnimations];
//        }
//        [subView addSubview:self];
//        [self showBackground];
//        [self showAlertAnimation];
//    }
//
    
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [window addSubview:self];
    [self showBackground];
    [self showAlertAnimation];
//    NSArray *windowViews = [window subviews];
//    if(windowViews && [windowViews count] > 0){
//        UIView *subView = [windowViews objectAtIndex:[windowViews count]-1];
//        for(UIView *aSubView in subView.subviews)
//        {
//            [aSubView.layer removeAllAnimations];
//        }
//        [subView addSubview:self];
//        [self showBackground];
//        [self showAlertAnimation];
//    }
}

- (void)hide
{
    _contentView.hidden = YES;
    [self hideAlertAnimation];
}

- (void)showBackground
{
    _backgroundView.alpha = 0;
    [UIView beginAnimations:@"fadeIn" context:nil];
    [UIView setAnimationDuration:0.35];
    _backgroundView.alpha = 0.6;
    [UIView commitAnimations];
}

-(void)showAlertAnimation
{
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.30;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    [_contentView.layer addAnimation:animation forKey:nil];
}

- (void)hideAlertAnimation
{
    [UIView beginAnimations:@"fadeIn" context:nil];
    [UIView setAnimationDuration:0.35];
    _backgroundView.alpha = 0.0;
    [UIView commitAnimations];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self removeFromSuperview];
    });
}

#pragma mark - MBProgressHUD
+ (void)showMessage:(NSString *)text afterDelay:(NSTimeInterval)delay
{
    CETCAlertView *selfClass = [[self alloc] initWithFrame:CGRectMake(0, 0, kScreeWidth, kScreeHeight)];
//    [selfClass.overlayView removeFromSuperview];
//    [selfClass removeFromSuperview];
//    
//    [selfClass addSubview:selfClass.overlayView];
    [[UIApplication sharedApplication].keyWindow addSubview:selfClass];
    
    //MBProgressHUD
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:selfClass animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.bezelView.color = [UIColor blackColor];
//    hud.backgroundView.alpha = .35f;
    hud.bezelView.layer.cornerRadius = 10;
    hud.label.text = text;
    hud.label.textColor =  [UIColor whiteColor];
    hud.label.numberOfLines = 0;
    hud.label.font = [UIFont systemFontOfSize:15];
    // Move to bottm center.
    //    hud.offset = CGPointMake(0.f, -MBProgressMaxOffset);
    
    //    [hud hideAnimated:YES afterDelay:delay];
    
    hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [hud hideAnimated:YES];
        [selfClass removeFromSuperview];
    });
}

+ (void)showMessage:(NSString *)text
{
    [CETCAlertView showMessage:text afterDelay:1];
}

@end
