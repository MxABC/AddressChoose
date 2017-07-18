//
//  Position.h
//  ChooseHierarchyData
//
//  Created by lbx on 2017/7/17.
//  Copyright © 2017年 lbx. All rights reserved.
//

#import <Foundation/Foundation.h>



#pragma mark-  认证权限接口返回
@interface Position :NSObject

@property (nonatomic , copy) NSString              * province;
@property (nonatomic , assign) long long              provinceId;

@property (nonatomic , assign) long long              cityId;
@property (nonatomic , copy) NSString              * city;

@property (nonatomic , copy) NSString              * county;
@property (nonatomic , assign) long long              countyId;

@property (nonatomic , copy) NSString              * hospital;
@property (nonatomic , assign) long long              hospitalId;

@property (nonatomic , assign) long long              replaceId;

//权限类型，1具体单位 2区/县级 3市级 4省级 5国家
@property (nonatomic , assign) NSInteger              type;

@end
