//
//  TYPEID_UI.h
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol do_ListView_IView <NSObject>

@required
//属性方法
- (void)change_selectedColor:(NSString *)newValue;
- (void)change_cell:(NSString *)newValue;
- (void)change_herderView:(NSString *)newValue;
//同步或异步方法
- (void)addViewtemplates:(NSArray *)parms;
- (void)addData:(NSArray *)parms;
- (void)bindData:(NSArray *)parms;

@end
