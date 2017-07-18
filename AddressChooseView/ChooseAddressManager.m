//
//  ChooseAddressManager.m
//  ChooseHierarchyData
//
//  Created by lbx on 2017/7/18.
//  Copyright © 2017年 lbx. All rights reserved.
//

#import "ChooseAddressManager.h"
#import "AddressInfoManager.h"
#import <Masonry.h>

@interface ChooseAddressManager()

//picker view
@property (nonatomic, strong) ChooseLocationView *chooseLocationView;

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UITapGestureRecognizer * tap;

@end

@implementation ChooseAddressManager

+ (instancetype)sharedManager
{
    static ChooseAddressManager* _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[ChooseAddressManager alloc] init];
    });
    
    return _sharedInstance;
}

- (void)loadAllAddress
{
    [[AddressInfoManager sharedManager]loadAllAddressItems];
}

- (void)loadTheItems:(NSArray<AddressItem*>*)items
{
    [[AddressInfoManager sharedManager]clearMem];
    [AddressInfoManager sharedManager].listItems = [NSMutableArray arrayWithArray:items];
}

- (void)showAddressPickerViewWithComplection:(void(^)(NSArray<AddressItem*>* arrayAddress))complection;
{
    [self bgView];
    
    
    CGRect rect = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 350, [UIScreen mainScreen].bounds.size.width, 350);
    rect.origin.y = [UIScreen mainScreen].bounds.size.height;
    _chooseLocationView = [[ChooseLocationView alloc]initWithFrame:rect];
    
    __weak typeof (self) weakSelf = self;
    
    _chooseLocationView.dataSourceBlock = ^NSArray<AddressItem *> *{
        
        return [AddressInfoManager sharedManager].listItems;
    };
    
    _chooseLocationView.chooseFinish = ^(NSArray<AddressItem *> *arrayAddress)
    {
        [weakSelf dismiss];
        complection(arrayAddress);
    };
    
    _chooseLocationView.cancel = ^()
    {
        [weakSelf dismiss];
    };

    [[UIApplication sharedApplication].delegate.window addSubview:self.chooseLocationView];
    
    [UIView animateWithDuration:0.25 animations:^{
       
         CGRect rect = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 350, [UIScreen mainScreen].bounds.size.width, 350);
        self.chooseLocationView.frame = rect;
        
    } completion:^(BOOL finished) {
        
    }];

}

- (void)dismiss
{
    [UIView animateWithDuration:0.25 animations:^{
        
        CGRect rect = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 350);
        self.chooseLocationView.frame = rect;
        
        self.bgView.alpha = 0.0;
        
    } completion:^(BOOL finished) {
                
        if (self.bgView) {
            
            if (self.tap) {
             
                [self.bgView removeGestureRecognizer:self.tap];
                self.tap = nil;
            }
            
            [self.bgView removeFromSuperview];
            self.bgView = nil;
        }
    
        if (self.chooseLocationView) {
            [self.chooseLocationView removeFromSuperview];
            self.chooseLocationView = nil;
        }
    }];
}


- (UIView*)bgView
{
    if (!_bgView) {
        
        _bgView = [UIView new];
        _bgView.backgroundColor = [UIColor blackColor];
        _bgView.alpha = 0.5;
        
        UIWindow *window = [UIApplication sharedApplication].delegate.window;
        [window addSubview:_bgView];
        
        [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(window).insets(UIEdgeInsetsZero);
        }];
        
        self.tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
        [_bgView addGestureRecognizer:self.tap];
    }
    return _bgView;
}



@end
