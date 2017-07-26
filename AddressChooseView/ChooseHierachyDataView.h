//
//  ChooseLocationView.h
//  ChooseLocation
//
//  Created by Sekorm on 16/8/22.
//  Copyright © 2016年 HY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddressItem.h"


/**
 通过调用者赋值第一层参数，后面的参数通过用户点击后，返回给调用者，
 调用者准备好数据后，再通知该控件
 */
@interface ChooseHierachyDataView : UIView

//初次赋值时，至少保证第一层数据
@property (nonatomic, strong) NSArray<AddressItem*> *listItems;


//选择结果返回
@property (nonatomic, copy) void(^chooseFinish)(NSArray<AddressItem*>* arrayAddress);

//用户取消
@property (nonatomic, copy) void(^cancel)();


//加载某个指定id的子级list
@property (nonatomic, copy) void (^nextStepBlock)(AddressItem* item);


//nextStepBlock 下一级数据填充完毕，刷新控件视图
- (void)refreshNextStepWithPreTitle:(NSString*)preTitle;

@end
