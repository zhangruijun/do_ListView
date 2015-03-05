using doCore.Helper;
using doCore.Helper.JsonParse;
using doCore.Interface;
using doCore.Object;
using do_ListView.extdefine;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using Windows.Storage;
using Windows.Storage.Streams;
using Windows.UI;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;
using Windows.UI.Xaml.Media;
using Windows.UI.Xaml.Media.Imaging;
using Windows.UI.Text;
using doCore;

namespace do_ListView.extimplement
{
    /// <summary>
    /// 自定义扩展UIView组件实现类，此类必须继承相应控件类或UserControl类，并实现doIUIModuleView,@TYPEID_IMethod接口；
    /// #如何调用组件自定义事件？可以通过如下方法触发事件：
    /// this.model.EventCenter.fireEvent(_messageName, jsonResult);
    /// 参数解释：@_messageName字符串事件名称，@jsonResult传递事件参数对象；
    /// 获取doInvokeResult对象方式new doInvokeResult(model.UniqueKey);
    /// </summary>
    public class listView_View : ListView, doIUIModuleView, listView_IMethod
    {
        /// <summary>
        /// 每个UIview都会引用一个具体的model实例；
        /// </summary>
        private listView_MAbstract model;
        Dictionary<string, string> DicTemplates = new Dictionary<string, string>();
        Dictionary<int, Dictionary<string, Dictionary<string, string>>> eventsMap = new Dictionary<int, Dictionary<string, Dictionary<string, string>>>();
        Dictionary<string, int> templatesPositionMap = new Dictionary<String, int>();
        public  listView_View()
        {
            
        }
        /// <summary>
        /// 初始化加载view准备,_doUIModule是对应当前UIView的model实例
        /// </summary>
        /// <param name="_doComponentUI"></param>
        public async void LoadView(doUIModule _doUIModule)
        {
            this.model = (listView_MAbstract)_doUIModule;
            this.HorizontalAlignment = Windows.UI.Xaml.HorizontalAlignment.Left;
            this.VerticalAlignment = Windows.UI.Xaml.VerticalAlignment.Top;
        }

        public doUIModule GetModel()
        {
            return this.model;
        }
 
        /// <summary>
        /// 动态修改属性值时会被调用，方法返回值为true表示赋值有效，并执行OnPropertiesChanged，否则不进行赋值；
        /// </summary>
        /// <param name="_changedValues">属性集（key名称、value值）</param>
        /// <returns></returns>
        public bool OnPropertiesChanging(Dictionary<string, string> _changedValues)
        {
            return true;
        }
        /// <summary>
        /// 属性赋值成功后被调用，可以根据组件定义相关属性值修改UIView可视化操作；
        /// </summary>
        /// <param name="_changedValues">属性集（key名称、value值）</param>
        public async void OnPropertiesChanged(Dictionary<string, string> _changedValues)
        {
            doUIModuleHelper.HandleBasicViewProperChanged(this.model, _changedValues);
            if (_changedValues.ContainsKey("cell"))
            {
                GetTemplateGroup(_changedValues["cell"]);
            }
        }
        /// <summary>
        /// 同步方法，JS脚本调用该组件对象方法时会被调用，可以根据_methodName调用相应的接口实现方法；
        /// </summary>
        /// <param name="_methodName">方法名称</param>
        /// <param name="_dictParas">参数（K,V）</param>
        /// <param name="_scriptEngine">当前Page JS上下文环境对象</param>
        /// <param name="_invokeResult">用于返回方法结果对象</param>
        /// <returns></returns>
        public bool InvokeSyncMethod(string _methodName, doJsonNode _dictParas, doIScriptEngine _scriptEngine, doInvokeResult _invokeResult)
        {
            if ("bindData".Equals(_methodName))
            {
                this.bindData(_dictParas, _scriptEngine, _invokeResult);
                return true;
            }
            if ("addData".Equals(_methodName))
            {
                this.addData(_dictParas, _scriptEngine, _invokeResult);
                return true;
            }
            if ("getOffsetX".Equals(_methodName))
            {
                this.getOffsetX(_dictParas, _scriptEngine, _invokeResult);
                return true;
            }
            if ("getOffsetY".Equals(_methodName))
            {
                this.getOffsetY(_dictParas, _scriptEngine, _invokeResult);
                return true;
            }
            return false;
        }
        /// <summary>
        /// 异步方法（通常都处理些耗时操作，避免UI线程阻塞），JS脚本调用该组件对象方法时会被调用，
        /// 可以根据_methodName调用相应的接口实现方法；#如何执行异步方法回调？可以通过如下方法：
        /// _scriptEngine.callback(_callbackFuncName, _invokeResult);
        /// 参数解释：@_callbackFuncName回调函数名，@_invokeResult传递回调函数参数对象；
        /// 获取doInvokeResult对象方式new doInvokeResult(model.UniqueKey);
        /// </summary>
        /// <param name="_methodName">方法名称</param>
        /// <param name="_dictParas">参数（K,V）</param>
        /// <param name="_scriptEngine">当前page JS上下文环境</param>
        /// <param name="_callbackFuncName">回调函数名</param>
        /// <returns></returns>
        public bool InvokeAsyncMethod(string _methodName, doJsonNode _dictParas, doIScriptEngine _scriptEngine, string _callbackFuncName)
        {
            if ("reg".Equals(_methodName))
            {
                this.reg(_dictParas, _scriptEngine, _callbackFuncName);
                return true;
            }
            return false;
        }
        /// <summary>
        /// 重绘组件，构造组件时由系统框架自动调用；
        /// 或者由前端JS脚本调用组件onRedraw方法时被调用（注：通常是需要动态改变组件（X、Y、Width、Height）属性时手动调用）
        /// </summary>
        public void OnRedraw()
        {
            var tp = doUIModuleHelper.GetThickness(this.model);
            this.Margin = tp.Item1;
            this.Width = tp.Item2;
            this.Height = tp.Item3;
        }
        /// <summary>
        /// 释放资源处理，前端JS脚本调用closePage或执行removeui时会被调用；
        /// </summary>
        public void OnDispose()
        {

        }

