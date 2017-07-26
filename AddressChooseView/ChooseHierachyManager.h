//
//  ChooseAddressManager.h
//  ChooseHierarchyData
//
//  Created by lbx on 2017/7/18.
//  Copyright © 2017年 lbx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddressItem.h"

@interface ChooseHierachyManager : NSObject

+ (instancetype)sharedManager;

/**
 @param items 加载第一级数据orN级别目录
 */
- (void)loadTheItems:(NSArray<AddressItem*>*)items;


/**
 显示地址pickerView,在显示pickerView之前，需要加载地址，调用loadAllAddress或loadTheItems:

 @param complection 用户操作完成，取消不返回
 */
- (void)showAddressPickerViewWithComplection:(void(^)(NSArray<AddressItem*>* arrayAddress))complection;

@end
