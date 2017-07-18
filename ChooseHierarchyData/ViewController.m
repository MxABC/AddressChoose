//
//  ViewController.m
//  ChooseHierarchyData
//
//  Created by lbx on 2017/7/17.
//  Copyright © 2017年 lbx. All rights reserved.
//

#import "ViewController.h"
#import "ChooseLocationView.h"
#import "AddressInfoManager.h"
#import <Masonry.h>
#import "Position.h"
#import "ChooseAddressManager.h"

@interface ViewController ()
//选择地址popView背景，防止重复点击选择地址
@property (nonatomic, strong) UIView *listBackView;

//分级list
//@property (nonatomic, strong) AddressItem *listItems;
@property (nonatomic, strong) NSArray<AddressItem*> *listItems;

@property (nonatomic, assign) NSInteger selectedProvinceIdx;
@property (nonatomic, assign) NSInteger selectedCityIdx;

@property (nonatomic, strong) Position *defaultPositon;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initData];
}


//加载postion固定的省
- (void)loadPositonProvince
{
    //固定后台传过来的省
    AddressItem *item = [AddressItem new];
    item.name = _defaultPositon.province;
    item.addrID = _defaultPositon.provinceId;
    item.addrType = AddressItemType_Province;
    
    long long provinceID = item.addrID;
    if (provinceID == 110 || provinceID == 120  || provinceID == 500 || provinceID == 310) {
        //北京,天津，重庆，上海
        item.addrType = AddressItemType_DirectlyCity;
    }
    self.listItems = @[item];
}

- (void)loadPositonCity
{
    AddressItem *item = [AddressItem new];
    item.name = _defaultPositon.city;
    item.addrID = _defaultPositon.cityId;
    item.parentID = _defaultPositon.provinceId;
    item.addrType = AddressItemType_City;
    NSMutableArray *arr = [NSMutableArray array];
    [arr addObject:item];
    self.listItems[0].subList = arr;
}

- (void)loadPostionCountry
{
    AddressItem *item = [AddressItem new];
    item.name = _defaultPositon.county;
    item.addrID = _defaultPositon.countyId;
    item.addrType = AddressItemType_Country;
    item.parentID = _defaultPositon.cityId;
    
    NSMutableArray *arr = [NSMutableArray array];
    [arr addObject:item];

    self.listItems[0].subList[0].subList = arr;
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



- (void)initData
{
    _defaultPositon = [[Position alloc]init];
    
    _defaultPositon.type = 3;
    
//    _defaultPositon.province = @"北京";
//    _defaultPositon.provinceId  = 110;

        _defaultPositon.province = @"河北省";
        _defaultPositon.provinceId  = 130;
    
    _defaultPositon.city = @"秦皇岛市";
    _defaultPositon.cityId = 130300000000;
    
//    id:130300000000,name:秦皇岛市
    
    
    //权限类型，1院长 2县级 3市级 4省级 5国家
    switch (_defaultPositon.type) {
        case 5:
        {
            //所有省
            self.listItems = [[AddressInfoManager sharedManager]provinceList];
            
            [self loadCitys];
            [self loadCountrys];
        }
            break;
        case 4:
        {
            //省级别，加载省下面的城市及城市下面的区
            
            //加载固定省
            [self loadPositonProvince];
            
            //加载省下面的所有市
            [self loadCitys];
            
            //加载市下面的所有区
            [self loadCountrys];
            
        }
            break;
        case 3:
        {
            //市级别
            [self loadPositonProvince];
            [self loadPositonCity];
            [self loadCountrys];
            
        }
            break;
        case 2:
        {
            //区/县级别
            [self loadPositonProvince];
            [self loadPositonCity];
            [self loadPostionCountry];
            
        }
            break;
        case 1:
        {
            //单位
            [self loadPositonProvince];
            [self loadPositonCity];
            [self loadPostionCountry];
        }
            break;
            
        default:
            break;
    }
}
- (IBAction)chooseAll:(id)sender {
    
    [[ChooseAddressManager sharedManager]loadAllAddress];
    
    [[ChooseAddressManager sharedManager]showAddressPickerViewWithComplection:^(NSArray<AddressItem *> *arrayAddress) {
        
        //打印地址
        NSMutableString *str = [NSMutableString string];
        for (int i = 0; i < arrayAddress.count; i++) {
            
            if (![str isEqualToString:@""]) {
                [str appendString:@">"];
            }
            NSLog(@"id:%lld,name:%@",arrayAddress[i].addrID,arrayAddress[i].name);
            
            [str appendString:arrayAddress[i].name];
        }
        
        self.labelAddress.text = str;
    }];

}

- (IBAction)choose:(id)sender {
    //清除上次选择记录
//    [[AddressInfoManager sharedManager]resetWithArray:self.listItems];

    [[ChooseAddressManager sharedManager]loadTheItems:self.listItems];
    
    [[ChooseAddressManager sharedManager]showAddressPickerViewWithComplection:^(NSArray<AddressItem *> *arrayAddress) {
        //打印地址
        NSMutableString *str = [NSMutableString string];
        for (int i = 0; i < arrayAddress.count; i++) {
            
            if (![str isEqualToString:@""]) {
                [str appendString:@">"];
            }
            NSLog(@"id:%lld,name:%@",arrayAddress[i].addrID,arrayAddress[i].name);
            
            [str appendString:arrayAddress[i].name];
        }
        
        self.labelAddress.text = str;
    }];

}



@end
