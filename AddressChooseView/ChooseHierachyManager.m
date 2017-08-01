//
//  ChooseAddressManager.m
//  ChooseHierarchyData
//
//  Created by lbx on 2017/7/18.
//  Copyright © 2017年 lbx. All rights reserved.
//

#import "ChooseHierachyManager.h"
#import "ChooseHierachyDataView.h"
#import "AddressInfoManager.h"
#import <Masonry.h>

@interface ChooseHierachyManager()

//picker view
@property (nonatomic, strong) ChooseHierachyDataView *chooseLocationView;

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UITapGestureRecognizer * tap;

@end

@implementation ChooseHierachyManager

+ (instancetype)sharedManager
{
    static ChooseHierachyManager* _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[ChooseHierachyManager alloc] init];
    });
    return _sharedInstance;
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
    _chooseLocationView = [[ChooseHierachyDataView alloc]initWithFrame:rect];
    
    __weak typeof (self) weakSelf = self;
    _chooseLocationView.listItems = [AddressInfoManager sharedManager].listItems;
    
    _chooseLocationView.chooseFinish = ^(NSArray<AddressItem *> *arrayAddress)
    {
        [weakSelf dismiss];
        complection(arrayAddress);
    };
    
    _chooseLocationView.cancel = ^()
    {
        [weakSelf dismiss];
    };
    
    _chooseLocationView.nextStepBlock = ^(AddressItem *item) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [weakSelf loadNextStepWithItem:item];
        });
    };

    [[UIApplication sharedApplication].delegate.window addSubview:self.chooseLocationView];
    
    [UIView animateWithDuration:0.25 animations:^{
       
         CGRect rect = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 350, [UIScreen mainScreen].bounds.size.width, 350);
        self.chooseLocationView.frame = rect;
        
    } completion:^(BOOL finished) {
    }];
}


/**
 加载下一级List,有可能是调用接口来完成

 @param item 需要加载子级List的item
 */
- (void)loadNextStepWithItem:(AddressItem*)item
{
    NSMutableArray<AddressItem*>* subList = nil;
    if (  item.addrType == AddressItemType_Province || item.addrType == AddressItemType_DirectlyCity) {
        subList = [[AddressInfoManager sharedManager]cityListWithProvinceId:item.addrID];
    }
    else if(item.addrType == AddressItemType_City )
    {
        subList = [[AddressInfoManager sharedManager]countryListWithCityId:item.addrID provinceId:item.parentID];
    }
    else if (item.addrType == AddressItemType_Country)
    {
        //test 假数据
        subList = [[AddressInfoManager sharedManager]cityListWithProvinceId:130];
    }
    else
    {
        //test 假数据
        subList = [[AddressInfoManager sharedManager]cityListWithProvinceId:130];
    }
    
    if (subList && subList.count > 0)
    {
        item.subList = subList;
        [_chooseLocationView performSelectorOnMainThread:@selector(refreshNextStepWithPreTitle:) withObject:item.name waitUntilDone:NO];
    }
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


