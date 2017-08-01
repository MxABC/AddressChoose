//
//  ChooseLocationView.m
//  ChooseLocation
//
//  Created by Sekorm on 16/8/22.
//  Copyright © 2016年 HY. All rights reserved.
//

#import "ChooseHierachyDataView.h"
#import "AddressView.h"
#import "UIView+Frame.h"
#import "AddressTableViewCell.h"
#import "AddressItem.h"




#define HYScreenW [UIScreen mainScreen].bounds.size.width

static  CGFloat  const  kHYTopViewHeight = 60; //顶部视图的高度

static  CGFloat  const  kHYTopTabbarHeight = 30; //地址标签栏的高度

@interface ChooseHierachyDataView ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>



@property (nonatomic,weak) AddressView * topTabbar;
@property (nonatomic,weak) UIScrollView * contentView;
@property (nonatomic,weak) UIView * underLine;

@property (nonatomic,strong) NSMutableArray * tableViews;
@property (nonatomic,strong) NSMutableArray * topTabbarItems;
@property (nonatomic,weak) UIButton * selectedBtn;

//每个级别选中的index
@property (nonatomic, assign) NSInteger firstChoosedItemIdx;
@property (nonatomic, assign) NSInteger secondChoosedItemIdx;
@property (nonatomic, assign) NSInteger thirdChooseItemIdx;
@property (nonatomic, assign) NSInteger fourChooseItemIdx;

@property (nonatomic, strong) NSMutableArray<NSNumber*> *arrayChooseItemIdx;

@end

@implementation ChooseHierachyDataView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setUp];
    }
    return self;
}

- (NSMutableArray<NSNumber*>*)arrayChooseItemIdx
{
    if (!_arrayChooseItemIdx) {
        
        _arrayChooseItemIdx = [NSMutableArray array];
        
        for (int i = 0; i < 10; i++) {
            
            NSNumber *number = [NSNumber numberWithInteger:-1];
            [_arrayChooseItemIdx addObject:number];
        }
    }
    return _arrayChooseItemIdx;
}

- (void)cancelAction
{
    _cancel();
}

- (void)sureAction
{
    NSMutableArray<AddressItem*>* chooseItems = [NSMutableArray array];
    
    //确定按钮
    
    NSArray<AddressItem*> * dataSouce  = self.listItems;
    
    while (dataSouce && dataSouce.count > 0) {
        
        BOOL isSelected = NO;
        for (AddressItem *item in dataSouce) {
            
            if (item.isSelected) {
                
                [chooseItems addObject:item];
                
                dataSouce = item.subList;
                isSelected = YES;
                break;
            }
        }
        
        if (!isSelected) {
            
            break;
        }
    }
    _chooseFinish(chooseItems);
}


#pragma mark - setUp UI

- (void)setUp{
    
    UIView * topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, kHYTopViewHeight)];
    [self addSubview:topView];
    UILabel * titleLabel = [[UILabel alloc]init];
    titleLabel.text = @"请选择";
    [titleLabel sizeToFit];
    [topView addSubview:titleLabel];
    titleLabel.centerY = topView.height * 0.5;
    titleLabel.centerX = topView.width * 0.5;
    UIView * separateLine = [self separateLine];
    [topView addSubview: separateLine];
    separateLine.top = topView.height - separateLine.height;
    topView.backgroundColor = [UIColor whiteColor];
    
    
    //确定，取消按钮
    UIButton *cancelButton = [[UIButton alloc]init];
    [cancelButton setTitle:@"取 消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    cancelButton.frame = CGRectMake(2, 15, 60, 30);
    [topView addSubview:cancelButton];
    [cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *okButton = [[UIButton alloc]init];
    [okButton setTitle:@"确 定" forState:UIControlStateNormal];
    [okButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    okButton.frame = CGRectMake(topView.frame.size.width - 62, 15, 60, 30);
    [topView addSubview:okButton];
    [okButton addTarget:self action:@selector(sureAction) forControlEvents:UIControlEventTouchUpInside];


    
    AddressView * topTabbar = [[AddressView alloc]initWithFrame:CGRectMake(0, topView.height, self.frame.size.width, 40)];
    [self addSubview:topTabbar];
    _topTabbar = topTabbar;
    [self addTopBarItem];
    UIView * separateLine1 = [self separateLine];
    [topTabbar addSubview: separateLine1];
    separateLine1.top = topTabbar.height - separateLine.height;
    [_topTabbar layoutIfNeeded];
    topTabbar.backgroundColor = [UIColor whiteColor];
    
    UIView * underLine = [[UIView alloc] initWithFrame:CGRectZero];
    [topTabbar addSubview:underLine];
    _underLine = underLine;
    underLine.height = 2.0f;
    UIButton * btn = self.topTabbarItems.lastObject;
    [self changeUnderLineFrame:btn];
    underLine.top = separateLine1.top - underLine.height;
    
    _underLine.backgroundColor = [UIColor orangeColor];
    UIScrollView * contentView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(topTabbar.frame), self.frame.size.width, self.height - kHYTopViewHeight - kHYTopTabbarHeight)];
    contentView.contentSize = CGSizeMake(HYScreenW, 0);
    [self addSubview:contentView];
    _contentView = contentView;
    _contentView.pagingEnabled = YES;
    _contentView.backgroundColor = [UIColor whiteColor];
    [self addTableView];
    _contentView.delegate = self;
}


