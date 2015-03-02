using doControlLib;
using doControlLib.Environment;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace doUIViewDesign
{
    class doListView : doComponentUIView
    {
        public override void DrawControl(int _x, int _y, int _width, int _height, Graphics g)
        {
            base.DrawControl(_x, _y, _width, _height, g);
            g.DrawLine(new Pen(Color.Gray, 2), new Point(_x + _width * 2 / 20, _y + _height * 3 / 20), new Point(_x + _width * 17 / 20, _y + _height * 3 / 20));
            g.DrawLine(new Pen(Color.Gray, 2), new Point(_x + _width * 2 / 20, _y + _height * 6 / 20), new Point(_x + _width * 17 / 20, _y + _height * 6 / 20));
            g.DrawLine(new Pen(Color.Gray, 2), new Point(_x + _width * 2 / 20, _y + _height * 9 / 20), new Point(_x + _width * 17 / 20, _y + _height * 9 / 20));
            g.DrawLine(new Pen(Color.Gray, 2), new Point(_x + _width * 2 / 20, _y + _height * 12 / 20), new Point(_x + _width * 17 / 20, _y + _height * 12 / 20));
        }

    }
}
