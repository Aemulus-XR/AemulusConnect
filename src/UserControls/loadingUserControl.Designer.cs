namespace Aemulus_XR_Reporting_App
{
	using VisualElements;

	partial class loadingUserControl
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
			System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(loadingUserControl));
			progressBar = new CustomProgressBar();
			lblDownloadStatus = new Label();
			logoBox = new PictureBox();
			statusLabel = new Label();
			((System.ComponentModel.ISupportInitialize)logoBox).BeginInit();
			SuspendLayout();
			// 
			// progressBar
			// 
			progressBar.BackColor = SystemColors.ButtonHighlight;
			progressBar.ForeColor = Color.FromArgb(1, 105, 224);
			progressBar.Location = new Point(97, 222);
			progressBar.Margin = new Padding(2);
			progressBar.MarqueeAnimationSpeed = 1;
			progressBar.Name = "progressBar";
			progressBar.Size = new Size(413, 12);
			progressBar.Step = 1;
			progressBar.Style = ProgressBarStyle.Continuous;
			progressBar.TabIndex = 0;
			// 
			// lblDownloadStatus
			// 
			lblDownloadStatus.AutoSize = true;
			lblDownloadStatus.Font = new Font("Arial", 15.8571434F, FontStyle.Regular, GraphicsUnit.Point, 0);
			lblDownloadStatus.Location = new Point(158, 251);
			lblDownloadStatus.MinimumSize = new Size(300, 0);
			lblDownloadStatus.Name = "lblDownloadStatus";
			lblDownloadStatus.Size = new Size(300, 25);
			lblDownloadStatus.TabIndex = 1;
			lblDownloadStatus.TextAlign = ContentAlignment.TopCenter;
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
			logoBox.TabIndex = 7;
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
			statusLabel.TabIndex = 6;
			statusLabel.Text = "AemulusXR Report";
			statusLabel.TextAlign = ContentAlignment.BottomCenter;
			// 
			// loadingUserControl
			// 
			AutoScaleDimensions = new SizeF(7F, 15F);
			AutoScaleMode = AutoScaleMode.Font;
			BackColor = Color.Transparent;
			Controls.Add(logoBox);
			Controls.Add(statusLabel);
			Controls.Add(lblDownloadStatus);
			Controls.Add(progressBar);
			Margin = new Padding(2);
			Name = "loadingUserControl";
			Size = new Size(601, 332);
			((System.ComponentModel.ISupportInitialize)logoBox).EndInit();
			ResumeLayout(false);
			PerformLayout();
		}

		#endregion

		private CustomProgressBar progressBar;
		private Label lblDownloadStatus;
		private PictureBox logoBox;
		private Label statusLabel;
	}
}
