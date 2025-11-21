namespace AemulusConnect
{
	using System.Globalization;

	public partial class disconnectedUserControl : UserControl
	{
		public disconnectedUserControl()
		{
			InitializeComponent();

			// For RTL languages, swap the step numbers so they appear in correct reading order
			// RightToLeftLayout automatically mirrors the control positions, so we only need to swap the content
			if (Helpers.LocalizationHelper.IsRightToLeft(CultureInfo.CurrentUICulture.Name))
			{
				// Swap the text content of the step numbers
				var temp = label1.Text;
				label1.Text = label2.Text;
				label2.Text = temp;

				// Swap the instruction text
				var tempText = textLabel1.Text;
				textLabel1.Text = textLabel2.Text;
				textLabel2.Text = tempText;

				// Swap the images and their sizes
				var tempImage = pictureBox1.Image;
				pictureBox1.Image = pictureBox2.Image;
				pictureBox2.Image = tempImage;

				// Swap the picture box sizes (they're different dimensions)
				var tempSize = pictureBox1.Size;
				pictureBox1.Size = pictureBox2.Size;
				pictureBox2.Size = tempSize;

				// Manually adjust picture box X positions to keep them centered over text
				// RightToLeftLayout mirrors positions, but we need to compensate to keep images centered
				// In RTL: pictureBox1 (now has wide image) should be over right text area
				//         pictureBox2 (now has small image) should be over left text area
				// The form width is 601, so we calculate RTL positions
				int formWidth = this.Width;

				// Keep the Y position, only adjust X for proper centering
				// pictureBox1 should center over the right side text (originally textLabel2's area)
				// pictureBox2 should center over the left side text (originally textLabel1's area)
				pictureBox1.Location = new Point(formWidth - 311 - pictureBox1.Width, pictureBox1.Location.Y);
				pictureBox2.Location = new Point(formWidth - 84 - pictureBox2.Width, pictureBox2.Location.Y);
			}
		}
	}
}
