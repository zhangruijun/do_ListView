//
//  TYPEID_View.h
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DoExt_ListView_IView.h"
#import "DoExt_ListView_UIModel.h"
#import "doIUIModuleView.h"

@interface DoExt_ListView_UIView : UITableView<DoExt_ListView_IView,doIUIModuleView,UITableViewDataSource,UITableViewDelegate>
//可根据具体实现替换UIView
{
    @private
    __weak DoExt_ListView_UIModel *_model;
}

@end
