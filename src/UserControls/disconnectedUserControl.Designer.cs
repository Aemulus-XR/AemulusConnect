namespace AemulusConnect
{
	partial class disconnectedUserControl
	{
		/// <summary> 
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.IContainer components = null;

		/// <summary> 
		/// Clean up any resources being used.
		/// </summary>
		/// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
		protected override void Dispose(bool disposing)
		{
			if (disposing && (components != null))
			{
				components.Dispose();
			}
			base.Dispose(disposing);
		}

		#region Component Designer generated code

		/// <summary> 
		/// Required method for Designer support - do not modify 
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(disconnectedUserControl));
			label1 = new Label();
			label2 = new Label();
			textLabel1 = new Label();
			textLabel2 = new Label();
			pictureBox1 = new PictureBox();
			pictureBox2 = new PictureBox();
			((System.ComponentModel.ISupportInitialize)pictureBox1).BeginInit();
			((System.ComponentModel.ISupportInitialize)pictureBox2).BeginInit();
			SuspendLayout();
			// 
			// label1
			// 
			label1.AutoSize = true;
			label1.Font = new Font("Arial", 30F);
			label1.Location = new Point(127, 166);
			label1.Margin = new Padding(2, 0, 2, 0);
			label1.Name = "label1";
			label1.Size = new Size(42, 45);
			label1.TabIndex = 2;
			label1.Text = Properties.Resources.Disconnected_StepNumber1;
			// 
			// label2
			// 
			label2.AutoSize = true;
			label2.Font = new Font("Arial", 30F);
			label2.Location = new Point(422, 166);
			label2.Margin = new Padding(2, 0, 2, 0);
			label2.Name = "label2";
			label2.Size = new Size(42, 45);
			label2.TabIndex = 3;
			label2.Text = Properties.Resources.Disconnected_StepNumber2;
			// 
			// textLabel1
			// 
			textLabel1.AutoSize = true;
			textLabel1.Font = new Font("Arial", 14F);
			textLabel1.Location = new Point(21, 216);
			textLabel1.Margin = new Padding(2, 0, 2, 0);
			textLabel1.MaximumSize = new Size(268, 0);
			textLabel1.Name = "textLabel1";
			textLabel1.Size = new Size(260, 66);
			textLabel1.TabIndex = 4;
			textLabel1.Text = Properties.Resources.Disconnected_Instruction1;
			textLabel1.TextAlign = ContentAlignment.TopCenter;
			// 
			// textLabel2
			// 
			textLabel2.AutoSize = true;
			textLabel2.Font = new Font("Arial", 14F);
			textLabel2.Location = new Point(302, 216);
			textLabel2.Margin = new Padding(2, 0, 2, 0);
			textLabel2.MaximumSize = new Size(292, 0);
			textLabel2.Name = "textLabel2";
			textLabel2.Size = new Size(286, 66);
			textLabel2.TabIndex = 5;
			textLabel2.Text = Properties.Resources.Disconnected_Instruction2;
			textLabel2.TextAlign = ContentAlignment.TopCenter;
			// 
			// pictureBox1
			// 
			pictureBox1.Image = (Image)resources.GetObject("pictureBox1.Image");
			pictureBox1.Location = new Point(84, 46);
			pictureBox1.Name = "pictureBox1";
			pictureBox1.Size = new Size(125, 97);
			pictureBox1.SizeMode = PictureBoxSizeMode.StretchImage;
			pictureBox1.TabIndex = 6;
			pictureBox1.TabStop = false;
			// 
			// pictureBox2
			// 
			pictureBox2.Image = (Image)resources.GetObject("pictureBox2.Image");
			pictureBox2.Location = new Point(311, 46);
			pictureBox2.Name = "pictureBox2";
			pictureBox2.Size = new Size(268, 117);
			pictureBox2.SizeMode = PictureBoxSizeMode.StretchImage;
			pictureBox2.TabIndex = 7;
			pictureBox2.TabStop = false;
			// 
			// disconnectedUserControl
			// 
			AutoScaleDimensions = new SizeF(7F, 15F);
			AutoScaleMode = AutoScaleMode.Font;
			BackColor = Color.Transparent;
			Controls.Add(pictureBox2);
			Controls.Add(pictureBox1);
			Controls.Add(textLabel2);
			Controls.Add(textLabel1);
			Controls.Add(label2);
			Controls.Add(label1);
			Margin = new Padding(2);
			Name = "disconnectedUserControl";
			Size = new Size(601, 332);
			((System.ComponentModel.ISupportInitialize)pictureBox1).EndInit();
			((System.ComponentModel.ISupportInitialize)pictureBox2).EndInit();
			ResumeLayout(false);
			PerformLayout();
		}

		#endregion
		private Label label1;
		private Label label2;
		private Label textLabel1;
		private Label textLabel2;
		private PictureBox pictureBox1;
		private PictureBox pictureBox2;
	}
}
