//
//  AddressInfoManager.m
//  PicaDo
//
//  Created by lbx on 2017/7/13.
//  Copyright © 2017年 owen. All rights reserved.
//

#import "AddressInfoManager.h"

@interface AddressInfoManager()
@property (nonatomic, strong) NSArray *arrayProvince;
@end

@implementation AddressInfoManager

+ (instancetype)sharedManager
{
    static AddressInfoManager* _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[AddressInfoManager alloc] init];
        
    });
    return _sharedInstance;
}


-(NSDictionary *)readLocalCitys{
    //目前本地文件中只有省市区，乡村信息需要接口拉取
    NSData *citysData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"citys" ofType:@"json"]];
    NSDictionary *citysDic = [NSJSONSerialization JSONObjectWithData:citysData options:NSJSONReadingAllowFragments error:nil];
    return citysDic;
}
- (void)loadAllAddress
{
    if (!_arrayProvince) {
    
        self.arrayProvince = [self readLocalCitys][@"provinceList"];

    }
}

- (NSMutableArray<AddressItem*>*)provinceList
{
    [self loadAllAddress];
    
//    "province_id": 110,
//    "province_name": "北京市",
    
    NSMutableArray<AddressItem*> *arrayItems = [[NSMutableArray alloc]init];

    AddressItem *addrItem = [AddressItem new];
    addrItem.addrID = 100;
    addrItem.name = @"全国";
    addrItem.addrType = AddressItemType_Nation;
    
    
    [arrayItems addObject:addrItem];
    
    for (int i = 0; i < self.arrayProvince.count; i++) {
        
        NSDictionary *dic = self.arrayProvince[i];
        
        AddressItem *addrItem = [AddressItem new];
        addrItem.addrID = [dic[@"province_id"]longLongValue];
        addrItem.name = dic[@"province_name"];
        addrItem.addrType = AddressItemType_Province;
        
        long long provinceID = addrItem.addrID;
        if (provinceID == 110 || provinceID == 120  || provinceID == 500 || provinceID == 310) {
            //北京,天津，深圳，重庆，上海
            
            addrItem.addrType = AddressItemType_DirectlyCity;
            
        }
        
        
        [arrayItems addObject:addrItem];
    }
    
    return arrayItems;
}


- (NSMutableArray<AddressItem*>*)cityListWithProvinceId:(long long)provinceID
{
    [self loadAllAddress];
    
    //全国
    if (provinceID == 100)
    {
//        AddressItem *addrItem = [AddressItem new];
//        addrItem.addrID = 100;
//        addrItem.name = @"";
//        addrItem.addrType = AddressItemType_Nation;
//        return @[addrItem];
        
        return [[NSMutableArray alloc]init];
    }
    
    NSMutableArray<AddressItem*> *arrayItems = [[NSMutableArray alloc]init];
    
    for (NSDictionary *dic in self.arrayProvince)
    {
        if ([dic[@"province_id"] integerValue] == provinceID) {
            
            NSArray *arrayCitys = dic[@"cityList"];
            
            for (NSDictionary *cityDic in arrayCitys) {
                
                AddressItem *addrItem = [AddressItem new];
                addrItem.addrID = [cityDic[@"city_id"]longLongValue];
                addrItem.parentID = [cityDic[@"province_id"]longLongValue];
                addrItem.name = cityDic[@"city_name"];
                addrItem.addrType = AddressItemType_City;
                
                long long provinceID = addrItem.addrID;
                if (provinceID == 110 || provinceID == 120  || provinceID == 500 || provinceID == 310) {
                    //北京,天津，重庆，上海
                    addrItem.addrType = AddressItemType_DirectlyCity;
                }

                [arrayItems addObject:addrItem];
            }
            break;
        }
    }
    
    return arrayItems;
}

- (NSMutableArray<AddressItem*>*)countryListWithCityId:(long long)cityId provinceId:(long long)provinceID
{
    [self loadAllAddress];
    
    if (provinceID == 110 || provinceID == 120 || provinceID == 500 || provinceID == 310) {
        //北京,天津，深圳，重庆，上海
        return [[NSMutableArray alloc]init];
    }
    
    NSMutableArray<AddressItem*> *arrayItems = [[NSMutableArray alloc]init];
    for (NSDictionary *dic in self.arrayProvince)
    {
        if ([dic[@"province_id"] integerValue] == provinceID)
        {
            //读取省下面的城市list
            NSArray *arrayCitys = dic[@"cityList"];
            
            for (NSDictionary *cityDic in arrayCitys)
            {
                if ( [cityDic[@"city_id"]longLongValue] == cityId )
                {
                    //读取城市下面的区list
                    NSArray *coutryList = cityDic[@"countyList"];
                    
                    for (NSDictionary *countryDic in coutryList)
                    {
                        AddressItem *addrItem = [AddressItem new];
                        addrItem.addrID = [countryDic[@"county_id"]longLongValue];
                        addrItem.parentID = [countryDic[@"city_id"]longLongValue];
                        addrItem.name = countryDic[@"county_name"];
                        addrItem.addrType = AddressItemType_Country;
                        
                        [arrayItems addObject:addrItem];
                    }
                    break;
                }
            }
            
            break;
        }
    }
    return arrayItems;
}

- (void)clearMem
{
    if (self.listItems) {
        [self.listItems removeAllObjects];
        self.listItems = nil;
    }
}


- (void)loadAllAddressItems
{
    [self clearMem];
    //所有省
    self.listItems = [[AddressInfoManager sharedManager]provinceList];
    
    [self loadCitys];
    
    [self loadCountrys];
    
}

- (void)loadCitys
{
    for (int i = 0; i < self.listItems.count; i++) {
        //某个省
        AddressItem *item = self.listItems[i];
        NSMutableArray *arr = [[AddressInfoManager sharedManager]cityListWithProvinceId:item.addrID];
        //某个省的城市List
        item.subList = arr;
    }
}

- (void)loadCountrys
{
    for (int j = 0; j < self.listItems.count; j++) {
        //某个省
        AddressItem *provinceItem = self.listItems[j];
        
        for (int i = 0; i < provinceItem.subList.count; i++) {
            //某个市
            AddressItem *cityItem = provinceItem.subList[i];
            
            cityItem.subList = [[AddressInfoManager sharedManager]countryListWithCityId:cityItem.addrID provinceId:cityItem.parentID];
        }
    }
}

- (void)resetAllUnSelected
{
    if (self.listItems) {
        [self resetWithArray:self.listItems];
    }
}

- (void)resetWithArray:(NSArray<AddressItem*>*)arrayItems
{
    if (arrayItems) {
        
        [arrayItems enumerateObjectsUsingBlock:^(AddressItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
           
            obj.isSelected = NO;
            if (obj.subList) {
                
                [self resetWithArray:obj.subList];
            }
        }];
    }
}


@end
