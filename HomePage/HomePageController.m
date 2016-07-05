//
//  HomePageController.m
//  HomePage
//
//  Created by Shao Jie on 16/7/2.
//  Copyright © 2016年 yourangroup. All rights reserved.
//

#import "HomePageController.h"
static CGFloat const scrollH = 40;// 标题栏高度
static CGFloat const padding = 10;//标题间隔
static CGFloat const scaleFontSize = 20;
static CGFloat const fontSize = 15;
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
@interface HomePageController ()<UIScrollViewDelegate>
@property (nonatomic,strong) NSMutableArray * titleLabelArray;// 标题label集合
@property (nonatomic,strong) UIScrollView * titleScrollView;// 标题容器
@property (nonatomic,strong) UIScrollView * contentsScrollView;// 内容容器
@property (nonatomic,strong) UILabel * selectedLabel;//记录选中状态的label
@property (nonatomic,strong) UIView * coverView;// 移动的遮盖
@property (nonatomic,strong) UIView * coverLine;// 移动的线条
@end

@implementation HomePageController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray * childArray = @[@"FirstViewController",@"SecondViewController",@"ThirdViewController",@"SecondViewController",@"FirthViewController",@"FifthViewController",@"FirstViewController"];
    NSArray * titleArray = @[@"头条",@"移动互联",@"欧洲杯",@"求知若渴",@"云课堂",@"虚怀若谷",@"态度公开课"];
//
//    self.childControllers = [NSArray arrayWithArray:childArray];
//    self.titleArray = [NSArray arrayWithArray:titleArray];

    [self configChildViewControllers:childArray titleArray:titleArray];
    
    // iOS7会给导航控制器下所有的UIScrollView顶部添加额外滚动区域
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.view addSubview:self.titleScrollView];
    [self.view addSubview:self.contentsScrollView];
