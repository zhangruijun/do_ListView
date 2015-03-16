//
//  TYPEID_View.m
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "DoExt_ListView_UIView.h"

#import "doUIModuleHelper.h"
#import "doScriptEngineHelper.h"
#import "doInvokeResult.h"
#import "doIPage.h"
#import "doISourceFS.h"
#import "doUIContainer.h"

@implementation DoExt_ListView_UIView
{
    BOOL _isEditing;
    NSMutableDictionary *_cellDics;
    UIColor *_selectColor;
    NSString *_Address;
    
    UIView *_headView;
    NSMutableArray *_dataArrays;
    NSMutableArray *_removeArrays;
    
    BOOL _isRefreshing;
}

- (instancetype)init
{
    //基础版本
    if(self = [super initWithFrame:CGRectZero style:UITableViewStylePlain])
    {
        self.delegate = self;
        self.dataSource = self;
        
        _isEditing = NO;
        _cellDics = [[NSMutableDictionary alloc] init];
        _dataArrays = [[NSMutableArray alloc] initWithCapacity:0];
        _removeArrays = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}
#pragma mark - doIUIModuleView协议方法（必须）
//引用Model对象
- (void) LoadView: (doUIModule *) _doUIModule
{
    _model = (typeof(_model)) _doUIModule;
}
//销毁所有的全局对象
- (void) OnDispose
{
    _model = nil;
    //自定义的全局属性
    _Address = nil;
    [_cellDics removeAllObjects];
    _cellDics = nil;
    [_headView removeFromSuperview];
    _headView = nil;
    [_dataArrays removeAllObjects];
    _dataArrays = nil;
    [_removeArrays removeAllObjects];
    _removeArrays = nil;
}
//实现布局
- (void) OnRedraw
{
    //实现布局相关的修改
    
    //重新调整视图的x,y,w,h
    [doUIModuleHelper OnRedraw:_model];
}

#pragma mark - TYPEID_IView协议方法（必须）
#pragma mark - Changed_属性
/*
 如果在Model及父类中注册过 "属性"，可用这种方法获取
 NSString *属性名 = [(doUIModule *)_model GetPropertyValue:@"属性名"];
 
 获取属性最初的默认值
 NSString *属性名 = [(doUIModule *)_model GetProperty:@"属性名"].DefaultValue;
 */
- (void)change_selectedColor:(NSString *)newValue
{
    UIColor *defulatCol = [doUIModuleHelper GetColorFromString:[_model GetProperty:@"selectedColor"].DefaultValue :[UIColor whiteColor]];
    _selectColor = [doUIModuleHelper GetColorFromString:newValue :defulatCol];
}
- (void)change_cell:(NSString *)newValue
{
    NSArray *arrays = [newValue componentsSeparatedByString:@","];
    [_cellDics removeAllObjects];
    [self addTemplates:arrays];
}
- (void)change_herderView:(NSString *)newValue
{
    id<doIPage> pageModel = _model.CurrentPage;
    doSourceFile *fileName = [pageModel.CurrentApp.SourceFS GetSourceByFileName:newValue];
    if(!fileName)
    {
        [NSException raise:@"scrollView" format:@"无效的headView:%@",newValue,nil];
        return;
    }
    doUIContainer *container = [[doUIContainer alloc] init:pageModel];
    [container LoadFromFile:fileName:nil:nil];
    doUIModule *insertViewModel = container.RootView;
    if (insertViewModel == nil)
    {
        [NSException raise:@"doLinearLayoutView" format:@"创建view失败",nil];
        return;
    }
    _Address = [NSString stringWithFormat:@"%@",[insertViewModel UniqueKey]];
    UIView *insertView = (UIView*)insertViewModel.CurrentUIModuleView;
    if (insertView == nil)
    {
        [NSException raise:@"doLinearLayoutView" format:@"创建view失败"];
        return;
    }
    _headView = insertView;
    CGFloat w = insertViewModel.RealWidth;
    CGFloat h = insertViewModel.RealHeight;
    _headView.frame = CGRectMake(0, -h, w, h);
    [self addSubview:_headView];
    const CGFloat *color = CGColorGetComponents([_headView.backgroundColor CGColor]);
    self.backgroundColor = [UIColor colorWithRed:color[0]/255 green:color[1]/255 blue:color[3]/255 alpha:color[4]/255];
}

#pragma mark -
#pragma mark - 同步异步方法的实现
/*
    1.参数节点
        doJsonNode *_dictParas = [parms objectAtIndex:0];
        在节点中，获取对应的参数
        NSString *title = [_dictParas GetOneText:@"title" :@"" ];
        说明：第一个参数为对象名，第二为默认值
 
    2.脚本运行时的引擎
        id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
 
 同步：
    3.同步回调对象(有回调需要添加如下代码)
        doInvokeResult *_invokeResult = [parms objectAtIndex:2];
        回调信息
        如：（回调一个字符串信息）
        [_invokeResult SetResultText:((doUIModule *)_model).UniqueKey];
 异步：
    3.获取回调函数名(异步方法都有回调)
        NSString *_callbackName = [parms objectAtIndex:2];
        在合适的地方进行下面的代码，完成回调
        新建一个回调对象
        doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
        填入对应的信息
        如：（回调一个字符串）
        [_invokeResult SetResultText: @"异步方法完成"];
        [_scritEngine Callback:_callbackName :_invokeResult];
 */
//同步
- (void)bindData:(NSArray *)parms
{
    doJsonNode *_dictParas = [parms objectAtIndex:0];
    //id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    //doInvokeResult *_invokeResult = [parms objectAtIndex:2];
    //构建_invokeResult的内容
    NSArray *dataArrays = [_dictParas GetOneNodeArray:@"data"];
    [_dataArrays removeAllObjects];
    [_dataArrays addObjectsFromArray:dataArrays];
    [_removeArrays removeAllObjects];
    [self reloadData];
}
- (void)addViewtemplates:(NSArray *)parms
{
    doJsonNode *_dictParas = [parms objectAtIndex:0];
    //id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    //doInvokeResult *_invokeResult = [parms objectAtIndex:2];
    //构建_invokeResult的内容
    NSString *filesStr = [_dictParas GetOneText:@"templates" :nil];
    NSArray *arrays = [filesStr componentsSeparatedByString:@","];
    [self addTemplates:arrays];
}
- (void)addData:(NSArray *)parms
{
    doJsonNode *_dictParas = [parms objectAtIndex:0];
    //id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    //doInvokeResult *_invokeResult = [parms objectAtIndex:2];
    //构建_invokeResult的内容
    NSArray *dataArrays = [_dictParas GetOneNodeArray:@"data"];
    [_dataArrays addObjectsFromArray:dataArrays];
    [self reloadData];
}
- (void)getOffsetX:(NSArray *)parms
{
    doInvokeResult *_invokeResult = [parms objectAtIndex:2];
    NSString *offsetX = [NSString stringWithFormat:@"%f",self.contentOffset.x];
    [_invokeResult SetResultText:offsetX];
}
- (void)getOffsetY :(NSArray *)parms
{
    doInvokeResult *_invokeResult = [parms objectAtIndex:2];
    NSString *offsetY = [NSString stringWithFormat:@"%f",self.contentOffset.y];
    [_invokeResult SetResultText:offsetY];
}
#pragma mark - private methed
- (void)addTemplates:(NSArray *)arrays
{
    for(int i=0;i<arrays.count;i++)
    {
        NSString *modelStr = arrays[i];
        if(modelStr != nil && ![modelStr isEqualToString:@""])
        {
            doSourceFile *source = [[[_model.CurrentPage CurrentApp] SourceFS] GetSourceByFileName:modelStr];
            if(source)
                [_cellDics setObject:source  forKey:modelStr];
            else
                [NSException raise:@"cell" format:@"试图使用无效的页面文件",nil];
        }
    }
}

- (void)fireEvent:(int)state :(CGFloat)y
{
    doJsonNode *node = [[doJsonNode alloc] init];
    [node SetOneInteger:@"state" :state];
    [node SetOneText:@"y" :[NSString stringWithFormat:@"%f",y]];
    doInvokeResult* _invokeResult = [[doInvokeResult alloc]init:_model.UniqueKey];
    [_invokeResult SetResultNode:node];
    [_model.EventCenter FireEvent:@"pull":_invokeResult];
}

#pragma mark - tableView sourcedelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArrays.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    doJsonValue *jsonValue = [_dataArrays objectAtIndex:indexPath.row];
    doJsonNode *dataNode = [jsonValue GetNode];
    NSString *indentify = [dataNode GetOneText:@"cell" :@"deviceOne"];
    id<doIUIModuleView> showView;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentify];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentify];
        cell.selectedBackgroundView.backgroundColor = _selectColor;
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [cell addGestureRecognizer:longPress];
        
        doSourceFile *fileName = [_cellDics objectForKey:indentify];
        if(!fileName)
        {
            [NSException raise:@"cell" format:@"无效的cellModel",nil];
            return nil;
        }
        id<doIPage> pageModel = _model.CurrentPage;
        doUIContainer *container = [[doUIContainer alloc] init:pageModel];
        [container LoadFromFile:fileName:nil:nil];
        doUIModule *showCellMode = container.RootView;
        _Address = [NSString stringWithFormat:@"%@",[showCellMode UniqueKey]];
        if (showCellMode == nil)
        {
            [NSException raise:@"doLinearLayoutView" format:@"创建view失败",nil];
            return nil;
        }
        showView = showCellMode.CurrentUIModuleView;
        UIView *insertView = (UIView*)showCellMode.CurrentUIModuleView;
        id<doIUIModuleView> modelView = showCellMode.CurrentUIModuleView;
        [modelView OnRedraw];
        if (insertView == nil)
        {
            [NSException raise:@"doLinearLayoutView" format:@"创建view失败"];
            return nil;
        }
        insertView.frame = CGRectMake(0, 0, insertView.frame.size.width, insertView.frame.size.height);
        [[cell contentView] addSubview:insertView];
    }
    else
    {
        showView = (id<doIUIModuleView>)[cell.contentView.subviews objectAtIndex:0];
    }
    [self setShowView:dataNode andView:showView];
    return cell;
}

