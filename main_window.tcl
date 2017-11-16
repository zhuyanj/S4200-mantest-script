namespace eval moni {
    variable M

    set M(Menu) {
        "File" all file 0 {
            {command "Exit"    {} "Exit Monitor"   {} -command ::moni::done}
        }
    }
}

################################################################################
#                               < 设置notebook >

proc moni::nb_tab {name} {
    if {[info exist ::moni::M(Win.TTY.$name)]} {
		focus $::moni::M(Win.TTY.$name)
	}
}

proc moni::createPopMenuEditorWindow {} {

    set ::moni::textMenu [menu .textmenu -tearoff 0]

    $::moni::textMenu delete 1 end

    $::moni::textMenu add command -label "Close current serial  Ctrl+X" -font { 宋体 9 normal } -command moni::close_serial
    $::moni::textMenu add separator

    $::moni::textMenu add command -label "Copy    Ctrl+C" -font { 宋体 9 normal } -command ::moni::selection_copy
    $::moni::textMenu add command -label "Paste    Ctrl+P" -font { 宋体 9 normal } -command ::moni::selection_paste
    $::moni::textMenu add separator
    $::moni::textMenu add command -label "Copy & Paste" -font { 宋体 9 normal } -command ::moni::selection_copy_and_paste
    $::moni::textMenu add separator
    $::moni::textMenu add command -label "Select all    Ctrl+A" -font { 宋体 9 normal } -command ::moni::select_all
    $::moni::textMenu add separator
    $::moni::textMenu add command -label "Select all & Copy" -font { 宋体 9 normal } -command ::moni::select_all_and_copy

}

proc moni::win_tty { nb title} {

    variable M

    set f [$nb insert end $title -text $title -raisecmd "::moni::nb_tab $title"]
    set sw  [ScrolledWindow $f.sw -scrollbar vertical -auto both]
    set txt [text $sw.txt -height 24 -width 80 -bg #000000000000 -fg #0000ffff0000 -insertbackground #0000ffff0000]
    $sw setwidget $txt
    pack $sw -fill both -expand yes

    set M(Win.TTY.$title) $txt
    bind $M(Win.TTY.$title) <Any-Key> { ::moni::tty_key %W %A %K }

    bind $M(Win.TTY.$title) <Control-Tab> {::moni::tty_switch}

    bind $M(Win.TTY.$title) <Control-x> {::moni::disconnect}

    bind $M(Win.TTY.$title) <Button-3> {tk_popup $::moni::textMenu %X %Y ; break}

    $nb raise $title
    focus $M(Win.TTY.$title)

    set M($title.Log.Dir)  ""
    set M($title.Log.Open) 0
    set M($title.Term.Log) 0
    set M($title.Log.Count) 0

    set M(RecvFlag.$title) 0
}

proc moni::update_status {} {
    variable M

    if { $M(Open) } {
        set M(TTY.OutQueue) [lindex [fconfigure $M(Chan) -queue] 1]
        set statStr [fconfigure $M(Chan) -ttystatus]
        foreach {name val} $statStr {
            set M(TTY.Stat.$name) $val
        }
    }
}

################################################################################
#                                < 创建主界面 >

proc moni::win {} {
    variable M

    #右键菜单
    ::moni::createPopMenuEditorWindow
    #主菜单

    if {$::moni::M(Debug) == "y"} {
	set descmenu {

	    "Config" all file 0 {
	        {command "Serial config" {} "Serial config" {Ctrl P} -font { 宋体 9 normal } -command "::moni::config_new"}
	        {command "Test config" {} "Test config" {Ctrl T} -font { 宋体 9 normal } -command "::moni::set_test_config"}
	        {separator}
	        {command "(&X)Exit" {} "Exit Application" {} -font { 宋体 9 normal } -command "::moni::test"}
	    }

	    "Test" all edit 1 {
	        {command "Start" {} "Start" {Ctrl K} -font { 宋体 9 normal } -command "::moni::set_mac"}
	        {command "Stop" {} "Stop" {Ctrl E} -font { 宋体 9 normal } -command "::moni::new_test"}
	    }

	    "Debug" all edit 2 {
	        {command "Run script" {} "Run script" {} -font { 宋体 9 normal } -command "::moni::set_script_params"}
	        {command "Local simulation" {} "Local simulation" {} -font { 宋体 9 normal } -command "::moni::select_local_01"}
	    }

	    "Help" all help 3 {
	        {command "(&A)About" {} "" {} -font { 宋体 9 normal } -command "::moni::appHelpAbout"}
	    }
	}
    } else {
    	set descmenu {

	    "Config" all file 0 {
	        {command "Serial config" {} "Serial config" {Ctrl P} -font { 宋体 9 normal } -command "::moni::config_new"}
	        {command "Test config" {} "Test config" {Ctrl T} -font { 宋体 9 normal } -command "::moni::set_test_config"}
	        {separator}
	        {command "(&X)Exit" {} "Exit Application" {} -font { 宋体 9 normal } -command "::moni::appExit"}
	    }

	    "Test" all edit 1 {
	        {command "Start" {} "Start" {Ctrl K} -font { 宋体 9 normal } -command "::moni::set_mac"}
	        {command "Stop" {} "Stop" {Ctrl E} -font { 宋体 9 normal } -command "::moni::new_test"}
	    }

	    "Help" all help 3 {
	        {command "(&A)About" {} "" {} -font { 宋体 9 normal } -command "::moni::appHelpAbout"}
	    }
	}
    }

    #============================== main frame ==================================

    set mainframe [MainFrame .moni -menu $descmenu -height 100 -width 100]

    #-------------------------- toolbar 1 creation ------------------------------

    set tb1  [$mainframe addtoolbar]
    pack configure $tb1 -expand yes -fill x

    #--------------------------- toolbar内的竖间隔线 --------------------------

    set sep1 [Separator $tb1.sep1 -orient vertical]
    pack $sep1 -side left -fill y -padx 4 -anchor w

    set bbox1 [ButtonBox $tb1.bbox1 -spacing 0 -padx 1 -pady 1]
    $bbox1 add -image [bitmap START] -command ::moni::set_mac \
        -highlightthickness 0 -takefocus 0 -relief link \
        -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Begin test"
    pack $bbox1 -side left -anchor w

    set sep2 [Separator $tb1.sep2 -orient vertical]
    pack $sep2 -side left -fill y -padx 4 -anchor w

    set bbox2 [ButtonBox $tb1.bbox2 -spacing 0 -padx 1 -pady 1]
    $bbox2 add -image [bitmap SORT] -command ::moni::set_test_config \
        -highlightthickness 0 -takefocus 0 -relief link \
        -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Test config"

    pack $bbox2 -side left -anchor w

    pack $mainframe -fill both -expand yes


    #============================== 创建控制台 =============================
    set mf [$mainframe getframe]
    set notebook [NoteBook $mf.nb]
    set ::moni::M(Win.Notebook) $notebook

    $notebook compute_size
    $notebook configure  -height 450 -width 600
    pack $notebook -fill both -expand yes -padx 4 -pady 4
    $notebook raise [$notebook page 0]

}