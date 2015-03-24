package extimplement;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AbsListView;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.ListView;
import core.DoServiceContainer;
import core.helper.DoUIModuleHelper;
import core.helper.jsonparse.DoJsonNode;
import core.helper.jsonparse.DoJsonValue;
import core.interfaces.DoIScriptEngine;
import core.interfaces.DoIUIModuleView;
import core.object.DoInvokeResult;
import core.object.DoSourceFile;
import core.object.DoUIContainer;
import core.object.DoUIModule;
import extdefine.do_ListView_IMethod;
import extdefine.do_ListView_MAbstract;

/**
 * 自定义扩展UIView组件实现类，此类必须继承相应VIEW类，并实现DoIUIModuleView,Do_ListView_IMethod接口；
 * #如何调用组件自定义事件？可以通过如下方法触发事件：
 * this.model.getEventCenter().fireEvent(_messageName, jsonResult);
 * 参数解释：@_messageName字符串事件名称，@jsonResult传递事件参数对象； 获取DoInvokeResult对象方式new
 * DoInvokeResult(this.model.getUniqueKey());
 */
public class do_ListView_View extends ListView implements DoIUIModuleView, do_ListView_IMethod {

	/**
	 * 每个UIview都会引用一个具体的model实例；
	 */
	private do_ListView_MAbstract model;

	protected MyAdapter myAdapter;

	public do_ListView_View(Context context) {
		super(context);
		myAdapter = new MyAdapter();
	}