- (void)setShowView:(doJsonNode *)dataNode andView:(id<doIUIModuleView>)showView
{
    if(showView)
    {
        doUIContainer *container = [[showView GetModel] CurrentUIContainer];
        NSMutableDictionary *dics = [dataNode GetAllKeyValues];
        for(NSString *key in [dics allKeys])
        {
            if(key && ![key isEqualToString:@""])
            {
                doUIModule *childModel = [container GetChildUIModuleByID:key];
                if(childModel)
                {
                    doJsonValue *chiValues = [dics objectForKey:key];
                    NSMutableDictionary *chiDic = [[NSMutableDictionary alloc] initWithDictionary:[[chiValues GetNode] GetAllKeyValues]];
                    if(![childModel OnPropertiesChanging:chiDic])
                    {
                        continue;
                    }
                    for(NSString *name in [chiDic allKeys])
                    {
                        [childModel SetPropertyValue:name :[chiDic objectForKey:name]];
                    }
                    [childModel OnPropertiesChanged:chiDic];
                }
            }
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        [_removeArrays addObject:[_dataArrays objectAtIndex:indexPath.row]];
        [_dataArrays removeObjectAtIndex:indexPath.row];
        [self deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if(editingStyle == UITableViewCellEditingStyleInsert)
    {
        NSLog(@"当前在插入模式!");
    }
}

//开始移动row时执行
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath
{
    NSLog(@"moveRowAtIndexPath");
    [_dataArrays exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:sourceIndexPath.row];
}

//开发可以编辑时执行
-(void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"willBeginEditingRowAtIndexPath");
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"%s",__func__);
    
    doInvokeResult* _invokeResult = [[doInvokeResult alloc]init:_model.UniqueKey];
    doJsonNode *node = [_dataArrays objectAtIndex:indexPath.row];
    [_invokeResult SetResultNode:node];
    [_model.EventCenter FireEvent:@"touch":_invokeResult];
}

#pragma mark - tableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    doJsonNode *node = [_dataArrays objectAtIndex:indexPath.row];
    NSString *indentify = [node GetOneText:@"cell" :@"deviceOne"];
    doSourceFile *fileName = [_cellDics objectForKey:indentify];
    if(!fileName)
    {
        [NSException raise:@"cell" format:@"无效的cellModel",nil];
        return 40;
    }
    id<doIPage> pageModel = _model.CurrentPage;
    doUIContainer *container = [[doUIContainer alloc] init:pageModel];
    [container LoadFromFile:fileName:nil:nil];
    doUIModule *showCellMode = container.RootView;
    return [showCellMode RealHeight];;
}

