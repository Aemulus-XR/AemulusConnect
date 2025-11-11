namespace AemulusConnect
{
	using VisualElements;

	partial class connectedUserControl
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
			System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(connectedUserControl));
			logoBox = new PictureBox();
			statusLabel = new Label();
			lblNumReports = new Label();
			btnTransfer = new RoundedButton();
			btnViewReports = new RoundedButton();
			label1 = new Label();
			((System.ComponentModel.ISupportInitialize)logoBox).BeginInit();
			SuspendLayout();
			// 
			// logoBox
			// 
			logoBox.Image = (Image)resources.GetObject("logoBox.Image");
			logoBox.Location = new Point(236, 37);
			logoBox.Margin = new Padding(2);
			logoBox.MaximumSize = new Size(120, 100);
			logoBox.Name = "logoBox";
			logoBox.Size = new Size(120, 100);
			logoBox.SizeMode = PictureBoxSizeMode.StretchImage;
			logoBox.TabIndex = 5;
			logoBox.TabStop = false;
			// 
			// statusLabel
			// 
			statusLabel.AutoSize = true;
			statusLabel.Font = new Font("Arial", 16F, FontStyle.Bold);
			statusLabel.ImageAlign = ContentAlignment.TopCenter;
			statusLabel.Location = new Point(196, 139);
			statusLabel.Margin = new Padding(2, 0, 2, 0);
			statusLabel.Name = "statusLabel";
			statusLabel.RightToLeft = RightToLeft.No;
			statusLabel.Size = new Size(207, 26);
			statusLabel.TabIndex = 4;
			statusLabel.Text = Properties.Resources.Connected_StatusLabel;
			statusLabel.TextAlign = ContentAlignment.BottomCenter;
			// 
			// lblNumReports
			// 
			lblNumReports.AutoSize = true;
			lblNumReports.Font = new Font("Arial", 14F);
			lblNumReports.Location = new Point(196, 310);
			lblNumReports.MinimumSize = new Size(200, 0);
			lblNumReports.Name = "lblNumReports";
			lblNumReports.Size = new Size(200, 22);
			lblNumReports.TabIndex = 8;
			lblNumReports.TextAlign = ContentAlignment.TopCenter;
			// 
			// btnTransfer
			// 
			btnTransfer.AutoSize = true;
			btnTransfer.AutoSizeMode = AutoSizeMode.GrowAndShrink;
			btnTransfer.BackColor = Color.FromArgb(1, 105, 224);
			btnTransfer.FlatAppearance.BorderColor = Color.FromArgb(1, 105, 224);
			btnTransfer.FlatAppearance.BorderSize = 0;
			btnTransfer.FlatAppearance.MouseDownBackColor = Color.FromArgb(1, 105, 224);
			btnTransfer.FlatAppearance.MouseOverBackColor = Color.FromArgb(1, 105, 224);
			btnTransfer.FlatStyle = FlatStyle.Flat;
			btnTransfer.Font = new Font("Arial", 16F);
			btnTransfer.ForeColor = Color.White;
			btnTransfer.Location = new Point(65, 212);
			btnTransfer.Margin = new Padding(4, 3, 4, 3);
			btnTransfer.Name = "btnTransfer";
			btnTransfer.Padding = new Padding(24, 12, 24, 12);
			btnTransfer.RoundedBorderColor = Color.FromArgb(1, 105, 224);
			btnTransfer.RoundedBorderRadius = 10;
			btnTransfer.RoundedBorderWidth = 0F;
			btnTransfer.Size = new Size(206, 59);
			btnTransfer.TabIndex = 3;
			btnTransfer.Text = Properties.Resources.Connected_FetchButton;
			btnTransfer.UseVisualStyleBackColor = false;
			btnTransfer.Click += btnTransfer_Click;
			// 
			// btnViewReports
			// 
			btnViewReports.AutoSize = true;
			btnViewReports.AutoSizeMode = AutoSizeMode.GrowAndShrink;
			btnViewReports.BackColor = Color.FromArgb(1, 105, 224);
			btnViewReports.FlatAppearance.BorderSize = 0;
			btnViewReports.FlatStyle = FlatStyle.Flat;
			btnViewReports.Font = new Font("Arial", 16F);
			btnViewReports.ForeColor = Color.White;
			btnViewReports.Location = new Point(327, 210);
			btnViewReports.Margin = new Padding(4, 3, 4, 3);
			btnViewReports.Name = "btnViewReports";
			btnViewReports.Padding = new Padding(24, 12, 24, 12);
			btnViewReports.RoundedBorderColor = Color.FromArgb(1, 105, 224);
			btnViewReports.RoundedBorderRadius = 10;
			btnViewReports.RoundedBorderWidth = 0F;
			btnViewReports.Size = new Size(200, 59);
			btnViewReports.TabIndex = 5;
			btnViewReports.Text = Properties.Resources.Connected_ViewButton;
			btnViewReports.UseVisualStyleBackColor = false;
			btnViewReports.Click += btnViewReports_Click;
			// 
			// connectedUserControl
			// 
			AutoScaleDimensions = new SizeF(7F, 15F);
			AutoScaleMode = AutoScaleMode.Font;
			BackColor = Color.Transparent;
			Controls.Add(label1);
			Controls.Add(logoBox);
			Controls.Add(statusLabel);
			Controls.Add(btnTransfer);
			Controls.Add(btnViewReports);
			Controls.Add(lblNumReports);
			Margin = new Padding(2);
			Name = "connectedUserControl";
			Size = new Size(601, 332);
			((System.ComponentModel.ISupportInitialize)logoBox).EndInit();
			ResumeLayout(false);
			PerformLayout();
		}

		#endregion

		private PictureBox logoBox;
		private Label statusLabel;
		private Label lblNumReports;
		private RoundedButton btnTransfer;
		private RoundedButton btnViewReports;
		private Label label1;
	}
}