- (void)addTableView{

    UITableView * tabbleView = [[UITableView alloc]initWithFrame:CGRectMake(self.tableViews.count * HYScreenW, 0, HYScreenW, _contentView.height)];
    [_contentView addSubview:tabbleView];
    [self.tableViews addObject:tabbleView];
    tabbleView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tabbleView.delegate = self;
    tabbleView.dataSource = self;
    tabbleView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
    [tabbleView registerNib:[UINib nibWithNibName:@"AddressTableViewCell" bundle:nil] forCellReuseIdentifier:@"AddressTableViewCell"];
}

- (void)addTopBarItem{
    
    UIButton * topBarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    [topBarItem setTitle:@"请选择" forState:UIControlStateNormal];
    [topBarItem setTitleColor:[UIColor colorWithRed:43/255.0 green:43/255.0 blue:43/255.0 alpha:1] forState:UIControlStateNormal];
    [topBarItem setTitleColor:[UIColor orangeColor] forState:UIControlStateSelected];
    [topBarItem sizeToFit];
     topBarItem.centerY = _topTabbar.height * 0.5;
    [self.topTabbarItems addObject:topBarItem];
    [_topTabbar addSubview:topBarItem];
    [topBarItem addTarget:self action:@selector(topBarItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    //怎么显示
    if (_topTabbar.frame.size.width < (_topTabbar.contentwidth+70))
    {
        [_topTabbar setContentOffset:CGPointMake(_topTabbar.contentwidth-_topTabbar.frame.size.width + 70,0) animated:YES];
    }
    else
    {
        [_topTabbar setContentOffset:CGPointMake(0,0) animated:YES];
    }
}

#pragma mark - TableViewDatasouce

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger colTableView = [self.tableViews indexOfObject:tableView];
    
    NSArray<AddressItem*>* subList = [self DataSourceWithTableViewIdx:colTableView];
    
    if (subList) {
        return subList.count;
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    AddressTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"AddressTableViewCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSInteger colTableView = [self.tableViews indexOfObject:tableView];
    
    NSArray<AddressItem*>* subList = [self DataSourceWithTableViewIdx:colTableView];
    
    if (subList && subList.count > indexPath.row) {
        cell.item = subList[indexPath.row];
    }
    
    return cell;
}

- (void)needNextStepWithItem:(AddressItem*)item
{
    if (_nextStepBlock) {
        _nextStepBlock(item);
    }
}


- (void)refreshNextStepWithPreTitle:(NSString*)preTitle
{
    [self addTopBarItem];
    [self addTableView];
    [self scrollToNextItem:preTitle];
}

#pragma mark - TableViewDelegate
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger colTableView = [self.tableViews indexOfObject:tableView];

    NSArray<AddressItem*>* subList = [self DataSourceWithTableViewIdx:colTableView];
    if (  !(subList && subList.count > indexPath.row) ) {
        
        return indexPath;
    }
    
    AddressItem *item = subList[indexPath.row];
    
    //1.1 判断是否是第一次选择,不是,则重新选择省,切换省.
    NSIndexPath * indexPath0 = [tableView indexPathForSelectedRow];
    
    if ([indexPath0 compare:indexPath] != NSOrderedSame && indexPath0) {
        
        NSInteger count = self.tableViews.count;
        for (int i = 0; i < count - 1 - colTableView; i++) {
            [self removeLastItem];
        }
        if (item.subList.count > 0) {
            
            [self addTopBarItem];
            [self addTableView];
            [self scrollToNextItem:item.name];
        }
        else{
            //needmore
            [self needNextStepWithItem:item];
        }
        return indexPath;
        
    }else if ([indexPath0 compare:indexPath] == NSOrderedSame && indexPath0){
        
//        NSInteger count = self.tableViews.count;
//
//        for (int i = 0; i < count-1 - colTableView; i++) {
//            [self removeLastItem];
//        }
//        if (item.subList.count > 0) {
//            [self addTopBarItem];
//            [self addTableView];
//            [self scrollToNextItem:item.name];
//        }
//        else{
//            //needmore
//            [self needNextStepWithItem:item];
//        }
        return indexPath;
    }
    
    if (item.subList.count > 0)
    {
        //之前未选中省，第一次选择省
        [self addTopBarItem];
        [self addTableView];
        
        [self scrollToNextItem:item.name];
    }
    else{
        //needmore
        [self needNextStepWithItem:item];
    }
    
    return indexPath;
}

- (void)setUnSelected:(NSArray*)array
{
    if (!array || array.count == 0 ) {
        return;
    }
    
    [array enumerateObjectsUsingBlock:^(AddressItem * item, NSUInteger idx, BOOL * _Nonnull stop) {
        item.isSelected = NO;
        
        if (item.subList && item.subList.count > 0) {
            [item.subList enumerateObjectsUsingBlock:^(AddressItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.isSelected = NO;
                
                if (obj.subList && obj.subList.count > 0 ) {
                    
                    [self setUnSelected:obj.subList];
                }
            }];
        }
    }];
}

- (void)refreshCell
{
    for (int k = 0; k < self.tableViews.count; k++) {
        
        UITableView *_tableView = self.tableViews[k];
        
        NSInteger sections = _tableView.numberOfSections;
        
        for (int section = 0; section < sections; section++) {
            
            NSInteger rows =  [_tableView numberOfRowsInSection:section];
            for (int row = 0; row < rows; row++) {
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                AddressTableViewCell * cell = [_tableView cellForRowAtIndexPath:indexPath];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                AddressItem * item = nil;
                
                NSInteger colTableView = [self.tableViews indexOfObject:_tableView];
                
                NSArray<AddressItem*>* subList = [self DataSourceWithTableViewIdx:colTableView];
                
                if (subList && subList.count > indexPath.row) {
                    
                    item = subList[indexPath.row];
                    cell.item = item;
                }
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddressItem * item = nil;
    
    NSInteger colTableView = [self.tableViews indexOfObject:tableView];
    
    NSInteger itemIdx = self.arrayChooseItemIdx[colTableView].integerValue;
    
    if (itemIdx != indexPath.row)
    {
        //重置之前选中的item
        [self setUnSelected:[self DataSourceWithTableViewIdx:colTableView]];
        
        for (NSInteger i = colTableView + 1; i < self.arrayChooseItemIdx.count; i++) {
            //之后的置-1
            NSNumber *number = [NSNumber numberWithInteger:-1];
            [self.arrayChooseItemIdx replaceObjectAtIndex:i withObject:number];
        }
        
        NSNumber *currentIdx = [NSNumber numberWithInteger:indexPath.row];
        [self.arrayChooseItemIdx replaceObjectAtIndex:colTableView withObject:currentIdx];
        
        NSArray<AddressItem*>* subList = [self DataSourceWithTableViewIdx:colTableView];
        
        if (subList && subList.count > indexPath.row ) {
            item = subList[indexPath.row];
        }
    }
    
//    if ( item.isSelected) {
//        return;
//    }
    
    item.isSelected = YES;
    
    //不主动设置，偶尔，会有重复的勾选存在
    [self refreshCell];
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}



#pragma mark - private 

//点击按钮,滚动到对应位置
- (void)topBarItemClick:(UIButton *)btn{
    
    NSInteger index = [self.topTabbarItems indexOfObject:btn];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.contentView.contentOffset = CGPointMake(index * HYScreenW, 0);
        [self changeUnderLineFrame:btn];
    }];
}

//调整指示条位置
- (void)changeUnderLineFrame:(UIButton  *)btn{
    
    _selectedBtn.selected = NO;
    btn.selected = YES;
    _selectedBtn = btn;
    _underLine.left = btn.left;
    _underLine.width = btn.width;
}

//完成地址选择,执行chooseFinish代码块
- (void)setUpAddress:(NSString *)address
{

//    return;
    NSInteger index = self.contentView.contentOffset.x / HYScreenW;
    UIButton * btn = self.topTabbarItems[index];
    [btn setTitle:address forState:UIControlStateNormal];
    [btn sizeToFit];
    [_topTabbar layoutIfNeeded];
    [self changeUnderLineFrame:btn];
    NSMutableString * addressStr = [[NSMutableString alloc] init];
    for (UIButton * btn  in self.topTabbarItems) {
        if ([btn.currentTitle isEqualToString:@"县"] || [btn.currentTitle isEqualToString:@"市辖区"] ) {
            continue;
        }
        [addressStr appendString:btn.currentTitle];
        [addressStr appendString:@" "];
    }
//    self.address = addressStr;
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self.hidden = YES;
//        if (self.chooseFinish) {
////            self.chooseFinish();
//        }
//    });
}

//当重新选择省或者市的时候，需要将下级视图移除。
- (void)removeLastItem{

    [self.tableViews.lastObject performSelector:@selector(removeFromSuperview) withObject:nil withObject:nil];
    [self.tableViews removeLastObject];
    
    [self.topTabbarItems.lastObject performSelector:@selector(removeFromSuperview) withObject:nil withObject:nil];
    [self.topTabbarItems removeLastObject];
    
    
    //怎么显示
    if (_topTabbar.frame.size.width < (_topTabbar.contentwidth+70))
    {
        [_topTabbar setContentOffset:CGPointMake(_topTabbar.contentwidth-_topTabbar.frame.size.width + 70,0) animated:YES];
    }
    else
    {
        [_topTabbar setContentOffset:CGPointMake(0,0) animated:YES];
    }
    

}

//滚动到下级界面,并重新设置顶部按钮条上对应按钮的title
- (void)scrollToNextItem:(NSString *)preTitle{
    
    NSInteger index = self.contentView.contentOffset.x / HYScreenW;
    UIButton * btn = self.topTabbarItems[index];
    [btn setTitle:preTitle forState:UIControlStateNormal];
    [btn sizeToFit];
    [_topTabbar layoutIfNeeded];
    [UIView animateWithDuration:0.25 animations:^{
        self.contentView.contentSize = (CGSize){self.tableViews.count * HYScreenW,0};
        CGPoint offset = self.contentView.contentOffset;
        self.contentView.contentOffset = CGPointMake(offset.x + HYScreenW, offset.y);
        [self changeUnderLineFrame: [self.topTabbar.subviews lastObject]];
    }];
}



//初始化选中状态

#pragma mark - getter 方法

//分割线
- (UIView *)separateLine{
    
    UIView * separateLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1 / [UIScreen mainScreen].scale)];
    separateLine.backgroundColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1];
    return separateLine;
}

