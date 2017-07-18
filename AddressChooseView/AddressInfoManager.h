//
//  AddressInfoManager.h
//  PicaDo
//
//  Created by lbx on 2017/7/13.
//  Copyright © 2017年 owen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddressItem.h"

@interface AddressInfoManager : NSObject

//存储地址信息,当前为省份信息，subList为城市信息，以此类推
@property (nonatomic, strong) NSMutableArray<AddressItem*> *listItems;

+ (instancetype)sharedManager;


//清除之前缓存，可以在退出或更改选择可以地址内容时调用
- (void)clearMem;


/**
 自动加载city.json文件中所有地址
 */
- (void)loadAllAddressItems;




/**
 加载listItems中所有省下面的城市
 ,在手动添加省份时
 */
- (void)loadCitys;

//加载listItems中所有城市的下的区
- (void)loadCountrys;


#pragma mark-  DIY加载,赋值给listItems，或自行存储处理

//加载所有省份
- (NSMutableArray<AddressItem*>*)provinceList;

//读取指定省份下面的城市
- (NSMutableArray<AddressItem*>*)cityListWithProvinceId:(long long)provinceID;

//读取指定省份、城市下面的区、县
- (NSMutableArray<AddressItem*>*)countryListWithCityId:(long long)cityId provinceId:(long long)provinceID;


//将listItems及所有子元素设置 isSelected = NO
- (void)resetAllUnSelected;

//将arrayItems及子元素都设置 isSelected = NO
- (void)resetWithArray:(NSArray<AddressItem*>*)arrayItems;


@end