        //=========================================================================
        private void bindData(doJsonNode _dictParas, doIScriptEngine _scriptEngine, doInvokeResult _invokeResult)
        {
            try
            {
                List<doJsonValue> ja = _dictParas.GetOneArray("data");
                SetListItems(ja);
            }
            catch (Exception _err)
            {
                doServiceContainer.LogEngine.WriteError("doListView bindData \n", _err);
            }
        }
        private void GetTemplateGroup(string templates)
        {
            templatesPositionMap.Clear();
            string[] temps = templates.Split(',');
            int tempindex = 0;
            foreach (var item in temps)
            {
                doSourceFile _sourceFile = model.CurrentPage.CurrentApp.SourceFS.GetSourceByFileName(item);
                string tempcontent = _sourceFile.TxtContent();
                DicTemplates.Add(item, tempcontent);
                templatesPositionMap.Add(item, tempindex);
                tempindex++;
            }
        }
        private string GetTempContent(string template)
        {
            if (DicTemplates.ContainsKey(template))
            {
                return DicTemplates[template];
            }
            else
            {
                doSourceFile _sourceFile = model.CurrentPage.CurrentApp.SourceFS.GetSourceByFileName(template);
                return _sourceFile.TxtContent();
            }
        }
        private void SetListItems(List<doJsonValue> ja)
        {
            foreach (var item in ja)
            {
                doIUIModuleView _doIUIModuleView = null;
                string viewtemplate = item.GetNode().GetOneText("cell", "");
                string tempcontent = GetTempContent(viewtemplate);
                doUIContainer _doUIContainer = new doUIContainer(model.CurrentPage);
                _doUIContainer.loadFromContent(tempcontent, null, null);
                _doIUIModuleView = _doUIContainer.RootView.CurrentComponentUIView;
                doUIContainer doUIContainer = _doIUIModuleView.GetModel().CurrentUIContainer;

                if (templatesPositionMap.ContainsKey(item.GetNode().GetOneText("cell", "")))
                {
                    Dictionary<string, doJsonValue> mapKeyValues = item.GetNode().GetAllKeyValues();
                    IniListItem(mapKeyValues, doUIContainer, templatesPositionMap[item.GetNode().GetOneText("cell", "")]);
                    FrameworkElement fe = _doIUIModuleView as FrameworkElement;
                    ListViewItem lvi = new ListViewItem();
                    lvi.Content = fe;
                    this.Items.Add(lvi);
                }
            }
        }
        private void IniListItem(Dictionary<string, doJsonValue> mapKeyValues, doUIContainer doUIContainer, int index)
        {
            foreach (var key in mapKeyValues.Keys)
            {
                if (key != null && !key.Equals("cell"))
                {
                    doUIModule doUIModule = doUIContainer.GetChildUIComponentByID(key);
                    Dictionary<string, string> _changedValues = new Dictionary<string, string>();

                    doJsonValue _DoJsonValue = mapKeyValues[key];
                    Dictionary<string, doJsonValue> mapPropertyValues = _DoJsonValue.GetNode().GetAllKeyValues();
                    foreach (var propertyName in mapPropertyValues.Keys)
                    {
                        _changedValues.Add(propertyName, mapPropertyValues[propertyName].GetText(""));
                    }
                    if (!doUIModule.OnPropertiesChanging(_changedValues))
                    {
                        continue;
                    }
                    foreach (var _name in _changedValues.Keys)
                    {
                        if (_name == null || _name.Length <= 0)
                            continue;
                        doUIModule.SetPropertyValue(_name, _changedValues[_name]);
                    }
                    doUIModule.OnPropertiesChanged(_changedValues);
                }
            }
            this.RegModuleEvent(doUIContainer, index);
        }
        private void RegModuleEvent(doUIContainer doUIContainer, int index)
        {
            if (eventsMap.Count > 0)
            {
                Dictionary<string, Dictionary<string, string>> eventsIdMap = eventsMap[index];
                if (eventsIdMap.Count > 0)
                {
                    foreach (var id in eventsIdMap.Keys)
                    {
                        doUIModule doUIModule = doUIContainer.GetChildUIComponentByID(id);

                        Dictionary<string, string> eventstringMap = eventsIdMap[id];
                        if (eventstringMap.Count > 0)
                        {
                            foreach (var myevent in eventstringMap.Keys)
                            {
                                doUIModule.EventCenter.Unsubscribe(myevent, doUIModule.CurrentPage.ScriptEngine);
                                doUIModule.EventCenter.Subscribe(myevent, eventstringMap[myevent], doUIModule.CurrentPage.ScriptEngine);
                            }
                        }
                    }
                }
            }
        }
        private void addData(doJsonNode _dictParas, doIScriptEngine _scriptEngine, doInvokeResult _invokeResult)
        {
            try
            {
                List<doJsonValue> ja = _dictParas.GetOneArray("data");
                SetListItems(ja);
            }
            catch (Exception _err)
            {
                doServiceContainer.LogEngine.WriteError("doListView addData \n", _err);
            }
        }
        private void getOffsetX(doJsonNode _dictParas, doIScriptEngine _scriptEngine, doInvokeResult _invokeResult)
        {
            try
            {

            }
            catch (Exception _err)
            {
                doServiceContainer.LogEngine.WriteError("doListView getOffsetX \n", _err);
            }
        }
        private void getOffsetY(doJsonNode _dictParas, doIScriptEngine _scriptEngine, doInvokeResult _invokeResult)
        {
            try
            {

            }
            catch (Exception _err)
            {
                doServiceContainer.LogEngine.WriteError("doListView getOffsetY \n", _err);
            }
        }
        private void reg(doJsonNode _dictParas, doIScriptEngine _scriptEngine, string _callbackFuncName)
        {
            try
            {
                int index = _dictParas.GetOneInteger("index", 0);
                string id = _dictParas.GetOneText("id", null);
                string regevent = _dictParas.GetOneText("event", null);
                if (id != null && regevent != null)
                {
                    this.regEvent(index, id, regevent, _callbackFuncName);
                }
            }
            catch (Exception _err)
            {
                doServiceContainer.LogEngine.WriteError("doListView reg \n", _err);
            }
        }
        public void regEvent(int index, string id, string regevent, string _callbackFuncName)
        {
            if (!eventsMap.ContainsKey(index))
            {
                Dictionary<string, Dictionary<string, string>> eventsIdMap = new Dictionary<string, Dictionary<string, string>>();
                Dictionary<string, string> eventstringMap = new Dictionary<string, string>();
                eventstringMap.Add(regevent, _callbackFuncName);
                eventsIdMap.Add(id, eventstringMap);
                eventsMap.Add(index, eventsIdMap);
            }
        }
    }
}