#pragma mark - All GestureRecognizer Method
- (void)longPress:(UILongPressGestureRecognizer *)longPress
{
    if(longPress.state == UIGestureRecognizerStateBegan)
    {
        NSLog(@"%s",__func__);
        _isEditing = !_isEditing;
        [self setEditing:_isEditing animated:YES];
        UITableViewCell *cell = (UITableViewCell *)[longPress view];
        NSIndexPath *indexPath = [self indexPathForCell:cell];
        doInvokeResult* _invokeResult = [[doInvokeResult alloc]init:_model.UniqueKey];
        doJsonNode *node = [_dataArrays objectAtIndex:indexPath.row];
        [_invokeResult SetResultNode:node];
        [_model.EventCenter FireEvent:@"longTouch":_invokeResult];
    }
}

#pragma mark - scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(_headView && !_isRefreshing)
    {
        if(scrollView.contentOffset.y >= _headView.frame.size.height*(-1))
            [self fireEvent:0 :scrollView.contentOffset.y];
        else
            [self fireEvent:1 :scrollView.contentOffset.y];
    }
    doInvokeResult* _invokeResult = [[doInvokeResult alloc]init:_model.UniqueKey];
    [_model.EventCenter FireEvent:@"didScroll":_invokeResult];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView.contentOffset.y < _headView.frame.size.height*(-1) && !_isRefreshing && _headView)
    {
        [self fireEvent:2 :scrollView.contentOffset.y];
        self.contentInset = UIEdgeInsetsMake(_headView.frame.size.height, 0, 0, 0);
        _isRefreshing = YES;
    }
    doInvokeResult* _invokeResult = [[doInvokeResult alloc]init:_model.UniqueKey];
    [_model.EventCenter FireEvent:@"endScroll":_invokeResult];
}

