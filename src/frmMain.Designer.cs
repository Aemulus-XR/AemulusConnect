namespace Aemulus_XR_Reporting_App
{
    partial class frmMain
    {
        /// <summary>
        ///  Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        ///  Clean up any resources being used.
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

		#region Windows Form Designer generated code

		/// <summary>
		///  Required method for Designer support - do not modify
		///  the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmMain));
			pnlMain = new Panel();
			lblVersion = new Label();
			SuspendLayout();
			// 
			// pnlMain
			// 
			pnlMain.BackColor = Color.White;
			pnlMain.Location = new Point(0, 1);
			pnlMain.Margin = new Padding(2);
			pnlMain.Name = "pnlMain";
			pnlMain.Size = new Size(601, 332);
			pnlMain.TabIndex = 3;
			// 
			// lblVersion
			// 
			lblVersion.Anchor = AnchorStyles.Left;
			lblVersion.AutoSize = true;
			lblVersion.BackColor = Color.White;
			lblVersion.Font = new Font("Arial", 14F);
			lblVersion.ForeColor = Color.FromArgb(179, 179, 179);
			lblVersion.Location = new Point(470, 310);
			lblVersion.MinimumSize = new Size(120, 0);
			lblVersion.Name = "lblVersion";
			lblVersion.RightToLeft = RightToLeft.No;
			lblVersion.Size = new Size(120, 22);
			lblVersion.TabIndex = 4;
			lblVersion.Text = "Version";
			lblVersion.TextAlign = ContentAlignment.TopRight;
			// 
			// frmMain
			// 
			AutoScaleDimensions = new SizeF(7F, 15F);
			AutoScaleMode = AutoScaleMode.Font;
			ClientSize = new Size(602, 335);
			Controls.Add(lblVersion);
			Controls.Add(pnlMain);
			FormBorderStyle = FormBorderStyle.FixedSingle;
			Icon = (Icon)resources.GetObject("$this.Icon");
			Margin = new Padding(1);
			MaximizeBox = false;
			MinimizeBox = false;
			Name = "frmMain";
			RightToLeft = RightToLeft.Yes;
			StartPosition = FormStartPosition.CenterScreen;
			Text = "AemulusXR Report";
			Shown += frmMain_Shown;
			ResumeLayout(false);
			PerformLayout();
		}

		#endregion
		private Panel pnlMain;
		private Label lblVersion;
	}
}