- (NSMutableArray *)tableViews{
    if (_tableViews == nil) {
        _tableViews = [NSMutableArray array];
    }
    return _tableViews;
}

- (NSMutableArray *)topTabbarItems{
    if (_topTabbarItems == nil) {
        _topTabbarItems = [NSMutableArray array];
    }
    return _topTabbarItems;
}


#pragma mark-  数据源
//第几个tableview，也就是第几列
- (NSArray*)DataSourceWithTableViewIdx:(NSInteger)idx
{
    switch (idx) {
        case 0:
        {
            //第一列
            return self.listItems;
        }
            break;
        default:
        {
            //第二列
            NSInteger firstIdx = self.arrayChooseItemIdx[0].integerValue;
            
            AddressItem *currentItem = self.listItems[firstIdx];
            for (int i = 1; i < idx; i++)
            {
                NSInteger currentIdx  = self.arrayChooseItemIdx[i].integerValue;
                if (currentItem.subList && currentItem.subList.count > currentIdx) {
                    currentItem = currentItem.subList[currentIdx];
                }
                else{
                    currentItem = nil;
                    break;
                }
            }
            if ( currentItem && currentItem.subList ) {
                return currentItem.subList;
            }
        }
            break;
    }
    
    return @[];
}


- (NSArray*)DataSourceWithTableViewIdx1:(NSInteger)idx
{
    switch (idx) {
        case 0:
        {
            //第一列
            return self.listItems;
        }
            break;
        case 1:
        {
            //第二列
            NSInteger firstIdx = self.arrayChooseItemIdx[0].integerValue;
            
            if (self.listItems.count > firstIdx)
            {
                if (self.listItems[firstIdx].subList && self.listItems[firstIdx].subList.count > 0)
                {
                    return self.listItems[firstIdx].subList;
                }
            }
        }
            break;
        case 2:
        {
            //第二列
            NSInteger firstIdx = self.arrayChooseItemIdx[0].integerValue;
            NSInteger secondIdx = self.arrayChooseItemIdx[1].integerValue;
            
            if (self.listItems.count > firstIdx)
            {
                if (self.listItems[firstIdx].subList && self.listItems[firstIdx].subList.count > secondIdx)
                {
                    return self.listItems[firstIdx].subList[secondIdx].subList;
                }
            }
        }
            break;
        case 3:
        {
            //第二列
            NSInteger firstIdx = self.arrayChooseItemIdx[0].integerValue;
            NSInteger secondIdx = self.arrayChooseItemIdx[1].integerValue;
            NSInteger thirdIdx = self.arrayChooseItemIdx[2].integerValue;
            
            if (self.listItems.count > firstIdx)
            {
                if (self.listItems[firstIdx].subList && self.listItems[firstIdx].subList.count > secondIdx)
                {
                    if (self.listItems[firstIdx].subList[secondIdx].subList && self.listItems[firstIdx].subList[secondIdx].subList.count > thirdIdx  ) {
                        
                        return self.listItems[firstIdx].subList[secondIdx].subList[thirdIdx].subList;
                    }
                }
            }
        }
            break;
        case 4:
        {
            //第二列
            NSInteger firstIdx = self.arrayChooseItemIdx[0].integerValue;
            NSInteger secondIdx = self.arrayChooseItemIdx[1].integerValue;
            NSInteger thirdIdx = self.arrayChooseItemIdx[2].integerValue;
            NSInteger fourIdx = self.arrayChooseItemIdx[3].integerValue;

            if (self.listItems.count > firstIdx)
            {
                if (self.listItems[firstIdx].subList && self.listItems[firstIdx].subList.count > secondIdx)
                {
                    if (self.listItems[firstIdx].subList[secondIdx].subList && self.listItems[firstIdx].subList[secondIdx].subList.count > thirdIdx  ) {

                        if (self.listItems[firstIdx].subList[secondIdx].subList[thirdIdx].subList && self.listItems[firstIdx].subList[secondIdx].subList[thirdIdx].subList.count > fourIdx ) {
                            
                            return self.listItems[firstIdx].subList[secondIdx].subList[thirdIdx].subList[fourIdx].subList;
                        }
                    }
                }
            }
            
            AddressItem *currentItem = self.listItems[firstIdx];
            for (int i = 1; i < idx; i++) {
                
                NSInteger currentIdx  = self.arrayChooseItemIdx[i].integerValue;
                if (currentItem.subList && currentItem.subList.count > currentIdx) {
                    
                    currentItem = currentItem.subList[currentIdx];
                }
                else
                {
                    currentItem = nil;
                    break;
                }
            }
            
            if ( currentItem && currentItem.subList ) {
                return currentItem.subList;
            }
            
        }
            break;
        default:
            break;
    }
    
    return @[];
}


////省级别数据源
////- (NSArray *)dataSouce
//- (NSArray *)provinceSource
//{
//    return self.listItems;
//}
//
//- (NSArray*)cityDataSouceWithIdx:(NSInteger)idx
//{
//    if (self.listItems.count > idx) {
//        return self.listItems[idx].subList;
//    }
//    
//    return @[];
//}
//
//- (NSArray*)cityDataSouce
//{
//    if (self.listItems.count > _firstChoosedItemIdx)
//    {
//        if (self.listItems[_firstChoosedItemIdx].subList && self.listItems[_firstChoosedItemIdx].subList.count > 0)
//        {
//            return self.listItems[_firstChoosedItemIdx].subList;
//        }
//    }
//    //回调,
//    
//    return @[];
//}
//
//
//- (NSArray*)districtDataSouce
//{
//    if (self.listItems.count > _firstChoosedItemIdx && self.listItems[_firstChoosedItemIdx].subList.count > _secondChoosedItemIdx) {
//        
//        return self.listItems[_firstChoosedItemIdx].subList[_secondChoosedItemIdx].subList;
//    }
//    return @[];
//}

@end