#pragma mark - doIUIModuleView协议方法（必须）<大部分情况不需修改>
- (BOOL) OnPropertiesChanging: (NSMutableDictionary *) _changedValues
{
    //属性改变时,返回NO，将不会执行Changed方法
    return YES;
}
- (void) OnPropertiesChanged: (NSMutableDictionary*) _changedValues
{
    //_model的属性进行修改，同时调用self的对应的属性方法，修改视图
    [doUIModuleHelper HandleViewProperChanged: self :_model : _changedValues ];
}
- (BOOL) InvokeSyncMethod: (NSString *) _methodName : (doJsonNode *)_dicParas :(id<doIScriptEngine>)_scriptEngine : (doInvokeResult *) _invokeResult
{
    //同步消息
    return [doScriptEngineHelper InvokeSyncSelector:self : _methodName :_dicParas :_scriptEngine :_invokeResult];
}
- (BOOL) InvokeAsyncMethod: (NSString *) _methodName : (doJsonNode *) _dicParas :(id<doIScriptEngine>) _scriptEngine : (NSString *) _callbackFuncName
{
    //异步消息
    return [doScriptEngineHelper InvokeASyncSelector:self : _methodName :_dicParas :_scriptEngine: _callbackFuncName];
}
- (doUIModule *) GetModel
{
    //获取model对象
    return _model;
}

@end
