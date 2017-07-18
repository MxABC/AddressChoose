//
//  ChooseAddressManager.h
//  ChooseHierarchyData
//
//  Created by lbx on 2017/7/18.
//  Copyright © 2017年 lbx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChooseLocationView.h"

@interface ChooseAddressManager : NSObject




+ (instancetype)sharedManager;


/**
 加载city.json文件中所有数据
 */
- (void)loadAllAddress;


/**
 DIY地址

 @param items 地址分级list，第一级为省
 */
- (void)loadTheItems:(NSArray<AddressItem*>*)items;



/**
 显示地址pickerView,在显示pickerView之前，需要加载地址，调用loadAllAddress或loadTheItems:

 @param complection 用户操作完成，取消不返回
 */
- (void)showAddressPickerViewWithComplection:(void(^)(NSArray<AddressItem*>* arrayAddress))complection;

@end
