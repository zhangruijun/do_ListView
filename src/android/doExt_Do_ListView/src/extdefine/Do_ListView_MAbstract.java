package extdefine;

import core.object.DoUIModule;
import core.object.DoProperty;
import core.object.DoProperty.PropertyDataType;

public abstract class Do_ListView_MAbstract extends DoUIModule {

	protected Do_ListView_MAbstract() throws Exception {
		super();
	}

	/**
	 * 初始化
	 */
	@Override
	public void onInit() throws Exception {
		super.onInit();
		// 注册属性
		this.registProperty(new DoProperty("selectedColor", PropertyDataType.String, "ffffff00", false));
		this.registProperty(new DoProperty("cell", PropertyDataType.String, "", true));
		this.registProperty(new DoProperty("herderView", PropertyDataType.String, "", true));
	}
}