//
//  TYPEID_Model.m
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_ListView_UIModel.h"
#import "doProperty.h"

@implementation do_ListView_UIModel

#pragma mark - 注册属性（--属性定义--）
/*
[self RegistProperty:[[doProperty alloc]init:@"属性名" :属性类型 :@"默认值" : BOOL:是否支持代码修改属性]];
 */
-(void)OnInit
{
    [super OnInit];
    
    //注册属性
    //selectedColor -- 选中颜色
    //cell -- cell单元
    //herderView -- 下拉刷新view
    
    [self RegistProperty:[[doProperty alloc]init:@"selectedColor" :String :@"ffffff00" :NO]];
    [self RegistProperty:[[doProperty alloc]init:@"cell" :String :@"" :YES]];
    [self RegistProperty:[[doProperty alloc]init:@"headerView" :String :@"" :YES]];
}

@end
