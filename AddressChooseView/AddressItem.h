//
//  AddressItem.h
//  ChooseLocation
//
//  Created by Sekorm on 16/8/26.
//  Copyright © 2016年 HY. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,AddressItemType)
{
    AddressItemType_Nation,//全国
    AddressItemType_Province,//省
    AddressItemType_DirectlyCity,//直辖市
    AddressItemType_City,//城市/区
    AddressItemType_Country,//区、县
    AddressItemType_Town//城镇、街道
};

@interface AddressItem : NSObject
@property (nonatomic, assign) long long parentID;
@property (nonatomic,assign) long long addrID;
@property (nonatomic,copy) NSString * name;

//是否选中，界面参数
@property (nonatomic,assign) BOOL  isSelected;
//当前item类型
@property (nonatomic, assign) AddressItemType addrType;
//子地址list
@property (nonatomic, strong) NSMutableArray<AddressItem*>* subList;

@end



