using System.ComponentModel;
using System.Drawing.Drawing2D;

namespace Aemulus_XR_Reporting_App.VisualElements
{
	internal class RoundedButton : Button
	{
		private int borderRadius = 1;
		private float borderWidth = 0f;
		private Color borderColor = Color.FromArgb(1, 105, 224);

		[Category("Border")]
		[Description("Set the roundness of the button's corners")]
		public int RoundedBorderRadius
		{
			get { return borderRadius; }
			set
			{
				//Prevent GraphPath from breaking when the border radius is less than 1
				if (borderRadius < 1)
					borderRadius = 1;

				borderRadius = value;
				Invalidate();
			}
		}

		[Category("Border")]
		[Description("Set the thickness of the border")]
		public float RoundedBorderWidth
		{
			get { return borderWidth; }
			set
			{
				borderWidth = value;
				Invalidate();
			}
		}

		[Category("Border")]
		[Description("A custom string property for the control.")]
		public Color RoundedBorderColor
		{
			get { return borderColor; }
			set
			{
				borderColor = value;
				Invalidate();
			}
		}

		GraphicsPath GetRoundPath(RectangleF Rect, int radius)
		{
			float r2 = radius / 2f;
			GraphicsPath GraphPath = new GraphicsPath();
			GraphPath.AddArc(Rect.X, Rect.Y, radius, radius, 180, 90);
			GraphPath.AddLine(Rect.X + r2, Rect.Y, Rect.Width - r2, Rect.Y);
			GraphPath.AddArc(Rect.X + Rect.Width - radius, Rect.Y, radius, radius, 270, 90);
			GraphPath.AddLine(Rect.Width, Rect.Y + r2, Rect.Width, Rect.Height - r2);
			GraphPath.AddArc(Rect.X + Rect.Width - radius,
							 Rect.Y + Rect.Height - radius, radius, radius, 0, 90);
			GraphPath.AddLine(Rect.Width - r2, Rect.Height, Rect.X + r2, Rect.Height);
			GraphPath.AddArc(Rect.X, Rect.Y + Rect.Height - radius, radius, radius, 90, 90);
			GraphPath.AddLine(Rect.X, Rect.Height - r2, Rect.X, Rect.Y + r2);
			GraphPath.CloseFigure();
			return GraphPath;
		}

		protected override void OnPaint(PaintEventArgs e)
		{
			base.OnPaint(e);
			RectangleF Rect = new(0, 0, this.Width, this.Height);

			using GraphicsPath GraphPath = GetRoundPath(Rect, borderRadius);

			Region = new Region(GraphPath);

			using Pen pen = new(borderColor, borderWidth);

			pen.Alignment = PenAlignment.Inset;
			e.Graphics.DrawPath(pen, GraphPath);
		}
	}
}
