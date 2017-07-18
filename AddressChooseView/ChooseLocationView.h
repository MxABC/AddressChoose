//
//  ChooseLocationView.h
//  ChooseLocation
//
//  Created by Sekorm on 16/8/22.
//  Copyright © 2016年 HY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddressItem.h"

typedef  NSArray<AddressItem*>* (^DataSourceBlock)();

@interface ChooseLocationView : UIView

//选择结果返回å
@property (nonatomic, copy) void(^chooseFinish)(NSArray<AddressItem*>* arrayAddress);

//用户取消
@property (nonatomic, copy) void(^cancel)();


//获取数据源
@property (nonatomic, copy) DataSourceBlock dataSourceBlock;


- (void)setInitArea;


@end