	/**
	 * 初始化加载view准备,_doUIModule是对应当前UIView的model实例
	 */
	@Override
	public void loadView(DoUIModule _doUIModule) throws Exception {
		this.model = (do_ListView_MAbstract) _doUIModule;
		this.setOnItemClickListener(new OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
				doListView_Touch();
			}
		});

		this.setOnItemLongClickListener(new OnItemLongClickListener() {
			@Override
			public boolean onItemLongClick(AdapterView<?> parent, View view, int position, long id) {
				doListView_LongTouch();
				return true;
			}
		});

		this.setOnScrollListener(new OnScrollListener() {
			@Override
			public void onScrollStateChanged(AbsListView view, int scrollState) {
				doListView_DisScroll();
			}

			@Override
			public void onScroll(AbsListView view, int firstVisibleItem, int visibleItemCount, int totalItemCount) {
				doListView_EndScroll();
			}
		});
	}

	/**
	 * 动态修改属性值时会被调用，方法返回值为true表示赋值有效，并执行onPropertiesChanged，否则不进行赋值；
	 * 
	 * @_changedValues<key,value>属性集（key名称、value值）；
	 */
	@Override
	public boolean onPropertiesChanging(Map<String, String> _changedValues) {
		if (_changedValues.containsKey("cell")) {
			String value = _changedValues.get("cell");
			if ("".equals(value)) {
				return false;
			}
		}
		return true;
	}

	/**
	 * 属性赋值成功后被调用，可以根据组件定义相关属性值修改UIView可视化操作；
	 * 
	 * @_changedValues<key,value>属性集（key名称、value值）；
	 */
	@Override
	public void onPropertiesChanged(Map<String, String> _changedValues) {
		DoUIModuleHelper.handleBasicViewProperChanged(this.model, _changedValues);
		if (_changedValues.containsKey("cell")) {
			initViewTemplate(_changedValues.get("cell"));
			this.setAdapter(myAdapter);
		}
	}

	/**
	 * 同步方法，JS脚本调用该组件对象方法时会被调用，可以根据_methodName调用相应的接口实现方法；
	 * 
	 * @_methodName 方法名称
	 * @_dictParas 参数（K,V）
	 * @_scriptEngine 当前Page JS上下文环境对象
	 * @_invokeResult 用于返回方法结果对象
	 */
	@Override
	public boolean invokeSyncMethod(String _methodName, DoJsonNode _dictParas, DoIScriptEngine _scriptEngine, DoInvokeResult _invokeResult) throws Exception {
		if ("bindData".equals(_methodName)) {
			bindData(_dictParas, _scriptEngine, _invokeResult);
			return true;
		}
		if ("addData".equals(_methodName)) {
			addData(_dictParas, _scriptEngine, _invokeResult);
			return true;
		}
		if ("getOffsetX".equals(_methodName)) {
			return true;
		}
		if ("getOffsetY".equals(_methodName)) {
			return true;
		}
		return false;
	}

	/**
	 * 异步方法（通常都处理些耗时操作，避免UI线程阻塞），JS脚本调用该组件对象方法时会被调用， 可以根据_methodName调用相应的接口实现方法；
	 * 
	 * @_methodName 方法名称
	 * @_dictParas 参数（K,V）
	 * @_scriptEngine 当前page JS上下文环境
	 * @_callbackFuncName 回调函数名 #如何执行异步方法回调？可以通过如下方法：
	 *                    _scriptEngine.callback(_callbackFuncName,
	 *                    _invokeResult);
	 *                    参数解释：@_callbackFuncName回调函数名，@_invokeResult传递回调函数参数对象；
	 *                    获取DoInvokeResult对象方式new DoInvokeResult(this.model.getUniqueKey());
	 */
	@Override
	public boolean invokeAsyncMethod(String _methodName, DoJsonNode _dictParas, DoIScriptEngine _scriptEngine, String _callbackFuncName) {
		// ...do something
		return false;
	}

	/**
	 * 释放资源处理，前端JS脚本调用closePage或执行removeui时会被调用；
	 */
	@Override
	public void onDispose() {
		// ...do something
	}

	// =========================================================================
	/**
	 * 重绘组件，构造组件时由系统框架自动调用；
	 * 或者由前端JS脚本调用组件onRedraw方法时被调用（注：通常是需要动态改变组件（X、Y、Width、Height）属性时手动调用）
	 */
	@Override
	public void onRedraw() {
		this.setLayoutParams(DoUIModuleHelper.getLayoutParams(this.model));
	}

	private void initViewTemplate(String data) {
		try {
			myAdapter.initTemplates(data.split(","));
		} catch (Exception e) {
			DoServiceContainer.getLogEngine().writeError("解析cell属性错误： \t", e);
		}
	}

	private void doListView_Touch() {
		DoInvokeResult _invokeResult = new DoInvokeResult(this.model.getUniqueKey());
		this.model.getEventCenter().fireEvent("touch", _invokeResult);
	}

	private void doListView_LongTouch() {
		DoInvokeResult _invokeResult = new DoInvokeResult(this.model.getUniqueKey());
		this.model.getEventCenter().fireEvent("longTouch", _invokeResult);
	}

	private void doListView_DisScroll() {
		DoInvokeResult _invokeResult = new DoInvokeResult(this.model.getUniqueKey());
		this.model.getEventCenter().fireEvent("disScroll", _invokeResult);
	}

	private void doListView_EndScroll() {
		DoInvokeResult _invokeResult = new DoInvokeResult(this.model.getUniqueKey());
		this.model.getEventCenter().fireEvent("endScroll", _invokeResult);
	}

	@Override
	public void bindData(DoJsonNode _dictParas, DoIScriptEngine _scriptEngine, DoInvokeResult _invokeResult) throws Exception {
		List<DoJsonValue> dataArray = _dictParas.getOneArray("data");
		myAdapter.bindData(dataArray);
	}

	@Override
	public void addData(DoJsonNode _dictParas, DoIScriptEngine _scriptEngine, DoInvokeResult _invokeResult) throws Exception {
		List<DoJsonValue> dataArray = _dictParas.getOneArray("data");
		myAdapter.addData(dataArray);
	}

	private class MyAdapter extends BaseAdapter {
		private Map<String, String> viewTemplates = new HashMap<String, String>();
		private Map<String, Integer> templatesPositionMap = new HashMap<String, Integer>();
		private Map<Integer, Integer> datasPositionMap = new HashMap<Integer, Integer>();
		private List<DoJsonValue> data;

		public MyAdapter() {
			data = new ArrayList<DoJsonValue>();
		}

		public void bindData(List<DoJsonValue> newData) {
			data.clear();
			if (newData == null) {
				newData = new ArrayList<DoJsonValue>();
			}
			data.addAll(newData);
			notifyDataSetChanged();
		}

		public void addData(List<DoJsonValue> newData) {
			data.addAll(newData);
			notifyDataSetChanged();
		}

		public void initTemplates(String[] templates) throws Exception {
			templatesPositionMap.clear();
			int index = 0;
			for (String templateUi : templates) {
				if (templateUi != null && !templateUi.equals("")) {
					DoSourceFile _sourceFile = model.getCurrentPage().getCurrentApp().getSourceFS().getSourceByFileName(templateUi);
					if (_sourceFile != null) {
						viewTemplates.put(templateUi, _sourceFile.getTxtContent());
						templatesPositionMap.put(templateUi, index);
						index++;
					} else {
						throw new Exception("试图使用一个无效的页面文件:" + templateUi);
					}
				}
			}
		}

		@Override
		public void notifyDataSetChanged() {
			int _size = data.size();
			for (int i = 0; i < _size; i++) {
				DoJsonValue childData = data.get(i);
				try {
					Integer index = templatesPositionMap.get(childData.getNode().getOneText("cell", ""));
					if (index == null) {
						index = 0;
					}
					datasPositionMap.put(i, index);
				} catch (Exception e) {
					DoServiceContainer.getLogEngine().writeError("解析data数据错误： \t", e);
				}
			}
			super.notifyDataSetChanged();
		}

		@Override
		public int getCount() {
			return data.size();
		}

		@Override
		public Object getItem(int position) {
			return data.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public int getItemViewType(int position) {
			return datasPositionMap.get(position);
		}

		@Override
		public int getViewTypeCount() {
			return templatesPositionMap.size();
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			DoJsonValue childData = data.get(position);
			try {
				DoIUIModuleView _doIUIModuleView = null;
				String templateUI = childData.getNode().getOneText("cell", "");
				Integer index = 0;
				index = templatesPositionMap.get(childData.getNode().getOneText("cell", ""));
				if (index == null) {
					index = 0;
				}
				if (convertView == null) {
					String content = viewTemplates.get(templateUI);

					DoUIContainer _doUIContainer = new DoUIContainer(model.getCurrentPage());
					_doUIContainer.loadFromContent(content, null, null);

					_doIUIModuleView = _doUIContainer.getRootView().getCurrentUIModuleView();
				} else {
					_doIUIModuleView = (DoIUIModuleView) convertView;
				}
				if (_doIUIModuleView != null) {
					DoUIContainer doUIContainer = _doIUIModuleView.getModel().getCurrentUIContainer();

					Map<String, DoJsonValue> mapKeyValues = childData.getNode().getAllKeyValues();
					for (String key : mapKeyValues.keySet()) {
						if (key != null && !key.equals("cell")) {
							DoUIModule doUIModule = doUIContainer.getChildUIModuleByID(key);
							if (doUIModule != null) {
								Map<String, String> _changedValues = new HashMap<String, String>();

								DoJsonValue _DoJsonValue = mapKeyValues.get(key);
								Map<String, DoJsonValue> mapPropertyValues = _DoJsonValue.getNode().getAllKeyValues();
								for (String propertyName : mapPropertyValues.keySet()) {
									_changedValues.put(propertyName, mapPropertyValues.get(propertyName).getText(""));
								}
								if (!doUIModule.onPropertiesChanging(_changedValues)) {
									continue;
								}
								for (String _name : _changedValues.keySet()) {
									if (_name == null || _name.length() <= 0)
										continue;
									doUIModule.setPropertyValue(_name, _changedValues.get(_name));
								}
								doUIModule.onPropertiesChanged(_changedValues);
							}
						}
					}

					return (View) _doIUIModuleView;
				}
			} catch (Exception e) {
				DoServiceContainer.getLogEngine().writeError("解析data数据错误： \t", e);
			}
			return null;
		}

	}

	/**
	 * 获取当前model实例
	 */
	@Override
	public DoUIModule getModel() {
		return model;
	}
}