//    self.coverType = CoverTypeView;
    [self configTitleLabel:titleArray];
    

}
- (instancetype)initWithChildArray:(NSArray *)childArray titleArray:(NSArray *)titleArray{
    self = [super init];
    if (self) {
        [self configChildViewControllers:childArray titleArray:titleArray];
        [self.view addSubview:self.titleScrollView];
        [self.view addSubview:self.contentsScrollView];
        [self configTitleLabel:titleArray];
    }
    return self;
}
#pragma mark --- 初始化
// 初始化子控制器
- (void)configChildViewControllers:(NSArray *)childArray titleArray:(NSArray *)titleArray{
    for (int i = 0; i < childArray.count; i ++) {
        [self addChildViewController:[[NSClassFromString(childArray[i]) alloc] init]];
        [[self.childViewControllers objectAtIndex:i] setTitle:titleArray[i]];
    }
}
//初始化标题
- (void)configTitleLabel:(NSArray *)titleArray{
    UIFont * font = [UIFont systemFontOfSize:scaleFontSize];//定义字体
    NSMutableArray * titleLabelWidthArray = [NSMutableArray array];
    NSMutableArray * titleLabelArrayX = [NSMutableArray array];
    for (int i = 0 ; i < titleArray.count; i ++) {
        CGFloat width = [self calculateString:titleArray[i] textFont:font labelHeight:scrollH] + padding;
        [titleLabelWidthArray addObject:@(width)];
        if (titleLabelArrayX.count) {
            CGFloat newWidth = [titleLabelWidthArray[i - 1] floatValue] + [titleLabelArrayX.lastObject floatValue];
            [titleLabelArrayX addObject:@(newWidth)];
        }else{
            [titleLabelArrayX addObject:@(0)];
        }
    }
    //更新标题栏ScrollView宽度
    self.titleScrollView.contentSize = CGSizeMake([titleLabelWidthArray.lastObject floatValue] + [titleLabelArrayX.lastObject floatValue], 0);
    
    
    for (int i = 0; i < titleArray.count; i ++) {

        UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake([titleLabelArrayX[i] floatValue], 0, [titleLabelWidthArray[i] floatValue], scrollH)];
        titleLabel.font = [UIFont systemFontOfSize:fontSize];
        titleLabel.text = titleArray[i];
        titleLabel.highlightedTextColor = [UIColor redColor];
        titleLabel.tag = i;
        titleLabel.userInteractionEnabled = YES;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.titleLabelArray addObject:titleLabel];
        
        UITapGestureRecognizer * gestureTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureTapClicked:)];
        [titleLabel addGestureRecognizer:gestureTap];
        
        //默认选中第一个
        if (i == 0) {
            [self gestureTapClicked:gestureTap];
        }
        //添加到标题滚动条上
        [self.titleScrollView addSubview:titleLabel];
    }
}
//选中标题后
- (void)gestureTapClicked:(UIGestureRecognizer *)tap{
    UILabel * label = (UILabel *)tap.view;
    [self selectingViewChange:label];
    self.contentsScrollView.contentOffset = CGPointMake(SCREEN_WIDTH * label.tag, 0);
    [self selectingControllerChange:label.tag];
    [self selectingLabelChange:label];
}
// 当前选中label字体变化
- (void)selectingViewChange:(UILabel *)label{
    _selectedLabel.highlighted = NO;
    //取消变形
    _selectedLabel.transform = CGAffineTransformIdentity;
    label.highlighted = YES;

    label.transform = CGAffineTransformMakeScale(1.3, 1.3);
    label.textAlignment = NSTextAlignmentCenter;
    _selectedLabel.textColor = [UIColor blackColor];
    _selectedLabel = label;
}
// 选中控制器转换
- (void)selectingControllerChange:(NSInteger)index{
    CGFloat offsetX = index * SCREEN_WIDTH;
    UIViewController * selectingController = [self.childViewControllers objectAtIndex:index];
    if (selectingController.isViewLoaded) {
        return;
    }
    selectingController.view.frame = CGRectMake(offsetX, 0, self.contentsScrollView.bounds.size.width, self.contentsScrollView.bounds.size.height);
    [self.contentsScrollView addSubview:selectingController.view];
}
// 选中label放在中心
- (void)selectingLabelChange:(UILabel *)label{
    CGFloat offsetX = label.center.x - SCREEN_WIDTH * 0.5;
    if (offsetX < 0) {
        offsetX = 0;
    }
    CGFloat maxOffsetX = self.titleScrollView.contentSize.width - SCREEN_WIDTH;
    if (offsetX > maxOffsetX) {
        offsetX = maxOffsetX;
    }
    [self.titleScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
}
#pragma mark --- UIScrollView代理
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat currentPage = scrollView.contentOffset.x / scrollView.bounds.size.width;
    NSInteger leftIndex = currentPage;
    NSInteger rightIndex = leftIndex + 1;
    
    UILabel * leftLabel = self.titleLabelArray[leftIndex];
    UILabel * rightLabel;
    if (rightIndex < self.titleLabelArray.count - 1) {
        rightLabel = self.titleLabelArray[rightIndex];
    }
    CGFloat rightScale = currentPage - leftIndex;
    CGFloat leftScale = 1 - rightScale;
    
    leftLabel.transform = CGAffineTransformMakeScale(leftScale * 0.3 + 1, leftScale * 0.3 +1);
    
    rightLabel.transform = CGAffineTransformMakeScale(rightScale * 0.3 + 1, rightScale * 0.3 + 1);
    
    leftLabel.textColor = [UIColor colorWithRed:leftScale green:0 blue:0 alpha:1];
    rightLabel.textColor = [UIColor colorWithRed:rightScale green:0 blue:0 alpha:1];
}
// 拖动减速调用
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger index = scrollView.contentOffset.x / scrollView.bounds.size.width;
    [self selectingControllerChange:index];
    [self selectingViewChange:self.titleLabelArray[index]];
    [self selectingLabelChange:self.titleLabelArray[index]];
}
#pragma mark --- 懒加载
- (NSMutableArray *)titleLabelArray{
    if (_titleLabelArray == nil) {
        _titleLabelArray = [NSMutableArray array];
    }
    return _titleLabelArray;
}
- (UIScrollView *)titleScrollView{
    if (_titleScrollView == nil) {
        _titleScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, scrollH)];
        _titleScrollView.showsHorizontalScrollIndicator = NO;
        _titleScrollView.backgroundColor =[UIColor purpleColor];
    }
    return _titleScrollView;
}
- (UIScrollView *)contentsScrollView{
    if (_contentsScrollView == nil) {
        _contentsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, scrollH + 64, SCREEN_WIDTH, SCREEN_HEIGHT - scrollH - 64 )];
        _contentsScrollView.contentSize = CGSizeMake(self.childViewControllers.count * SCREEN_WIDTH, SCREEN_HEIGHT - scrollH - 64);
        _contentsScrollView.pagingEnabled = YES;
        _contentsScrollView.bounces = NO;
        _contentsScrollView.showsHorizontalScrollIndicator = NO;
        _contentsScrollView.delegate = self;
    }
    return _contentsScrollView;
}
- (UIView *)coverLine{
    NSLog(@"coverLine");
    if (_coverLine == nil) {
        
    }
    return _coverLine;
}
#pragma mark --- 辅助方法
//计算字符串宽度
- (CGFloat)calculateString:(NSString *)string textFont:(UIFont *)font labelHeight:(CGFloat)height{
    NSDictionary * dic = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    CGRect  rect = [string boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
    return rect.size.width;
}
// 随机颜色
- (UIColor *)randomColor{
    CGFloat red = arc4random()%256/256.0;
    CGFloat green = arc4random()%256/256.0;
    CGFloat blue = arc4random()%256/256.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
