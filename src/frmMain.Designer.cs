namespace AemulusConnect
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
			menuStrip = new MenuStrip();
			fileToolStripMenuItem = new ToolStripMenuItem();
			settingsToolStripMenuItem = new ToolStripMenuItem();
			exitToolStripMenuItem = new ToolStripMenuItem();
			menuStrip.SuspendLayout();
			SuspendLayout();
			//
			// pnlMain
			//
			pnlMain.BackColor = Color.White;
			pnlMain.Location = new Point(0, 28);
			pnlMain.Margin = new Padding(2);
			pnlMain.Name = "pnlMain";
			pnlMain.Size = new Size(601, 305);
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
			// menuStrip
			//
			menuStrip.Items.AddRange(new ToolStripItem[] { fileToolStripMenuItem });
			menuStrip.Location = new Point(0, 0);
			menuStrip.Name = "menuStrip";
			menuStrip.Size = new Size(602, 24);
			menuStrip.TabIndex = 5;
			menuStrip.Text = "menuStrip1";
			//
			// fileToolStripMenuItem
			//
			fileToolStripMenuItem.DropDownItems.AddRange(new ToolStripItem[] { settingsToolStripMenuItem, exitToolStripMenuItem });
			fileToolStripMenuItem.Name = "fileToolStripMenuItem";
			fileToolStripMenuItem.Size = new Size(37, 20);
			fileToolStripMenuItem.Text = Properties.Resources.Menu_File;
			//
			// settingsToolStripMenuItem
			//
			settingsToolStripMenuItem.Name = "settingsToolStripMenuItem";
			settingsToolStripMenuItem.Size = new Size(180, 22);
			settingsToolStripMenuItem.Text = Properties.Resources.Menu_Settings;
			settingsToolStripMenuItem.Click += settingsToolStripMenuItem_Click;
			//
			// exitToolStripMenuItem
			//
			exitToolStripMenuItem.Name = "exitToolStripMenuItem";
			exitToolStripMenuItem.Size = new Size(180, 22);
			exitToolStripMenuItem.Text = Properties.Resources.Menu_Exit;
			exitToolStripMenuItem.Click += exitToolStripMenuItem_Click;
			//
			// frmMain
			//
			AutoScaleDimensions = new SizeF(7F, 15F);
			AutoScaleMode = AutoScaleMode.Font;
			ClientSize = new Size(602, 335);
			Controls.Add(lblVersion);
			Controls.Add(pnlMain);
			Controls.Add(menuStrip);
			MainMenuStrip = menuStrip;
			FormBorderStyle = FormBorderStyle.FixedSingle;
			Icon = (Icon)resources.GetObject("$this.Icon");
			Margin = new Padding(1);
			MaximizeBox = false;
			MinimizeBox = false;
			Name = "frmMain";
			RightToLeft = RightToLeft.No;
			StartPosition = FormStartPosition.CenterScreen;
			Text = "AemulusXR Report";
			Shown += frmMain_Shown;
			menuStrip.ResumeLayout(false);
			menuStrip.PerformLayout();
			ResumeLayout(false);
			PerformLayout();
		}

		#endregion
		private Panel pnlMain;
		private Label lblVersion;
		private MenuStrip menuStrip;
		private ToolStripMenuItem fileToolStripMenuItem;
		private ToolStripMenuItem settingsToolStripMenuItem;
		private ToolStripMenuItem exitToolStripMenuItem;
	}
}
