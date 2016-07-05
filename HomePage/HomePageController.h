//
//  HomePageController.h
//  HomePage
//
//  Created by Shao Jie on 16/7/2.
//  Copyright © 2016年 yourangroup. All rights reserved.
//

#import <UIKit/UIKit.h>
//typedef NS_ENUM(NSInteger,CoverType){
//    /**移动的线条*/
//    CoverTypeLine,
//    /**移动的View*/
//    CoverTypeView,
//};
@interface HomePageController : UIViewController
@property (nonatomic,strong) NSArray * childControllers;//所有子控制器
@property (nonatomic,strong) NSArray * titleArray;//子控制器对应的标题
//@property (nonatomic,assign) CoverType coverType;// 遮盖类型
- (instancetype)initWithChildArray:(NSArray *)childArray titleArray:(NSArray *)titleArray;
@end
