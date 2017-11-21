
proc moni::get_script_param {index line} {
    variable M
    upvar title titlename

    set sp "\x0D"

    set start 0
    set end [expr {[string first $sp $line 0]-1}]
    if {$index>1} {
        for {set i 1} {$i < $index} {incr i} {
            set start [expr {$end+2}]
            set end [expr {[string first $sp $line $start]-1}]
        }
    }

    set titlename [string range $line $start $end]
}

proc moni::send_script_line {} {
#    tk_messageBox -message "M(ScriptName) = $::moni::M(ScriptName)"
#    tk_messageBox -message "M(ScriptTimes) = $::moni::M(ScriptTimes)"
#    tk_messageBox -message "M(ScriptInterval) = $::moni::M(ScriptInterval)"
    set file [open $::moni::M(ScriptName) r]
    while {[gets $file line] >= 0} {
#    	gets $file line
#    	tk_messageBox -message "line = $line"
    	::moni::send $::moni::Cfg(name) "$line\r"
    	#tk_messageBox -message "$line"
    	if {[string first "loopback" $line 0] >= 0} {
    	    #tk_messageBox -message "loopback"
    	    ::moni::wait 15000
    	} else {
    	    ::moni::wait $::moni::M(ScriptInterval)
    	}
#    	::moni::get_param 1 $line

#        $win.selection.list insert end $name
    }

    close $file

}

proc moni::confirm_script_params_set {} {
    destroy .scriptSetDlg

    for {set i 0} {$i < $::moni::M(ScriptTimes)} {incr i} {
        ::moni::send_script_line
    }
}

proc moni::set_script_params {} {
    variable M
    toplevel .scriptSetDlg

    wm withdraw .scriptSetDlg
    update
    BWidget::place .scriptSetDlg 300 220 center
    wm transient .scriptSetDlg .
    wm title     .scriptSetDlg "Script parameter config"
    wm deiconify .scriptSetDlg
    wm resizable .scriptSetDlg 0 0

    set win .scriptSetDlg

    set lab1 [Label $win.label1 -text "Loop times:" -font { 宋体 12 normal } -fg blue \
        -width 15 -anchor w  -helptext "Loop times"]
	set ent1 [Entry $win.entry1 -background white  -width 25 -state normal \
	    -textvariable ::moni::M(ScriptTimes)]

    place $lab1 \
                -in $win -x 25 -y 30 -width 100 -height 20 -anchor nw \
                -bordermode ignore
    place $ent1 \
                -in $win -x 150 -y 30 -width 120 -height 20 -anchor nw \
                -bordermode ignore

    set lab2 [Label $win.label2 -text "Time interval:" -font { 宋体 12 normal } -fg blue \
        -width 15 -anchor w  -helptext "Time interval"]
	set ent2 [Entry $win.entry2 -background white  -width 25 -state normal \
	    -textvariable ::moni::M(ScriptInterval)]

    place $lab2 \
                -in $win -x 25 -y 80 -width 120 -height 20 -anchor nw \
                -bordermode ignore
    place $ent2 \
                -in $win -x 150 -y 80 -width 120 -height 20 -anchor nw \
                -bordermode ignore

    set lab3 [Label $win.label3 -text "Script name:" -font { 宋体 12 normal } -fg blue \
        -width 15 -anchor w  -helptext "Script name"]
	set ent3 [Entry $win.entry3 -background white  -width 25 -state normal \
	    -textvariable ::moni::M(ScriptName)]

    place $lab3 \
                -in $win -x 25 -y 130 -width 100 -height 20 -anchor nw \
                -bordermode ignore
    place $ent3 \
                -in $win -x 150 -y 130 -width 120 -height 20 -anchor nw \
                -bordermode ignore

    set bbox [ButtonBox $win.bbox -spacing 10 -padx 1 -pady 1]

    $bbox add -text "Execute" -font { 宋体 12 normal } -width 10 -fg brown \
        -helptext "Execute" \
        -command {::moni::confirm_script_params_set} \
        -highlightthickness 0 -takefocus 0 -borderwidth 2 -padx 4 -pady 4

    place $win.bbox -in .scriptSetDlg -x 100 -y 160 -width 100 -height 36 \
        -anchor nw -bordermode ignore

    grab .scriptSetDlg
    focus -force .scriptSetDlg
}

proc moni::select_test_mode {} {
    if {$::moni::M(Manufactory) == "01"} {
       place forget .testSetDlg.labf
	place .testSetDlg.labf1 \
	-in .testSetDlg -x 70 -y 120 -width 400 -height 300 -anchor nw \
	-bordermode ignore

    } elseif {$::moni::M(Manufactory) == "SCC"} {
        place forget .testSetDlg.labf1
        place .testSetDlg.labf \
        -in .testSetDlg -x 70 -y 120 -width 400 -height 300 -anchor nw \
        -bordermode ignore

    }
    ::moni::save_test_variable $::moni::M(Manufactory) "manufactory:" $::moni::M(Manufactory)
}

proc moni::set_test_config {} {
    variable M
    toplevel .testSetDlg

    wm withdraw .testSetDlg
    update
    BWidget::place .testSetDlg 550 480 center
    wm transient .testSetDlg .
    wm title     .testSetDlg "Test config"
    wm deiconify .testSetDlg
    wm resizable .testSetDlg 0 0

    set win .testSetDlg

    set lab [Label $win.label -text "Hareware version:" -font { 宋体 12 normal } -fg blue \
        -width 30 -anchor w  -helptext "Hareware version"]
    set ent [Entry $win.entry1 -background white  -width 25 -state disabled \
	 -textvariable ::moni::M(HWVersion)]

    place $lab \
        -in $win -x 70 -y 30 -width 150 -height 20 -anchor nw \
        -bordermode ignore
    place $ent \
        -in $win -x 230 -y 30 -width 220 -height 20 -anchor nw \
        -bordermode ignore


    set lab1 [Label $win.label1 -text "Board Type:" -font { 宋体 12 normal } -fg blue \
        -width 30 -anchor w  -helptext "Board Type:"]
    set ent1 [Entry $win.entry2 -background white  -width 25 -state disabled \
        -textvariable ::moni::M(BoardType)]

    place $lab1 \
        -in $win -x 70 -y 60 -width 150 -height 20 -anchor nw \
        -bordermode ignore
    place $ent1 \
        -in $win -x 230 -y 60 -width 220 -height 20 -anchor nw \
        -bordermode ignore


    set lab2 [Label $win.label2 -text "Manufactory:" -font { 宋体 12 normal } -fg blue \
        -width 30 -anchor w  -helptext "Manufactory:"]
    ComboBox $win.combl3 \
        -textvariable ::moni::M(Manufactory) -editable 0 \
        -values {} -font { 宋体 12 normal } -width 25 \
        -modifycmd {::moni::select_test_mode} \
        -helptext [$win.label2 cget -helptext]

    place $lab2 \
        -in $win -x 70 -y 90 -width 150 -height 20 -anchor nw \
        -bordermode ignore
    place $win.combl3 \
        -in $win -x 230 -y 90 -width 220 -height 20 -anchor nw \
        -bordermode ignore



    labelframe $win.labf -font { 宋体 10 normal } -fg black
    place $win.labf \
        -in $win -x 70 -y 120 -width 400 -height 300 -anchor nw \
        -bordermode ignore

    catch {Label $win.labf.label1 -text "Test tpye:" -font { 宋体 12 normal } -fg blue \
        -width 15 -anchor w  -helptext "Test tpye"}
    place $win.labf.label1 \
        -in $win.labf  -x 10 -y 20 -width 100 -height 20


    set rad1 [radiobutton $win.labf.rad1 -text "P/T" \
        -command {moni::first_test_select} \
	 -font { 宋体 12 normal } -fg black -value en ]

    place $win.labf.rad1 \
        -in $win.labf -x 140 -y 60 -width 120 -height 30 -anchor nw \
        -bordermode ignore

    set rad2 [radiobutton $win.labf.rad2 -text "F/T" \
        -command {moni::last_test_select} \
        -font { 宋体 12 normal } -fg black -value fr]

    place $win.labf.rad2 \
        -in $win.labf -x 140 -y 110 -width 120 -height 30 -anchor nw \
        -bordermode ignore

    if {$::moni::M(TestType) == "P/T"} {
        $win.labf.rad1 select
    } elseif {$::moni::M(TestType) == "F/T"} {
        $win.labf.rad2 select
    }


   #01界面
    labelframe $win.labf1 -font { 宋体 10 normal } -fg black

    catch {Label $win.labf1.label8 -text "WS_ID:" -font { 宋体 12 normal } -fg blue \
        -width 15 -anchor w  -helptext "WS_ID"}
    place $win.labf1.label8 \
        -in $win.labf1  -x 10 -y 20 -width 100 -height 20

    set rad3 [radiobutton $win.labf1.rad3 -text "P/T" \
        -command {moni::first_test_select} \
	 -font { 宋体 12 normal } -fg black -value en ]
    set rad4 [radiobutton $win.labf1.rad4 -text "F/T" \
        -command {moni::last_test_select} \
        -font { 宋体 12 normal } -fg black -value fr]

    place $win.labf1.rad3 \
        -in $win.labf1 -x 120 -y 20 -width 100 -height 20 -anchor nw \
        -bordermode ignore
    place $win.labf1.rad4 \
        -in $win.labf1 -x 280 -y 20 -width 100 -height 20 -anchor nw \
        -bordermode ignore

    if {$::moni::M(TestType) == "P/T"} {
        $win.labf1.rad3 select
    } elseif {$::moni::M(TestType) == "F/T"} {
        $win.labf1.rad4 select
    }

    catch {Label $win.labf1.label6 -text "LINE:" -font { 宋体 12 normal } -fg blue \
        -width 15 -anchor w  -helptext "LINE"}
    catch {Entry $win.entry6 -background white -width 25 -state normal \
        -textvariable ::moni::M(LINE)}
    place $win.labf1.label6 \
        -in $win.labf1  -x 10 -y 60 -width 100 -height 20
    place $win.entry6 \
        -in $win.labf1  -x 120 -y 60 -width 260 -height 20

    catch {Label $win.labf1.label7 -text "SHIFT:" -font { 宋体 12 normal } -fg blue \
        -width 15 -anchor w  -helptext "SHIFT"}
    catch {Entry $win.entry7 -background white -width 25 -state normal \
        -textvariable ::moni::M(SHIFT)}
    place $win.labf1.label7 \
        -in $win.labf1  -x 10 -y 100 -width 100 -height 20
    place $win.entry7 \
        -in $win.labf1  -x 120 -y 100 -width 260 -height 20


    catch {Label $win.labf1.label9 -text "OPERATOR:" -font { 宋体 12 normal } -fg blue \
        -width 15 -anchor w  -helptext "OPERATOR"}
    catch {Entry $win.entry9 -background white -width 25 -state normal \
        -textvariable ::moni::M(OPERATOR)}
    place $win.labf1.label9 \
        -in $win.labf1  -x 10 -y 140 -width 100 -height 20
    place $win.entry9 \
        -in $win.labf1  -x 120 -y 140 -width 260 -height 20

    catch {Label $win.labf1.label10 -text "RACK:" -font { 宋体 12 normal } -fg blue \
        -width 15 -anchor w  -helptext "RACK"}
    catch {Entry $win.entry10 -background white -width 25 -state normal \
        -textvariable ::moni::M(RACK)}
    place $win.labf1.label10 \
        -in $win.labf1  -x 10 -y 180 -width 100 -height 20
    place $win.entry10 \
        -in $win.labf1  -x 120 -y 180 -width 260 -height 20

    catch {Label $win.labf1.label11 -text "LOT_NO:" -font { 宋体 12 normal } -fg blue \
        -width 15 -anchor w  -helptext "LOT_NO"}
    catch {Entry $win.entry11 -background white -width 25 -state normal \
        -textvariable ::moni::M(LOT_NO)}
    place $win.labf1.label11 \
        -in $win.labf1  -x 10 -y 220 -width 100 -height 20
    place $win.entry11 \
        -in $win.labf1  -x 120 -y 220 -width 260 -height 20

    catch {Label $win.labf1.label12 -text "TEST VERSION:" -font { 宋体 12 normal } -fg blue \
        -width 15 -anchor w  -helptext "TEST VERSION"}
    catch {Entry $win.entry12 -background white -width 25 -state normal \
        -textvariable ::moni::M(TEST_VER)}
    place $win.labf1.label12 \
        -in $win.labf1  -x 10 -y 260 -width 100 -height 20
    place $win.entry12 \
        -in $win.labf1  -x 120 -y 260 -width 260 -height 20


    set bbox [ButtonBox $win.bbox -spacing 10 -padx 1 -pady 1]

    $bbox add -text "Confirm" -font { 宋体 12 normal } -width 10 -fg brown \
        -helptext "Confirm" \
        -command {::moni::confirm_test_set} \
        -highlightthickness 0 -takefocus 0 -borderwidth 2 -padx 4 -pady 4

    place $win.bbox -in .testSetDlg -x 225 -y 430 -width 100 -height 36 \
        -anchor nw -bordermode ignore


    grab .testSetDlg
    focus -force .testSetDlg

    ::moni::init_test_mode_info
}

proc moni::init_test_mode_info {} {
    set pstr "SCC"
    .testSetDlg.combl3 configure -values $pstr
    ::moni::select_test_mode
}

################################################################################
#                                   < 测试配置 >

proc moni::sendlogfile {} {
	
	#给一定时间缓冲串口log，再发送日志
	if { $::moni::M(BoardType) == "S4200-28P-SI" \
		|| $::moni::M(BoardType) == "S4200-28P-P-SI" } {
		return
	}
	::moni::wait 5000

	::moni::get_time

	#一个设备一个log
	if { $::moni::M(SN) != $::moni::M(CURRSN) } {

		if { $::moni::M(TestType) == "P/T" } {
			set ::moni::M(LOGFILE) $::moni::M(SN)_$::moni::M(Year)$::moni::M(Month)$::moni::M(Day)$::moni::M(Hour)$::moni::M(Minute)$::moni::M(Second)PT.txt
		} else {
			set ::moni::M(LOGFILE) $::moni::M(SN)_$::moni::M(Year)$::moni::M(Month)$::moni::M(Day)$::moni::M(Hour)$::moni::M(Minute)$::moni::M(Second)FT.txt
		}

		set ::moni::M(CURRSN)  $::moni::M(SN)
	}

	if { $::moni::M(ErrorFound) == 0 } {
		set factoryfile 0pass$::moni::M(LOGFILE)
	} else {
		set factoryfile 0fail$::moni::M(LOGFILE)
	}

	file copy -force log/$::moni::M(SN).com.txt log/$factoryfile

	set send_log [exec java -jar java/HttpClient.jar sendFile log/$factoryfile \
				$::moni::M(ATEMSN) $::moni::M(MacVlan) $::moni::M(SN)]
	if {$send_log != 200} {
		tk_messageBox -message "$moni::MSG(check_sendlog_msg)"
	}



}

proc moni::set_hwinfo {} {
    variable M
    toplevel .testSetDlg

    wm withdraw .testSetDlg
    update
    BWidget::place .testSetDlg 550 280 center
    wm transient .testSetDlg .
    wm title     .testSetDlg "Test config"
    wm deiconify .testSetDlg
    wm resizable .testSetDlg 0 0

    set win .testSetDlg
#    set f [frame $win.cfg]

    set lab [Label $win.label -text "Hareware version:" -font { 宋体 12 normal } -fg blue \
        -width 30 -anchor w  -helptext "Hareware version"]
	  set ent [Entry $win.entry1 -background white  -width 25 -state normal \
	    -textvariable ::moni::M(HWVersion)]

    place $lab \
        -in $win -x 70 -y 30 -width 150 -height 20 -anchor nw \
        -bordermode ignore
    place $ent \
        -in $win -x 230 -y 30 -width 140 -height 20 -anchor nw \
        -bordermode ignore

     labelframe $win.labf -font { 宋体 10 normal } -fg black
#产测优化后去掉producer选项
    Label $win.labf.label3 -text "Producer:" -font { 宋体 12 normal } -fg blue \
        -width 15 -anchor w  -helptext "Producer"
    ComboBox $win.labf.combl1 \
        -textvariable ::moni::M(Producer) -editable 0 \
        -modifycmd {moni::modproducer} \
        -values {"SCC" "01" "59" "60" "RUN"} -width 25 \
        -helptext [$win.labf.label3 cget -helptext]
    #grid $win.labf.label3 $win.labf.combl1 -pady 15
#    place $win.labf.label3 \
#        -in $win.labf  -x 10 -y 10 -width 100 -height 20
#    place $win.labf.combl1 \
#        -in $win.labf  -x 120 -y 10 -width 160 -height 20

#产测优化后去掉Product type选项
    Label $win.labf.label4 -text "Product type:" -font { 宋体 12 normal } -fg blue \
        -width 15 -anchor w  -helptext "Product type"
    ComboBox $win.labf.combl2 \
        -textvariable ::moni::M(ProductType) -editable 0 \
        -modifycmd {moni::modptype} \
        -values {} -width 25 \
        -helptext [$win.labf.label4 cget -helptext]
    #grid $win.labf.label4 $win.labf.combl2 -pady 15
#    place $win.labf.label4 \
#        -in $win.labf  -x 10 -y 50 -width 100 -height 20
#    place $win.labf.combl2 \
#        -in $win.labf  -x 120 -y 50 -width 160 -height 20

    Label $win.labf.label5 -text "Board Type:" -font { 宋体 12 normal } -fg blue \
        -width 15 -anchor w  -helptext "Board Type"
    ComboBox $win.labf.combl3 \
        -textvariable ::moni::M(BoardType) -editable 0 \
        -values {} -font { 宋体 12 normal } -width 25 \
        -helptext [$win.labf.label5 cget -helptext]
    #grid $win.labf.label5 $win.labf.combl3 -pady 15
    place $win.labf.label5 \
        -in $win.labf  -x 10 -y 10 -width 100 -height 25
    place $win.labf.combl3 \
        -in $win.labf  -x 120 -y 10 -width 260 -height 25

    if {$::moni::M(Manufactory) == "01"} {
        place $win.labf \
            -in $win -x 70 -y 80 -width 400 -height 320 -anchor nw \
            -bordermode ignore

        catch {Label $win.labf.label6 -text "LINE:" -font { 宋体 12 normal } -fg blue \
            -width 15 -anchor w  -helptext "LINE"}
        catch {Entry $win.entry2 -background white -width 25 -state normal \
	        -textvariable ::moni::M(LINE)}
        place $win.labf.label6 \
            -in $win.labf  -x 10 -y 40 -width 100 -height 20
        place $win.entry2 \
            -in $win.labf  -x 120 -y 40 -width 260 -height 20

        catch {Label $win.labf.label7 -text "SHIFT:" -font { 宋体 12 normal } -fg blue \
            -width 15 -anchor w  -helptext "SHIFT"}
        catch {Entry $win.entry3 -background white -width 25 -state normal \
	        -textvariable ::moni::M(SHIFT)}
        place $win.labf.label7 \
            -in $win.labf  -x 10 -y 80 -width 100 -height 20
        place $win.entry3 \
            -in $win.labf  -x 120 -y 80 -width 260 -height 20

        catch {Label $win.labf.label8 -text "WS_ID:" -font { 宋体 12 normal } -fg blue \
            -width 15 -anchor w  -helptext "WS_ID"}
        catch {Entry $win.entry4 -background white -width 25 -state normal \
	        -textvariable ::moni::M(WS_ID)}
        place $win.labf.label8 \
            -in $win.labf  -x 10 -y 120 -width 100 -height 20
        place $win.entry4 \
            -in $win.labf  -x 120 -y 120 -width 260 -height 20

        catch {Label $win.labf.label9 -text "OPERATOR:" -font { 宋体 12 normal } -fg blue \
            -width 15 -anchor w  -helptext "OPERATOR"}
        catch {Entry $win.entry5 -background white -width 25 -state normal \
	        -textvariable ::moni::M(OPERATOR)}
        place $win.labf.label9 \
            -in $win.labf  -x 10 -y 160 -width 100 -height 20
        place $win.entry5 \
            -in $win.labf  -x 120 -y 160 -width 260 -height 20

        catch {Label $win.labf.label10 -text "RACK:" -font { 宋体 12 normal } -fg blue \
            -width 15 -anchor w  -helptext "RACK"}
        catch {Entry $win.entry6 -background white -width 25 -state normal \
	        -textvariable ::moni::M(RACK)}
        place $win.labf.label10 \
            -in $win.labf  -x 10 -y 200 -width 100 -height 20
        place $win.entry6 \
            -in $win.labf  -x 120 -y 200 -width 260 -height 20

        catch {Label $win.labf.label11 -text "LOT_NO:" -font { 宋体 12 normal } -fg blue \
            -width 15 -anchor w  -helptext "LOT_NO"}
        catch {Entry $win.entry7 -background white -width 25 -state normal \
	        -textvariable ::moni::M(LOT_NO)}
        place $win.labf.label11 \
            -in $win.labf  -x 10 -y 240 -width 100 -height 20
        place $win.entry7 \
            -in $win.labf  -x 120 -y 240 -width 260 -height 20

        catch {Label $win.labf.label12 -text "TEST VERSION:" -font { 宋体 12 normal } -fg blue \
            -width 15 -anchor w  -helptext "TEST VERSION"}
        catch {Entry $win.entry8 -background white -width 25 -state normal \
	        -textvariable ::moni::M(TEST_VER)}
        place $win.labf.label12 \
            -in $win.labf  -x 10 -y 280 -width 100 -height 20
        place $win.entry8 \
            -in $win.labf  -x 120 -y 280 -width 260 -height 20

    } else {
        place $win.labf \
            -in $win -x 70 -y 80 -width 400 -height 130 -anchor nw \
            -bordermode ignore
    }


    set bbox [ButtonBox $win.bbox -spacing 10 -padx 1 -pady 1]

    $bbox add -text "Confirm" -font { 宋体 12 normal } -width 10 -fg brown \
        -helptext "Confirm" \
        -command {::moni::confirm_test_set} \
        -highlightthickness 0 -takefocus 0 -borderwidth 2 -padx 4 -pady 4

    if {$::moni::M(Manufactory) == "01"} {
        BWidget::place $win 450 550 center
        place $win.bbox -in $win -x 175 -y 500 -width 100 -height 36 \
        -anchor nw -bordermode ignore
    } else {
        place $win.bbox -in .testSetDlg -x 175 -y 230 -width 100 -height 36 \
            -anchor nw -bordermode ignore
    }

    grab .testSetDlg
    focus -force .testSetDlg

    if {$::moni::M(TestType) == "F/T"} {
        $win.entry1 configure -state disabled
    }

    #::moni::modproducer
    ::moni::initboardtype
    ::moni::inithwinfo
}

proc moni::inithwinfo {} {

    if {$::moni::M(Producer) == "SCC"} {
        .testSetDlg.labf.combl2 configure -values {CPU8245 DCRS-5950 DCRS-7600 DCRS-6800 DCRS-9800}
    } elseif {$::moni::M(Producer) == "01"} {
        .testSetDlg.labf.combl2 configure -values {CPU8245 ES4600 EM4700 DCRS-9800}
    } elseif {$::moni::M(Producer) == "59"} {
        .testSetDlg.labf.combl2 configure -values {GX-6504}
    } elseif {$::moni::M(Producer) == "60"} {
        .testSetDlg.labf.combl2 configure -values {"TiNet S6808"}
    } elseif {$::moni::M(Producer) == "RUN"} {
        .testSetDlg.labf.combl2 configure -values {"RUN"}
    }

    if {$::moni::M(Manufactory) == "01"} {
        BWidget::place .testSetDlg 550 550 center
        place .testSetDlg.bbox -in .testSetDlg -x 200 -y 480 -width 100 -height 36 \
        -anchor nw -bordermode ignore
        place .testSetDlg.labf \
            -in .testSetDlg -x 70 -y 80 -width 400 -height 320 -anchor nw \
            -bordermode ignore

        catch {Label .testSetDlg.labf.label6 -text "LINE:" -font { 宋体 12 normal } -fg blue \
            -width 15 -anchor w  -helptext "LINE"}
        catch {Entry .testSetDlg.entry2 -background white -width 25 -state normal \
	        -textvariable ::moni::M(LINE)}
        place .testSetDlg.labf.label6 \
            -in .testSetDlg.labf  -x 10 -y 40 -width 100 -height 20
        place .testSetDlg.entry2 \
            -in .testSetDlg.labf  -x 120 -y 40 -width 260 -height 20

        catch {Label .testSetDlg.labf.label7 -text "SHIFT:" -font { 宋体 12 normal } -fg blue \
            -width 15 -anchor w  -helptext "SHIFT"}
        catch {Entry .testSetDlg.entry3 -background white -width 25 -state normal \
	        -textvariable ::moni::M(SHIFT)}
        place .testSetDlg.labf.label7 \
            -in .testSetDlg.labf  -x 10 -y 80 -width 100 -height 20
        place .testSetDlg.entry3 \
            -in .testSetDlg.labf  -x 120 -y 80 -width 260 -height 20

        catch {Label .testSetDlg.labf.label8 -text "WS_ID:" -font { 宋体 12 normal } -fg blue \
            -width 15 -anchor w  -helptext "WS_ID"}
        catch {Entry .testSetDlg.entry4 -background white -width 25 -state normal \
	        -textvariable ::moni::M(WS_ID)}
        place .testSetDlg.labf.label8 \
            -in .testSetDlg.labf  -x 10 -y 120 -width 100 -height 20
        place .testSetDlg.entry4 \
            -in .testSetDlg.labf  -x 120 -y 120 -width 260 -height 20

        catch {Label .testSetDlg.labf.label9 -text "OPERATOR:" -font { 宋体 12 normal } -fg blue \
            -width 15 -anchor w  -helptext "OPERATOR"}
        catch {Entry .testSetDlg.entry5 -background white -width 25 -state normal \
	        -textvariable ::moni::M(OPERATOR)}
        place .testSetDlg.labf.label9 \
            -in .testSetDlg.labf  -x 10 -y 160 -width 100 -height 20
        place .testSetDlg.entry5 \
            -in .testSetDlg.labf  -x 120 -y 160 -width 260 -height 20

        catch {Label .testSetDlg.labf.label10 -text "RACK:" -font { 宋体 12 normal } -fg blue \
            -width 15 -anchor w  -helptext "RACK"}
        catch {Entry .testSetDlg.entry6 -background white -width 25 -state normal \
	        -textvariable ::moni::M(RACK)}
        place .testSetDlg.labf.label10 \
            -in .testSetDlg.labf  -x 10 -y 200 -width 100 -height 20
        place .testSetDlg.entry6 \
            -in .testSetDlg.labf  -x 120 -y 200 -width 260 -height 20

        catch {Label .testSetDlg.labf.label11 -text "LOT_NO:" -font { 宋体 12 normal } -fg blue \
            -width 15 -anchor w  -helptext "LOT_NO"}
        catch {Entry .testSetDlg.entry7 -background white -width 25 -state normal \
	        -textvariable ::moni::M(LOT_NO)}
        place .testSetDlg.labf.label11 \
            -in .testSetDlg.labf  -x 10 -y 240 -width 100 -height 20
        place .testSetDlg.entry7 \
            -in .testSetDlg.labf  -x 120 -y 240 -width 260 -height 20

        catch {Label .testSetDlg.labf.label12 -text "TEST VERSION:" -font { 宋体 12 normal } -fg blue \
            -width 15 -anchor w  -helptext "TEST VERSION"}
        catch {Entry .testSetDlg.entry8 -background white -width 25 -state normal \
	        -textvariable ::moni::M(TEST_VER)}
        place .testSetDlg.labf.label12 \
            -in .testSetDlg.labf  -x 10 -y 280 -width 100 -height 20
        place .testSetDlg.entry8 \
            -in .testSetDlg.labf  -x 120 -y 280 -width 260 -height 20
    } else {
        BWidget::place .testSetDlg 550 280 center
        place .testSetDlg.bbox -in .testSetDlg -x 210 -y 230 -width 100 -height 36 \
        -anchor nw -bordermode ignore
        place .testSetDlg.labf \
            -in .testSetDlg -x 70 -y 80 -width 400 -height 130 -anchor nw \
            -bordermode ignore

        catch {destroy .testSetDlg.labf.label6}
        catch {destroy .testSetDlg.labf.label7}
        catch {destroy .testSetDlg.labf.label8}
        catch {destroy .testSetDlg.labf.label9}
        catch {destroy .testSetDlg.labf.label10}
        catch {destroy .testSetDlg.labf.label11}
        catch {destroy .testSetDlg.labf.label12}
        catch {destroy .testSetDlg.entry2}
        catch {destroy .testSetDlg.entry3}
        catch {destroy .testSetDlg.entry4}
        catch {destroy .testSetDlg.entry5}
        catch {destroy .testSetDlg.entry6}
        catch {destroy .testSetDlg.entry7}
        catch {destroy .testSetDlg.entry8}
    }
}

proc moni::modproducer {} {
    #.testSetDlg.labf.combl2 configure -text {}
    set moni::M(ProductType) ""
    set moni::M(BoardType) ""

    moni::inithwinfo
}

proc moni::modptype {} {

    set moni::M(BoardType) ""
    moni::initboardtype
}

proc moni::initboardtype {} {
#/* BEGIN: Modified by yueql, 2010/09/13 增加RS-9800-24GB-V-CO MRS-9800-24GT-V-CO */
#/* BEGIN: Modified by jianghtc, 2010/02/02 任务[40999] */
#/* BEGIN: Modified by jianghtc, 2010/01/26 任务[40676] */
    set pstr "MRS-7600-48GT MRS-6800-48GT F0S007600016H-48GB(R4) F0P007608004H-7608E(R2) F1P006808004H-6808E(R2)
              DCRS-9808(R3)-CO DCRS-9816(R3)-CO MRS-9800-24GB-CO MRS-9800-24GT-CO
              MRS-9800-24GB-V-CO MRS-9800-24GT-V-CO MRS-9800-MI-CO MRS-9808-M(R3)-CO
              F0S007600010H-2XFP12GX12GB-CO F0S007600011H-12GX12GB-CO F0S007604006H-M1XFP12GX12GB-CO
              F0S007608002H-M2-CO F0S007600012H-2XFP24GB12GT-CO DCRS-7600-24GB12GT(R3)-FLF-CO
              MRS-9800-4XFP(R3)-CO MRS-9800-24SFP-PLUS F0S007604013H-M1XFP12GX12GT(R4) F0S007608005H-MRS-7608-MI(R4)
              F0S007600015H-12GX12GT(R4) F0S007600014H-2XFP12GX12GT(R4) DCRS-5950-24 DCRS-5950-26 ES4624-SFP ES4626-SFP
              MRS-7600E-2XFP24GB12GT(R2) MRS-7600E-24GB12GT(R2) MRS-6800E-2XFP24GB12GT(R2) MRS-6800E-24GB12GT(R2)"
#/* END:   Modified by jianghtc, 2010/01/26 任务[40676] */
#/* END:   Modified by jianghtc, 2010/02/02 任务[40999] */
#/* END: Modified by yueql, 2010/09/13 增加RS-9800-24GB-V-CO MRS-9800-24GT-V-CO */
		.testSetDlg.labf.combl3 configure -values $pstr

}

proc moni::confirm_test_set {} {
#    savelog $::moni::M(HWVersion)
#    savelog $::moni::M(ProductType)
    #::moni::save_test_variable $::moni::M(HWVersion) "hardwareversion:" $::moni::M(HWVersion)
    ::moni::save_test_variable $::moni::M(Producer) "producer:" $::moni::M(Producer)
    #::moni::save_test_variable $::moni::M(BoardType) "boardtype:" $::moni::M(BoardType)
#先根据板卡类型获取产品类型再写入config.ini文件
    ::moni::get_producttype
    ::moni::save_test_variable $::moni::M(ProductType) "producttype:" $::moni::M(ProductType)

    if {$::moni::M(Manufactory) == "01"} {
        ::moni::save_test_variable $::moni::M(BoardType) "line:" $::moni::M(LINE)
        ::moni::save_test_variable $::moni::M(BoardType) "shift:" $::moni::M(SHIFT)
        ::moni::save_test_variable $::moni::M(BoardType) "ws_id:" $::moni::M(WS_ID)
        ::moni::save_test_variable $::moni::M(BoardType) "operator:" $::moni::M(OPERATOR)
        ::moni::save_test_variable $::moni::M(BoardType) "rack:" $::moni::M(RACK)
        ::moni::save_test_variable $::moni::M(BoardType) "lot_no:" $::moni::M(LOT_NO)

        #if {$::moni::M(WS_ID) == "P/T"} {
        #    set ::moni::M(TestType) "P/T"
        #} elseif {$::moni::M(WS_ID) == "F/T"} {
        #    set ::moni::M(TestType) "F/T"
        #}
        moni::confirm_testtype_set
    }

    ::moni::get_boardtypenum

    if {$::moni::M(BoardTypeNum) == 5 || $::moni::M(BoardTypeNum) == 69} {
        moni::first_test_select
    }
    destroy .testSetDlg
    update

}

################################################################################
#                              < 测试类别 >

proc moni::set_sort {} {
    if {$::moni::M(Manufactory) == "01"} {
        return
    }
    toplevel .testSortDlg

    wm withdraw .testSortDlg
    update
    BWidget::place .testSortDlg 300 200 center
    wm transient .testSortDlg .
    wm title     .testSortDlg "Select Test Type"
    wm deiconify .testSortDlg
    wm resizable .testSortDlg 0 0

    set win .testSortDlg

    LabelFrame $win.labf \
        -text TestType -font { 宋体 10 normal } -bg LightBlue -fg black  -side top \
                   -anchor w -relief groove -borderwidth 1

    place $win.labf \
        -in $win -x 50 -y 25 -width 200 -height 100 -anchor nw \
        -bordermode ignore

	set rad1 [radiobutton $win.labf.rad1 -text "P/T" \
	    -command {moni::first_test_select} \
	    -font { 宋体 12 normal } -bg LightBlue -fg blue -value en ]

    place $win.labf.rad1 \
        -in $win.labf -x 30 -y 30 -width 120 -height 30 -anchor nw \
        -bordermode ignore


    set rad2 [radiobutton $win.labf.rad2 -text "F/T" \
        -command {moni::last_test_select} \
        -font { 宋体 12 normal } -bg LightBlue -fg blue -value fr]

    place $win.labf.rad2 \
        -in $win.labf -x 30 -y 60 -width 120 -height 30 -anchor nw \
        -bordermode ignore

    set bbox [ButtonBox $win.bbox -spacing 10 -padx 1 -pady 1]

    $bbox add -text "Close" -font { 宋体 12 normal } -fg brown -width 10 -height 1 \
        -command {::moni::confirm_testtype_set} \
        -highlightthickness 0 -takefocus 0 -borderwidth 2 -padx 4 -pady 1
    if {$::moni::M(TestType) == "P/T"} {
        $win.labf.rad1 select
    } elseif {$::moni::M(TestType) == "F/T"} {
        $win.labf.rad2 select
    }
    place $win.bbox -in .testSortDlg -x 100 -y 140 -width 100 -height 36 \
        -anchor nw -bordermode ignore

    grab .testSortDlg
    focus -force .testSortDlg
}

proc moni::first_test_select {} {
    set testtype "P/T"
    set ::moni::M(TestType) $testtype
    moni::save_test_variable $::moni::M(TestType) "testtype:" $::moni::M(TestType)
}

proc moni::last_test_select {} {
    # CPU扣板只有初次测试
    #BEGIN: Modified by jianghtc, 2010/02/24 bug[41301],背板只有初测
    if {$::moni::M(BoardTypeNum) == 5 || $::moni::M(BoardTypeNum) == 69 \
    || $::moni::M(BoardTypeNum) == 9|| $::moni::M(BoardTypeNum) == 73} {
        moni::first_test_select
    } else {
        set testtype "F/T"
        set ::moni::M(TestType) $testtype
        moni::save_test_variable $::moni::M(TestType) "testtype:" $::moni::M(TestType)
    }
    #END:   Modified by jianghtc, 2010/02/24 bug[41301]
}

proc moni::confirm_testtype_set {} {
    ::moni::save_test_variable $::moni::M(TestType) "testtype:" $::moni::M(TestType)
#    savelog "::moni::M(TestType) = $::moni::M(TestType)\n"
    destroy .testSortDlg
    update

}

proc moni::save_test_variable { name head value } {
    set name $value

    set file [open config.ini r]
    set filestr ""
    set newfilestr ""
    set enter \x0A
    set sp "*"
    while {[gets $file line] >= 0} {
        set filestr $filestr$line$enter
    }
    set len [string length $filestr]
    set startpos [string first $head $filestr 0]
    set endpos [string first $enter $filestr $startpos]
    set newfilestr [string range $filestr 0 [expr {$startpos-1}]]
    set newfilestr $newfilestr$head$sp$value$sp
    set strafterenter [string range $filestr $endpos $len]
    set newfilestr $newfilestr$strafterenter

    close $file

    set file [open config.ini w]
    puts -nonewline $file $newfilestr
    close $file
}

################################################################################
#                            < 开始测试 设置MAC >

proc moni::set_mac {} {
    variable M

    #wm withdraw .       ;#隐藏
    wm deiconify .      ;#显现
    #wm state . iconic

    #CPU板只有初测
    if {$::moni::M(BoardTypeNum) == 5 || $::moni::M(BoardTypeNum) == 69} {
        moni::first_test_select
    }


        ::moni::get_boardtypenum
		
	#增加FT还是PT的判断，如果是PT，则不弹出输入MAC、SN、PN、LICENSE的框直接测试
	 if {$::moni::M(TestType) == "P/T"} {

            if {$::moni::M(Producer) == "SCC"} {
                set mac_strs "Input a mac address!"
            } 

            set M(TestItem) "set_mac"
            ::moni::paraComDlgCreate $moni::MSG(set_mac_dlg_title) $mac_strs 
    } elseif {$::moni::M(TestType) == "F/T"} {
        
		if {$::moni::M(Producer) == "SCC"} {
                set mac_strs "Input a mac address!"
            } 

		set M(TestItem) "set_mac"
		::moni::paraComDlgCreate $moni::MSG(set_mac_dlg_title) $mac_strs    
	}
    #tk_messageBox -message "moni::set_mac $::moni::M(BoardType) $::moni::M(BoardTypeNum)"
}

proc moni::exit_set_mac {} {
    catch { destroy .paraCommonDlg }
    wm deiconify .      ;#显现
    update
}

proc moni::check_mac {} {
    if {[string length $::moni::M(MacVlan)] != 12} {
        tk_messageBox -message "$moni::MSG(check_mac_msg)"
        return
    }
    for {set i 0} {$i<12} {incr i} {
        set digit [string range $::moni::M(MacVlan) $i $i]
        binary scan $digit "c" charout
        format "%#d" $charout
        set isdigit1 [expr {[expr {$charout >= 48}] && [expr {$charout <= 57}]}]
        set isdigit2 [expr {[expr {$charout >= 65}] && [expr {$charout <= 70}]}]
        set isdigit3 [expr {[expr {$charout >= 97}] && [expr {$charout <= 102}]}]
        if {$isdigit1 || $isdigit2 || $isdigit3} {
            if {$::moni::M(Producer) == "SCC" || $::moni::M(Producer) == "RUN"} {
			
				#根据6063fd修改
               #if {[expr {[expr {$i == 0}] || [expr {$i == 2}]}] && [expr {$charout != 54}]} {

                #    tk_messageBox -message "$moni::MSG(check_mac_msg)"
                 #   return
                #} elseif {[expr {$i == 1}] && [expr {$charout != 48}]} {
                 #   tk_messageBox -message "$moni::MSG(check_mac_msg)"
                 #   return
                #} elseif {[expr {$i == 3}] && [expr {$charout != 51}]} {
                 #   tk_messageBox -message "$moni::MSG(check_mac_msg)"
                  #  return
                #} elseif {[expr {$i == 4}] && [expr {[expr {$charout != 70}] && [expr {$charout != 102}]}]} {
                 #   tk_messageBox -message "$moni::MSG(check_mac_msg)"
                 #   return
                #} elseif {[expr {$i == 5}] && [expr {[expr {$charout != 68}] && [expr {$charout != 100}]}]} {
                #    tk_messageBox -message "$moni::MSG(check_mac_msg)"
                 #   return
                #}			
            #    if {[expr {[expr {$i == 0}] || [expr {$i == 1}] || [expr {$i == 2}]
            #        || [expr {$i == 4}]}] && [expr {$charout != 48}]} {

            #        tk_messageBox -message "$moni::MSG(check_mac_msg)"
            #        return
            #    } elseif {[expr {$i == 3}] && [expr {$charout != 51}]} {
            #        tk_messageBox -message "$moni::MSG(check_mac_msg)"
            #        return
            #    } elseif {[expr {$i == 5}] && [expr {[expr {$charout != 70}] && [expr {$charout != 102}]}]} {
            #        tk_messageBox -message "$moni::MSG(check_mac_msg)"
            #        return
            #    }
            } elseif {$::moni::M(Producer) == "01"} {
                #for 01
                if {[expr {[expr {$i == 0}] || [expr {$i == 1}]}] && [expr {$charout != 48}]} {
                    tk_messageBox -message "$moni::MSG(check_mac_msg)"
                    return
                } elseif {[expr {$i == 2}] && [expr {$charout != 49}]} {
                    tk_messageBox -message "$moni::MSG(check_mac_msg)"
                    return
                } elseif {[expr {$i == 3}] && [expr {$charout != 50}]} {
                    tk_messageBox -message "$moni::MSG(check_mac_msg)"
                    return
                } elseif {[expr {$i == 4}] && [expr {[expr {$charout != 67}] && [expr {$charout != 99}]}]} {
                    tk_messageBox -message "$moni::MSG(check_mac_msg)"
                    return
                } elseif {[expr {$i == 5}] && [expr {[expr {$charout != 70}] && [expr {$charout != 102}]}]} {
                    tk_messageBox -message "$moni::MSG(check_mac_msg)"
                    return
                }
            }
        } elseif {$::moni::M(Producer) == "59"} {

        } elseif {$::moni::M(Producer) == "60"} {

        } elseif {$::moni::M(Producer) == "RUN"} {

        } else {
            tk_messageBox -message "$moni::MSG(check_mac_msg)"
            return
        }
    }
    if {$::moni::M(Manufactory) == "01"} {
        set moni::M(MAC_ID) $::moni::M(MacVlan)
    }
    ::moni::set_sn
	
}

################################################################################
#                                  < 设置SN >

proc moni::set_sn {} {
    variable M

    set M(TestItem) "set_sn"
    ::moni::paraComDlgCreate $moni::MSG(set_sn_dlg_title) $moni::MSG(set_sn_dlg_text)

}

proc moni::exit_set_sn {} {
    catch { destroy .paraCommonDlg }
    wm deiconify .      ;#显现
    update
}

proc moni::check_sn {} {
#由于各厂家支持的sn不同，而sn在工厂都是扫描，不会出错，所以去掉此判断
    #if {[string length $::moni::M(SN)] == 10} {
   #     set digit [string range $::moni::M(SN) 0 0]
     #   if {$::moni::M(Producer) == "SCC"} {
     #       if {$digit != "N"} {
     #           tk_messageBox -message "$moni::MSG(check_sn_msg)"
     #           return
     #       }
     #   } elseif {$::moni::M(Producer) == "01"} {
     #       if {$digit != "A"} {
     #           tk_messageBox -message "$moni::MSG(check_sn_msg)"
     #           return
     #       }
     #   }
     #   for {set i 1} {$i<10} {incr i} {
     #       set digit [string range $::moni::M(SN) $i $i]
     #       binary scan $digit "c" charout
     #       format "%#d" $charout
     #       set isdigit [expr {[expr {$charout >= 48}] && [expr {$charout <= 57}]}]
     #       set ischars [expr {[expr {$charout >= 65}] && [expr {$charout <= 90}]}]
     #       set ischarb [expr {[expr {$charout >= 97}] && [expr {$charout <= 122}]}]

     #       if {$isdigit == 0 && $ischars == 0 && $ischarb == 0} {
     #           tk_messageBox -message "$moni::MSG(check_sn_msg)"
     #           return
     #       }
     #   }
   # } elseif {[string length $::moni::M(SN)] == 18} {
     #   set sn [string range $::moni::M(SN) 9 17]
     #   for {set i 0} {$i<9} {incr i} {
     #       set digit [string range $sn $i $i]
     #       binary scan $digit "c" charout
     #       format "%#d" $charout
     #       set isdigit [expr {[expr {$charout >= 48}] && [expr {$charout <= 57}]}]

     #       if {$isdigit == 0} {
     #           tk_messageBox -message "$moni::MSG(check_sn_msg)"
     #           return
     #       }
     #   }
     #   set ::moni::M(SN) N$sn
   # } else {
     #   tk_messageBox -message "$moni::MSG(check_sn_msg)"
     #   return
    #}

    if {[string length $::moni::M(SN)] != 18} {
        tk_messageBox -message "$moni::MSG(check_sn_msg)"
        return
    }

    #::moni::start_main_board_test
	::moni::set_pn
}

proc moni::check_sn_retest {} {
    if {[string length $::moni::M(SN)] == 10} {
        set digit [string range $::moni::M(SN) 0 0]
        if {$::moni::M(Producer) == "SCC"} {
            if {$digit != "N"} {
                tk_messageBox -message "$moni::MSG(check_sn_retest_msg)"
                exit
            }
        } elseif {$::moni::M(Producer) == "01"} {
            if {$digit != "A"} {
                tk_messageBox -message "$moni::MSG(check_sn_retest_msg)"
                exit
            }
        }
    } else {
        tk_messageBox -message "$moni::MSG(check_sn_msg)"
        exit
    }
}

################################################################################
#                                  < 设置PN >

proc moni::set_pn {} {
    variable M

    set M(TestItem) "set_pn"
    ::moni::paraComDlgCreate $moni::MSG(set_pn_dlg_title) $moni::MSG(set_pn_dlg_text)

}

proc moni::exit_set_pn {} {
    catch { destroy .paraCommonDlg }
    wm deiconify .      ;#显现
    update
}

proc moni::check_pn {} {
    if {[string length $::moni::M(PN)] != 18} {
        tk_messageBox -message "$moni::MSG(check_pn_msg)"
        return
    }
	
	if { 0 == [::moni::atem_license_is_support] } {
		if {$::moni::M(TestType) == "P/T" } {
			::moni::set_license
			return
		}
	}

	::moni::start_main_board_test
}

proc moni::check_pn_retest {} {
    if {[string length $::moni::M(PN)] == 10} {
        set digit [string range $::moni::M(PN) 0 0]
        if {$::moni::M(Producer) == "SCC"} {
            if {$digit != "N"} {
                tk_messageBox -message "$moni::MSG(check_pn_retest_msg)"
                exit
            }
        } elseif {$::moni::M(Producer) == "01"} {
            if {$digit != "A"} {
                tk_messageBox -message "$moni::MSG(check_pn_retest_msg)"
                exit
            }
        }
    } else {
        tk_messageBox -message "$moni::MSG(check_pn_msg)"
        exit
    }
}


################################################################################
#                                  < 设置LICENSE >

proc moni::set_license {} {
    variable M

    set M(TestItem) "set_license"
    ::moni::paraComDlgCreate $moni::MSG(set_license_dlg_title) $moni::MSG(set_license_dlg_text)

}

proc moni::exit_set_license {} {
    catch { destroy .paraCommonDlg }
    wm deiconify .      ;#显现
    update
}

proc moni::check_license {} {
    if {[string length $::moni::M(LICENSE)] < 1} {
        tk_messageBox -message "$moni::MSG(check_license_msg)"
        return
    }

    ::moni::start_main_board_test
}

proc moni::check_license_retest {} {
    if {[string length $::moni::M(LICENSE)] == 10} {
        set digit [string range $::moni::M(LICENSE) 0 0]
        if {$::moni::M(Producer) == "SCC"} {
            if {$digit != "N"} {
                tk_messageBox -message "$moni::MSG(check_license_retest_msg)"
                exit
            }
        } elseif {$::moni::M(Producer) == "01"} {
            if {$digit != "A"} {
                tk_messageBox -message "$moni::MSG(check_license_retest_msg)"
                exit
            }
        }
    } else {
        tk_messageBox -message "$moni::MSG(check_license_msg)"
        exit
    }
}


################################################################################
#                               < 显示测试信息 >

proc moni::show_test_info_dlg {} {
    variable M
    catch { destroy .testInfoDlg }
    toplevel .testInfoDlg

    wm withdraw .testInfoDlg
#    wm state . iconic
    update
#    BWidget::place .testInfoDlg 600 480 at 0 0
    BWidget::place .testInfoDlg [winfo screenwidth .] [expr {[winfo screenheight .]-50}] at 0 0
#    wm transient .testInfoDlg .
    wm title     .testInfoDlg "$moni::MSG(show_test_info_dlg_title)   $moni::M(TEST_VER)"
    wm deiconify .testInfoDlg
    wm resizable .testInfoDlg 0 0


    set win .testInfoDlg

    set labellogo [Label $win.labellogo -image [bitmap DCLOGO]]
    place $labellogo \
        -in $win -x 10 -y 10 -width 200 -height 80 -anchor nw \
        -bordermode ignore

    labelframe $win.labf1 \
        -text configuration -font { 宋体 18 normal  bold} -borderwidth 3
    place $win.labf1 \
        -in $win -x 20 -y 90 -width [expr {[winfo screenwidth .]-40}] -height 120 -anchor nw \
        -bordermode ignore

    set label01 [Label $win.labf1.label1 -text "$moni::MSG(show_test_info_dlg_config_lab1)" -anchor w \
        -font { 宋体 14 normal } -fg black ]
    set label02 [Label $win.labf1.label2 -text $::moni::M(MacVlan) -anchor w \
        -font { 宋体 14 normal } -fg blue ]
    place $label01 \
        -in $win.labf1 -x [expr {[winfo screenwidth .]*1/30}] -y 40 -width 200 -height 20 -anchor nw \
        -bordermode ignore
    place $label02 \
        -in $win.labf1 -x [expr {[winfo screenwidth .]*5/30}] -y 40 -width 150 -height 20 -anchor nw \
        -bordermode ignore

    set label03 [Label $win.labf1.label3 -text "$moni::MSG(show_test_info_dlg_config_lab2)" -anchor w \
        -font { 宋体 14 normal } -fg black ]
    set label04 [Label $win.labf1.label4 -text $::moni::M(SN) -anchor w \
        -font { 宋体 14 normal } -fg blue ]
    place $label03 \
        -in $win.labf1 -x [expr {[winfo screenwidth .]*9.5/30}] -y 40 -width 40 -height 20 -anchor nw \
        -bordermode ignore
    place $label04 \
        -in $win.labf1 -x [expr {[winfo screenwidth .]*11/30}] -y 40 -width 250 -height 20 -anchor nw \
        -bordermode ignore

    set label05 [Label $win.labf1.label5 -text "$moni::MSG(show_test_info_dlg_config_lab3)" -anchor w \
        -font { 宋体 14 normal } -fg black ]
    set label06 [Label $win.labf1.label6 -text $::moni::M(TestType) -anchor w \
        -font { 宋体 14 normal } -fg blue ]
    place $label05 \
        -in $win.labf1 -x [expr {[winfo screenwidth .]*18/30}] -y 40 -width 100 -height 20 -anchor nw \
        -bordermode ignore
    place $label06 \
        -in $win.labf1 -x [expr {[winfo screenwidth .]*21/30}] -y 40 -width 150 -height 20 -anchor nw \
        -bordermode ignore

    set label07 [Label $win.labf1.label7 -text "$moni::MSG(show_test_info_dlg_config_lab4)" -anchor w \
        -font { 宋体 14 normal } -fg black ]
    set label08 [Label $win.labf1.label8 -text $::moni::M(HWVersion) -anchor w \
        -font { 宋体 14 normal } -fg blue ]
    place $label07 \
        -in $win.labf1 -x [expr {[winfo screenwidth .]*1/30}] -y 80 -width 200 -height 20 -anchor nw \
        -bordermode ignore
    place $label08 \
        -in $win.labf1 -x [expr {[winfo screenwidth .]*5/30}] -y 80 -width 100 -height 20 -anchor nw \
        -bordermode ignore

    set label09 [Label $win.labf1.label9 -text "PN:" -anchor w \
        -font { 宋体 14 normal } -fg black ]
    set label10 [Label $win.labf1.label10 -text $::moni::M(PN) -anchor w \
        -font { 宋体 14 normal } -fg blue ]
    place $label09 \
        -in $win.labf1 -x [expr {[winfo screenwidth .]*9.5/30}] -y 80 -width 140 -height 20 -anchor nw \
        -bordermode ignore
    place $label10 \
        -in $win.labf1 -x [expr {[winfo screenwidth .]*11/30}] -y 80 -width 250 -height 20 -anchor nw \
        -bordermode ignore

    set label11 [Label $win.labf1.label11 -text "$moni::MSG(show_test_info_dlg_config_lab6)" -anchor w \
        -font { 宋体 14 normal } -fg black ]
    set label12 [Label $win.labf1.label12 -text $::moni::M(BoardType) -anchor w \
        -font { 宋体 14 normal } -fg blue ]
    place $label11 \
        -in $win.labf1 -x [expr {[winfo screenwidth .]*18/30}] -y 80 -width 200 -height 20 -anchor nw \
        -bordermode ignore
    place $label12 \
        -in $win.labf1 -x [expr {[winfo screenwidth .]*21/30}] -y 80 -width 360 -height 20 -anchor nw \
        -bordermode ignore

    labelframe $win.labf2 \
        -text "$moni::MSG(show_test_info_dlg_process_frame)" -font { 宋体 18 normal bold} -borderwidth 3
    place $win.labf2 \
        -in $win -x 20 -y 200 -width [expr {[winfo screenwidth .]/2 + 20}] -height 500 -anchor nw \
        -bordermode ignore

    pack [ctext $win.labf2.t -bg black -fg green -insertbackground yellow \
         -yscrollcommand {.testInfoDlg.labf2.s set}] -fill both -expand 1
    place $win.labf2.t \
        -in $win.labf2 -x 5 -y 40 -width 690 -height 440 -anchor nw \
        -bordermode ignore


    pack [scrollbar $win.labf2.s -command {.testInfoDlg.labf2.t yview}] \
        -side right -fill y
    place $win.labf2.s \
        -in $win.labf2 -x 5 -y 40 -width 690 -height 440 -anchor nw \
        -bordermode ignore

#    .testInfoDlg.labf2.t yview 10000        ;#显示到10000行

    labelframe $win.labf3 \
        -text "$moni::MSG(show_test_info_dlg_result_frame)" -font { 宋体 18 normal bold} -borderwidth 3
    place $win.labf3 \
        -in $win -x [expr {[winfo screenwidth .]/2 + 60}] -y 200 -width [expr {[winfo screenwidth .]/2-80}] -height 500 -anchor nw \
        -bordermode ignore

    set label13 [Label $win.labf3.label1 -text "$moni::MSG(show_test_info_dlg_result_lab1)" -anchor w \
        -font { 宋体 14 normal } -fg black ]
    set label14 [Label $win.labf3.label2 -text $M(tested) \
        -font { 宋体 14 normal } -fg blue ]

    place $label13 \
        -in $win.labf3 -x [expr {[winfo screenwidth .]*1.2/8}] -y 80 -width 180 -height 20 -anchor nw \
        -bordermode ignore
    place $label14 \
        -in $win.labf3 -x [expr {[winfo screenwidth .]*2.2/8}] -y 80 -width 50 -height 20 -anchor nw \
        -bordermode ignore

    set label15 [Label $win.labf3.label3 -text "$moni::MSG(show_test_info_dlg_result_lab2)" -anchor w \
        -font { 宋体 14 normal } -fg black ]
    set label16 [Label $win.labf3.label4 -text $M(passed) \
        -font { 宋体 14 normal } -fg green ]

    place $label15 \
        -in $win.labf3 -x [expr {[winfo screenwidth .]*1.2/8}] -y 120 -width 180 -height 20 -anchor nw \
        -bordermode ignore
    place $label16 \
        -in $win.labf3 -x [expr {[winfo screenwidth .]*2.2/8}] -y 120 -width 50 -height 20 -anchor nw \
        -bordermode ignore

    set label17 [Label $win.labf3.label5 -text "$moni::MSG(show_test_info_dlg_result_lab3)" -anchor w \
        -font { 宋体 14 normal } -fg black ]
    set label18 [Label $win.labf3.label6 -text $M(failed) \
        -font { 宋体 20 normal } -fg red ]

    place $label17 \
        -in $win.labf3 -x [expr {[winfo screenwidth .]*1.2/8}] -y 160 -width 180 -height 20 -anchor nw \
        -bordermode ignore
    place $label18 \
        -in $win.labf3 -x [expr {[winfo screenwidth .]*2.2/8}] -y 160 -width 50 -height 20 -anchor nw \
        -bordermode ignore

    focus -force .testInfoDlg.labf2.t
}

proc moni::reinit {} {
#    ::moni::term_clear     ;#清空Notebook
    ::moni::close_serial

    ::moni::config_open_default
    ::moni::global_init
}

proc moni::new_test {} {
#    ::moni::term_clear     ;#清空Notebook
    catch {destroy .testInfoDlg}
    ::moni::close_serial
    ::moni::sn_init
    ::moni::global_init
    ::moni::config_open_default
}

################################################################################
#                                < 开始主板测试 >

proc moni::start_main_board_test {} {
    variable M
    variable Cfg
    set ::moni::M(FirstShowTestInfo) 0
    set ::moni::M(HandleString) 1

	set name $::moni::Cfg(name)
	set M(RecvBufAll.$name) ""
	
    #::moni::savelog $::moni::M(TestType)

    catch {destroy .paraCommonDlg}
    update

    if {$::moni::M(Manufactory) == "01"} {
        moni::create_request_file

        ::moni::comDlgCreate $moni::MSG(start_main_board_test_searchdlg_title) $moni::MSG(start_main_board_test_searchdlg_text)

        moni::search_response_file
        catch {destroy .commonDlg}

    }

    if {$::moni::M(BoardTypeNum) == 6 || $::moni::M(BoardTypeNum) == 70} {
        tk_messageBox -message "$moni::MSG(start_main_board_test_msg1)"
    } elseif {$::moni::M(BoardTypeNum) == 9 || $::moni::M(BoardTypeNum) == 73} {
        #/* BEGIN: Modified by jianghtc, 2010/01/26 任务[40676] */
        tk_messageBox -message "$moni::MSG(start_main_board_test_msg2)"
        #/* END:   Modified by jianghtc, 2010/01/26 任务[40676] */
    } elseif {$::moni::M(BoardTypeNum) == 199 || $::moni::M(BoardTypeNum) == 200} {
        tk_messageBox -message "$moni::MSG(start_main_board_test_msg3)"
    }

    ::moni::comDlgCreate $moni::MSG(start_main_board_test_testdlg_title) $moni::MSG(start_main_board_test_testdlg_lab1)

    #if {$::moni::M(TestType) == "板卡初次测试" } {
    ::moni::get_time
    ::moni::savelog "Time begin：$::moni::M(Time)\n"
    ::moni::saveerrlog "Time end：$::moni::M(Time)\n"
    #}

    ::moni::wait_ram      ;#检测"Testing RAM..."

    if {$::moni::M(GetRam) == 1} {
        set ::moni::M(GetRam) 0
        ::moni::send $::moni::Cfg(name) "\x02"  ;#Ctrl+B 进入boot.rom
        ::moni::send $::moni::Cfg(name) "\x02"
        ::moni::send $::moni::Cfg(name) "\x02"

        ::moni::wait 3000
        #换行
        ::moni::send $::moni::Cfg(name) "\x0A"
        set ::moni::M(GetBoot) 0

        ::moni::wait_boot     ;#检测"[Boot]:"
    } else {
        return
    }

    if {$::moni::M(GetBoot) == 1} {
        if {$::moni::M(TestType) == "F/T" } {
                ::moni::wait 1000
                set name $::moni::Cfg(name)
			if { 1 == [::moni::atem_license_is_support] } {
				::moni::send $::moni::Cfg(name) "showatemsn\r"
				if { [::moni::wait_string {atem sn:}] == 0 } {
					tk_messageBox -message "$moni::MSG(Invalid_atemsn_msg)" -icon error
					return;
				}

				set showatem [string first "showatemsn" $::moni::M(RecvBufAll.$name) 100]
				set index [string first "atem sn:" $::moni::M(RecvBufAll.$name) $showatem]
				set enter [string first "\x0A" $::moni::M(RecvBufAll.$name) $index]
				set atemsn [string range $::moni::M(RecvBufAll.$name) [expr {$index + 8}] [expr {$enter - 1}] ]

				set ::moni::M(ATEMSN) $atemsn
			}
				    
			::moni::send $::moni::Cfg(name) "show board\r"
			::moni::wait 500

			::moni::send $::moni::Cfg(name) "reboot\r"

			set ::moni::M(StartWaitRam) 1
			set ::moni::M(ExitWaitRam) 0
			set ::moni::M(GetRam) 0

			::moni::wait 20000   ;#需要等待串口发送完数据
			::moni::reinit       ;#2222222222222222

			::moni::wait_ram

			if {$::moni::M(GetRam) == 1} {
			  set ::moni::M(GetRam) 0

			  ::moni::send $::moni::Cfg(name) "\x14"  ;#Ctrl+T 进入img产测命令行 modified by duzqa131028
			  ::moni::wait 3000
			  ::moni::send $::moni::Cfg(name) "\x14"
			  ::moni::wait 3000
			  ::moni::send $::moni::Cfg(name) "\x14"
			  ::moni::wait 3000
			  ::moni::send $::moni::Cfg(name) "\x14"
			} else {
				return
			}
			::moni::wait 3000
				
			set ::moni::M(GetMantest) 0

			::moni::term_clear
			::moni::wait 3000
			
			::moni::wait_mantest

			if {$::moni::M(GetMantest) == 1} {
				set ::moni::M(GetMantest) 0
				
				#::moni::send $::moni::Cfg(name) "$::moni::M(USER)\r"
				#::moni::send $::moni::Cfg(name) "\x0A"
				#::moni::send $::moni::Cfg(name) $::moni::M(PASSWORD)
				::moni::send $::moni::Cfg(name) "\n"
				::moni::wait 1000
				set conname $::moni::Cfg(name)
				#set promptsChk [string first $::moni::M(PROMPTS) $::moni::M(RecvBufAll.$conname)]
				#if { $promptsChk >= 0 } {
				#	::moni::wait 100
				#} else {
				#	return
				#}	
				# ::moni::delete_mantestimg_and_log
				# ::moni::update_nosimg
				# return
				::moni::send $name "en\n"
				::moni::wait 2000
				::moni::send $::moni::Cfg(name) "terminal length 0"
				::moni::send $::moni::Cfg(name) "\n"
				::moni::wait 3000
				::moni::send $name "mantest portled normal\n"
				::moni::wait 100
				::moni::send $name "mantest log show\n"
				::moni::wait 2000

				::moni::check_AgingResult				;#检查老化测试是否OK,OK后才能进行复测
				if {$::moni::M(GetAgingResult) == 1} {
					set ::moni::M(GetAgingResult) 0
					if {[::moni::wait_RepeatTest] == 1	} {
						::moni::send $name "en\n"
						
						::moni::wait_PortLedTest
						#::moni::test_end
					}						

				} else {
					::moni::saveerrlog "Aging TEST ERROR"
					::moni::addtesterr
					::moni::get_result
					return
				}

			}									
        } elseif {$::moni::M(TestType) == "P/T" } {

		::moni::send $::moni::Cfg(name) "clear boardinfo\r"
		::moni::wait 1000
		::moni::send $::moni::Cfg(name) "y\r"
		::moni::wait 500
		::moni::send $::moni::Cfg(name) "settype sw\r"
		::moni::wait 500

		::moni::send $::moni::Cfg(name) "$::moni::M(BoardTypeNum)\r"						

		::moni::wait 500
		::moni::send $::moni::Cfg(name) "setver sw\r"
		::moni::wait 500
		::moni::send $::moni::Cfg(name) "$::moni::M(HWVersion)\r"
		
		::moni::wait 500
		::moni::send $::moni::Cfg(name) "setdate sw\r"
		::moni::wait 500
		::moni::send $::moni::Cfg(name) "$::moni::M(DATE)\r"
		::moni::wait 500
		::moni::send $::moni::Cfg(name) "setsn sw\r"
		::moni::wait 500				
		::moni::send $::moni::Cfg(name) "$::moni::M(SN)\r"				
		::moni::wait 500
		::moni::send $::moni::Cfg(name) "setpn sw\r"
		::moni::wait 500				
		::moni::send $::moni::Cfg(name) "$::moni::M(PN)\r"
		
		if {1 != [::moni::atem_license_is_support] } {
			::moni::wait 500									
			::moni::send $::moni::Cfg(name) "setlicense sw\r"
			::moni::wait 500				
			::moni::send $::moni::Cfg(name) "$::moni::M(LICENSE)\r"
		}

		if { $::moni::M(BoardType) == "S5750E-52X-SI" \
			|| $::moni::M(BoardType) == "CS6200-52X-EI" \
			|| $::moni::M(BoardType) == "S5750E-28X-P-SI" \
			|| $::moni::M(BoardType) == "S5750E-28X-SI" \
			|| $::moni::M(BoardType) == "S5750E-28C-SI" \
			|| $::moni::M(BoardType) == "CS6200-28X-P-EI" \
			|| $::moni::M(BoardType) == "CS6200-28X-EI" } {
			::moni::wait 500
			::moni::send_rtc
			::moni::wait 500
			::moni::send_show_rtc
		}

		::moni::wait 500
		::moni::send_mac

		if { $::moni::M(ErrorFound) == 1 } {
			return 
		}
		
		::moni::wait 3000
		::moni::send $::moni::Cfg(name) "show board\r"
		::moni::wait 500
		::moni::send $::moni::Cfg(name) "reboot\r"

                set ::moni::M(StartWaitRam) 1
                set ::moni::M(ExitWaitRam) 0
                set ::moni::M(GetRam) 0

				::moni::wait 20000   ;#需要等待串口发送完数据
                ::moni::reinit       ;#2222222222222222

                ::moni::wait_ram

                if {$::moni::M(GetRam) == 1} {
                  set ::moni::M(GetRam) 0

                  ::moni::send $::moni::Cfg(name) "\x14"  ;#Ctrl+T 进入img产测命令行 modified by duzqa131028
                  ::moni::wait 3000
                  ::moni::send $::moni::Cfg(name) "\x14"
                  ::moni::wait 3000
                  ::moni::send $::moni::Cfg(name) "\x14"
                  ::moni::wait 3000
                  ::moni::send $::moni::Cfg(name) "\x14"
                } else {
                    return
                }
                ::moni::wait 3000

                set ::moni::M(GetMantest) 0

                #::moni::send $::moni::Cfg(name) "\x0A"
                #::moni::send $::moni::Cfg(name) "\x0A"
                #::moni::send $::moni::Cfg(name) "\x0A"

                #::moni::wait_mantest   ;#检测"[manTest]:"		modified by duzqa131028
				::moni::wait 5000
				::moni::term_clear
				::moni::wait 3000
				::moni::wait_mantest

                if {$::moni::M(GetMantest) == 1} {
			set ::moni::M(GetMantest) 0
			   
			::moni::wait 1000
			set conname $::moni::Cfg(name)
			#set promptsChk [string first $::moni::M(PROMPTS) $::moni::M(RecvBufAll.$conname)]
			#if { $promptsChk >= 0 } {
			#	::moni::wait 100
			#} else {
			#	return
			#}
			::moni::send $::moni::Cfg(name) "en\r"
			::moni::send $::moni::Cfg(name) "terminal length 0"
			::moni::send $::moni::Cfg(name) "\n"
			::moni::send $name "boot img mantest.img primary\n"
			::moni::wait 2000

			if {[::moni::wait_FirstTest] == 1	} {
				::moni::wait_PortLedTest

				#::moni::wait_AgingTest
				
			}
					
                }
        }

    }
    return
}

#增加一个测试例
proc moni::wait_mem_check {} {
    variable M
    set i 0
    set ::moni::M(StartWaitRam) 1
    set name $::moni::Cfg(name)
    while {1} {
        catch { .testInfoDlg.labf2.t fastinsert end "." }
        catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行

        #设置内存强力检测超时为10分钟，ERROR CODE为T481
        ::moni::wait 1000
        set vRamChk [string first {Memory ok} $::moni::M(RecvBufAll.$name)]
        if {$vRamChk >= 0} {
            set ::moni::M(GetMemOk) 1
            ::moni::addtestok
            ::moni::savelog "$moni::MSG(wait_mem_check_ok_log)\n"
            catch { .testInfoDlg.labf2.t fastinsert end "\n$moni::MSG(wait_mem_check_ok_log)\n" }
            catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
            break
        }
        if {$i == $::moni::M(waitMemTime)} {
            set ::moni::M(ErrorFound) 1
            set ::moni::M(HandleString) 0
            moni::saveerrlog "$moni::MSG(wait_mem_check_fail_log)\n"
            moni::savelog "$moni::MSG(wait_mem_check_fail_log)\n"
            moni::addtesterr
            catch { .testInfoDlg.labf2.t fastinsert end "\n$moni::MSG(wait_mem_check_fail_log)\n" }
            catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
            #tk_messageBox -message "内存强力检测失败。"
            if {$::moni::M(Manufactory) == "01"} {
                set ::moni::M(ERROR_CODE) "T481"
    	    }
            ::moni::get_result
        	return
        }
        incr i
    }
}

proc moni::wait_ucode_download {} {
    variable M
    set i 0
    set name $::moni::Cfg(name)
    while {1} {
    	::moni::fastinsertend "test" "." 

        #设置微码烧录超时为3分钟，ERROR CODE为T479
        ::moni::wait 1000
        set vChkOk [string first {Firmware unicode downloading OK} $::moni::M(RecvBufAll.$name)]
        set vChkErr [string first {Firmware unicode downloading ERROR} $::moni::M(RecvBufAll.$name)]
        set vChkTryagain [string first {try again...} $::moni::M(RecvBufAll.$name)]
        
        if {$vChkOk >= 0} {
        	set ::moni::M(GetUcodeDownOK) 1
            catch { .testInfoDlg.labf2.t fastinsert end "\nFirmware unicode downloading OK\n" }
            catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
            break
        }        
        
        if {$vChkErr >= 0} {
        	#这里即使烧写报错也算烧写完成, 因为6个phy中可能不是全部都失败, 由后面的微码检测来找出具体哪个phy烧写失败
        	set ::moni::M(GetUcodeDownOK) 1
            catch { .testInfoDlg.labf2.t fastinsert end "\nFirmware unicode downloading ERROR\n" }
            catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
            break
        }  

        #如果检测到try again, 表示烧写微码发生了错误, 多延迟20秒.
        if {$vChkTryagain >= 0} {
        	if {$i > 20} {
        		set i [expr $i - 20]
        	} else {
        		set i 0
        	}        	
        }       

        #超时时间为200秒, 如果200秒无响应, 认为是烧写导致死机, 报错退出        
        if {$i == 200} {
            set ::moni::M(ErrorFound) 1
            set ::moni::M(HandleString) 0
            moni::saveerrlog "$moni::MSG(wait_ucode_download_timeout_log)\n"
            moni::savelog "$moni::MSG(wait_ucode_download_timeout_log)\n"
            moni::addtesterr
            catch { .testInfoDlg.labf2.t fastinsert end "\n$moni::MSG(wait_ucode_download_timeout_log)\n" }
            catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行        
            if {$::moni::M(Manufactory) == "01"} {
                set ::moni::M(ERROR_CODE) "T516"
    	    }
            ::moni::get_result
        	return            
        }
        incr i
    }
}

proc moni::wait_ram {} {
    variable M
    set i 0
    set ::moni::M(StartWaitRam) 1
    set ::moni::M(waitdot) 1
    set name $::moni::Cfg(name)
    set ::moni::M(GetRam) 0

    while {1} {
        #catch { .testInfoDlg.labf2.t fastinsert end "." }
        #catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
        ::moni::fastinsertend "test" "."
        ::moni::wait 10
        #set vRamChk [string first {Testing RAM...} $::moni::M(RecvBufAll.$name)]
        set vRamChk [string first {RAM} $::moni::M(RecvBufAll.$name)]
        if {$vRamChk >= 0} {
#        	  .testInfoDlg.labf2.t fastinsert end "get ram 111!!!\n"
#       	  ::moni::send $::moni::Cfg(name) "get ram 222!!!\r"
#            ::moni::savelog "get ram!!!\n"
            set ::moni::M(GetRam) 1
            set ::moni::M(waitdot) 0
            break
#            return
        } else {
            if {$::moni::M(ExitWaitRam) == 1} {
                set ::moni::M(ExitWaitRam) 0
                set ::moni::M(waitdot) 0
#                savelog "退出 wait_ram\n"
                break
#               return
            }
        }
        incr i

        #等待5分钟
        if { $i > $::moni::M(waitRamTime) * 100} {
            set ::moni::M(ErrorFound) 1
            ::moni::send $::moni::Cfg(name) "\x0A"
            moni::saveerrlog "Start DUT FAILED!"
            moni::savelog "Start DUT FAILED!"
            moni::addtesterr
            catch { .testInfoDlg.labf2.t fastinsert end "\nStart DUT FAILED!\n" }
            catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
            set ::moni::M(HandleString) 0
            if {$::moni::M(Manufactory) == "01" || $::moni::M(Manufactory) == "scc"} {
                set ::moni::M(HandleString) 0
                set ::moni::M(ERROR_CODE) "T479"
            }
            moni::get_result
            set ::moni::M(waitdot) 0
            return
        }
    }
}

proc moni::wait_power {} {
    variable M

    set name $::moni::Cfg(name)
    set ::moni::M(GetPower1) 0
    set ::moni::M(GetPower2) 0

    while {1} {
        #catch { .testInfoDlg.labf2.t fastinsert end "." }
        #catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
        ::moni::fastinsertend "test" "."
        ::moni::wait 500
        set vPowerIndexErr [string first {Presentation.........{T491}[ERROR]} $::moni::M(RecvBufAll.$name)]
        set vPowerStatusErr [string first {Status.........{T491}[ERROR]} $::moni::M(RecvBufAll.$name)]

        if {$vPowerIndexErr >= 0} {
            set ::moni::M(GetPower1) 1
        }

        if {$vPowerStatusErr >= 0} {
            set ::moni::M(GetPower2) 1
        }

        #tesk ok时退出
        break
    }
}

proc moni::wait_aging {} {
    variable M
    set i 0

    set name $::moni::Cfg(name)
    set ::moni::M(GetAging) 0

    while {1} {
        catch { .testInfoDlg.labf2.t fastinsert end "." }
        catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
        ::moni::wait 1000
        set vRamChkOK [string first {OK} $::moni::M(RecvBufAll.$name)]
        set vRamChkERR [string first {ERR} $::moni::M(RecvBufAll.$name)]

        if {$vRamChkOK >= 0} {
            set ::moni::M(GetAging) 0

            break
        } elseif {$vRamChkERR >= 0} {
            set ::moni::M(GetAging) 1
            break
        }
        incr i

        #等待5分钟
        if { $i > $::moni::M(waitAingTime) } {
            set ::moni::M(ErrorFound) 1
            ::moni::send $::moni::Cfg(name) "\x0A"
            moni::saveerrlog "$moni::MSG(wait_aging_errlog)"
            moni::savelog "$moni::MSG(wait_aging_errlog)"
            moni::addtesterr
            catch { .testInfoDlg.labf2.t fastinsert end "\n$moni::MSG(wait_aging_errlog)\n" }
            catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
            set ::moni::M(HandleString) 0
            if {$::moni::M(Manufactory) == "01" || $::moni::M(Manufactory) == "scc"} {
                set ::moni::M(HandleString) 0
                set ::moni::M(ERROR_CODE) "T479"
            }
            moni::get_result
            return
       }
    }
}
proc moni::wait_aging_detail {} {
    variable M
    set vRamChkPowerOnOff_times ""

    set name $::moni::Cfg(name)
    set ::moni::M(GetAgingDetail) 0

    while {1} {
        catch { .testInfoDlg.labf2.t fastinsert end "." }
        catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
        ::moni::wait 500

	#增加复测时老化通断电次数检验
        set vRamChkPowerOnOff_index [string first "Power on/off times:" $::moni::M(RecvBufAll.$name)]
        set enter1 [string first "\x0A" $::moni::M(RecvBufAll.$name) $vRamChkPowerOnOff_index]

        if {$vRamChkPowerOnOff_index>0  && $enter1>$vRamChkPowerOnOff_index} {
            set vRamChkPowerOnOff_times [string range $::moni::M(RecvBufAll.$name) [expr {$vRamChkPowerOnOff_index + 19}] [expr {$enter1 - 1}]]
            if {$vRamChkPowerOnOff_times < 10} {
	            set ::moni::M(GetAgingDetail) 1
		}
		return
        }
    }
}

proc moni::wait_watchdog_reboot {} {
    variable M
    set i 0
    set ::moni::M(StartWaitRam) 1
    set ::moni::M(waitdot) 1
    set name $::moni::Cfg(name)
    set ::moni::M(GetRam) 0

    while {1} {
        #catch { .testInfoDlg.labf2.t fastinsert end "." }
        #catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
        ::moni::fastinsertend "test" "."

        #set vRamChk [string first {Testing RAM...} $::moni::M(RecvBufAll.$name)]
        set vRamChk [string first {RAM} $::moni::M(RecvBufAll.$name)]
        if {$vRamChk >= 0} {
            set ::moni::M(GetRam) 1
            ::moni::addtestok
            ::moni::savelog "$moni::MSG(wait_watchdog_reboot_ok_log)\n"
            catch { .testInfoDlg.labf2.t fastinsert end "\n$moni::MSG(wait_watchdog_reboot_ok_log)\n" }
            catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
            set ::moni::M(waitdot) 0
            break
#            return
        } else {
            if {$::moni::M(ExitWaitRam) == 1} {
                set ::moni::M(ExitWaitRam) 0
                set ::moni::M(waitdot) 0
#                savelog "退出 wait_ram\n"
                break
#               return
            }
        }

        ::moni::wait 1000

        #设置启动watchodog重启超时为2分钟
        if {$i == $::moni::M(waitWatchdogTime)} {
            set ::moni::M(ErrorFound) 1
            set ::moni::M(HandleString) 0
            ::moni::send $::moni::Cfg(name) "\x0A"
            moni::saveerrlog "$moni::MSG(wait_watchdog_reboot_fail_log)"
            moni::savelog "$moni::MSG(wait_watchdog_reboot_fail_log)"
            moni::addtesterr
            catch { .testInfoDlg.labf2.t fastinsert end "\n$moni::MSG(wait_watchdog_reboot_fail_log)\n" }
            catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
            moni::get_result
            set ::moni::M(waitdot) 0
            return
        }
        incr i
    }
}


proc moni::wait_SNRnosimg {} {
    variable M
    set i 0
    set ::moni::M(StartWaitMantest) 1
    set ::moni::M(waitdot) 1
    set foundpasswd 0
    set name $::moni::Cfg(name)

    set switchname $::moni::M(BoardType)
    append switchname "#"

    while {1} {
        #catch { .testInfoDlg.labf2.t fastinsert end "." }
        #catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
        ::moni::fastinsertend "test" "."
        ::moni::wait 1000

	set vlicenseChk [string first {(license)>} $::moni::M(RecvBufAll.$name)]

	if { $vlicenseChk >= 0 } {
		tk_messageBox -message "$moni::MSG(check_atemlicense_msg)"
		set ::moni::M(ErrorFound) 1
		::moni::get_result
		break;
	}

	set vPasswdModChk [string first {Username} $::moni::M(RecvBufAll.$name)]

	if { $vPasswdModChk >= 0 && $foundpasswd != 1 } {
		::moni::send $::moni::Cfg(name) "admin\r"
		::moni::wait 1000
		::moni::send $::moni::Cfg(name) "admin\n"
		set foundpasswd 1
	}

        set vMantestModChk [string first $switchname $::moni::M(RecvBufAll.$name)]
      
        if { $vMantestModChk >= 0 } {
             set ::moni::M(GetMantest) 1
             set ::moni::M(waitdot) 0
             catch { .testInfoDlg.labf2.t fastinsert end "\n" }   ;#yueql
             break
        
        } else {
            if {$::moni::M(ExitWaitMantest) == 1} {
                set ::moni::M(ExitWaitMantest) 0
                set ::moni::M(waitdot) 0
                catch { .testInfoDlg.labf2.t fastinsert end "\n" }   ;#yueql
#                savelog "退出 wait_ram\n"
                break
#               return
            }
        }
				#设置启动mantest超时为3分钟
        if {$i == 300} {
            set ::moni::M(ErrorFound) 1
            set ::moni::M(HandleString) 0
            ::moni::send $::moni::Cfg(name) "\x0A"
            moni::saveerrlog "$moni::MSG(wait_nos_log)"
            moni::savelog "$moni::MSG(wait_nos_log)"
            moni::addtesterr
            catch { .testInfoDlg.labf2.t fastinsert end "\n$moni::MSG(wait_nos_log)\n" }
            catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
            set ::moni::M(HandleString) 0
            if {$::moni::M(Producer) == "01"} {
                set ::moni::M(HandleString) 0
                set ::moni::M(ERROR_CODE) "T479"
                ::moni::get_result
                set ::moni::M(waitdot) 0
                return
            }

            moni::get_result
            set ::moni::M(waitdot) 0
            return
        }
        incr i
    }
}

proc moni::wait_nosimg {} {
    variable M
    set i 0
    set ::moni::M(StartWaitMantest) 1
    set ::moni::M(waitdot) 1
    set name $::moni::Cfg(name)

    set switchname $::moni::M(BoardType)
    append switchname ">"

    while {1} {
        #catch { .testInfoDlg.labf2.t fastinsert end "." }
        #catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
        ::moni::fastinsertend "test" "."
        ::moni::wait 1000

	set vlicenseChk [string first {(license)>} $::moni::M(RecvBufAll.$name)]

	if { $vlicenseChk >= 0 } {
		tk_messageBox -message "$moni::MSG(check_atemlicense_msg)"
		set ::moni::M(ErrorFound) 1
		::moni::get_result
		break;
	}
        set vMantestModChk [string first $switchname $::moni::M(RecvBufAll.$name)]
        #set vNosModChk [string first {S4600} $::moni::M(RecvBufAll.$name)]
      
        if { $vMantestModChk >= 0 } {
             set ::moni::M(GetMantest) 1
             set ::moni::M(waitdot) 0
             catch { .testInfoDlg.labf2.t fastinsert end "\n" }   ;#yueql
             break
        
        } else {
            if {$::moni::M(ExitWaitMantest) == 1} {
                set ::moni::M(ExitWaitMantest) 0
                set ::moni::M(waitdot) 0
                catch { .testInfoDlg.labf2.t fastinsert end "\n" }   ;#yueql
#                savelog "退出 wait_ram\n"
                break
#               return
            }
        }
				#设置启动mantest超时为3分钟
        if {$i == 300} {
            set ::moni::M(ErrorFound) 1
            set ::moni::M(HandleString) 0
            ::moni::send $::moni::Cfg(name) "\x0A"
            moni::saveerrlog "$moni::MSG(wait_nos_log)"
            moni::savelog "$moni::MSG(wait_nos_log)"
            moni::addtesterr
            catch { .testInfoDlg.labf2.t fastinsert end "\n$moni::MSG(wait_nos_log)\n" }
            catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
            set ::moni::M(HandleString) 0
            if {$::moni::M(Producer) == "01"} {
                set ::moni::M(HandleString) 0
                set ::moni::M(ERROR_CODE) "T479"
                ::moni::get_result
                set ::moni::M(waitdot) 0
                return
            }

            moni::get_result
            set ::moni::M(waitdot) 0
            return
        }
        incr i
    }
}

proc moni::wait_mantest {} {
    variable M
    set i 0
    set ::moni::M(StartWaitMantest) 1
    set ::moni::M(waitdot) 1
    set name $::moni::Cfg(name)
    while {1} {
        #catch { .testInfoDlg.labf2.t fastinsert end "." }
        #catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
        ::moni::fastinsertend "test" "."
        ::moni::wait 1000

        #set vRamChk [string first {Testing RAM...} $::moni::M(RecvBufAll.$name)]
        set vMantestModChk [string first {Switch>} $::moni::M(RecvBufAll.$name)]
        #set vNosModChk [string first {S4600} $::moni::M(RecvBufAll.$name)]
      
        if { $vMantestModChk >= 0 } {
             set ::moni::M(GetMantest) 1
             set ::moni::M(waitdot) 0
             catch { .testInfoDlg.labf2.t fastinsert end "\n" }   ;#yueql
             break
        
        } else {
            if {$::moni::M(ExitWaitMantest) == 1} {
                set ::moni::M(ExitWaitMantest) 0
                set ::moni::M(waitdot) 0
                catch { .testInfoDlg.labf2.t fastinsert end "\n" }   ;#yueql
#                savelog "退出 wait_ram\n"
                break
#               return
            }
        }
				#设置启动mantest超时为3分钟
        if {$i == 300} {
            set ::moni::M(ErrorFound) 1
            set ::moni::M(HandleString) 0
            ::moni::send $::moni::Cfg(name) "\x0A"
            moni::saveerrlog "$moni::MSG(wait_mantest_log)"
            moni::savelog "$moni::MSG(wait_mantest_log)"
            moni::addtesterr
            catch { .testInfoDlg.labf2.t fastinsert end "\n$moni::MSG(wait_mantest_log)\n" }
            catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
            set ::moni::M(HandleString) 0
            if {$::moni::M(Producer) == "01"} {
                set ::moni::M(HandleString) 0
                set ::moni::M(ERROR_CODE) "T479"
                ::moni::get_result
                set ::moni::M(waitdot) 0
                return
            }

            moni::get_result
            set ::moni::M(waitdot) 0
            return
        }
        incr i
    }
}


proc moni::wait_boot {} {
    variable M
    set i 0
    set FmtErrStr1 "File system DevCreate failed"
    set FmtErrStr2 "cd: error = 0xc0009"
    set ::moni::M(waitdot) 1
    set name $::moni::Cfg(name)
    while {1} {
        #catch { .testInfoDlg.labf2.t fastinsert end "." }
        #catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
        ::moni::fastinsertend "test" "."
        ::moni::wait 1000
        set vBoot [string first {[Boot]:} $::moni::M(RecvBufAll.$name)]
        set vFmtErr1 [string first $FmtErrStr1 $::moni::M(RecvBufAll.$name)]
        set vFmtErr2 [string first $FmtErrStr2 $::moni::M(RecvBufAll.$name)]
        if {$::moni::M(FmtErrStrChecked) == 0} {
            if {$vFmtErr1 > 0 || $vFmtErr2 > 0} {
                set ::moni::M(FmtErrStrChecked) 1
                set ::moni::M(ErrorFound) 1
                moni::saveerrlog "$moni::MSG(wait_boot_log1)"
                moni::savelog "$moni::MSG(wait_boot_log1)"
                moni::addtesterr
                catch { .testInfoDlg.labf2.t fastinsert end "\n$moni::MSG(wait_boot_log1)\n" }
                catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
                tk_messageBox -message "$moni::MSG(wait_boot_log1)"
                if {$::moni::M(Manufactory) == "01"} {
                    set ::moni::M(HandleString) 0
                    set ::moni::M(ERROR_CODE) "T452"
                    ::moni::get_result
                    set ::moni::M(waitdot) 0
        	        return
        	    }
            }
        }
        if {$vBoot >= 0} {
            set ::moni::M(GetBoot) 1
            set ::moni::M(StartWaitRam) 0
            set ::moni::M(waitdot) 0
            break
        }
        incr i
        #设置启动bootrom超时为10分钟，如果是新卡或者是文件系统破坏，启动时将格式化
        if {$i ==  $::moni::M(waitBootTime)} {
            set ::moni::M(ErrorFound) 1
            ::moni::send $::moni::Cfg(name) "\x0A"
            moni::saveerrlog "$moni::MSG(wait_boot_log2)"
            moni::savelog "$moni::MSG(wait_boot_log2)"
            moni::addtesterr
            catch { .testInfoDlg.labf2.t fastinsert end "\n$moni::MSG(wait_boot_log2)\n" }
            catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
            set ::moni::M(HandleString) 0
            if {$::moni::M(Manufactory) == "01"} {
                set ::moni::M(HandleString) 0
                set ::moni::M(ERROR_CODE) "T479"
                ::moni::get_result
                set ::moni::M(waitdot) 0
                return
            }

            moni::get_result
            set ::moni::M(waitdot) 0
            return
        }
        #if {$::moni::M(BoardTypeNum) == 16 || $::moni::M(BoardTypeNum) == 80} {
            #::moni::send $::moni::Cfg(name) "\x0A"
        #}
    }
    if {$::moni::M(BoardTypeNum) == 16 || $::moni::M(BoardTypeNum) == 80} {
        ::moni::send $::moni::Cfg(name) "\x0A"
    }
}
##
##wait_showboard
## 等待showboard命令检测是否成功
##  返回结果
##  1，正确
##  0，错误
## wangbza,2011.1.14
##
proc moni::wait_showboard { } {
    #初始置位，表示没有开始检测
    #   0，将要开始
    #   1，正确
    #   2，错误
    #set moni::M(ShowboardCheck) 0
    set moni::M(ShowboardCheck) 0
    set show_board_cmd "show board\r"
    ::moni::send $::moni::Cfg(name) $show_board_cmd

    set i 0

    while { 1 } {
        moni::wait 1000

        if { $moni::M(ShowboardCheck) == 1 } {
            return 1
        }

        if { $moni::M(ShowboardCheck) == 2 } {
            return 0
        }

        incr i

        #等待3分钟
        if { $i > $::moni::M(waitShowboardTime) } {
            set ::moni::M(ErrorFound) 1
            ::moni::send $::moni::Cfg(name) "\x0A"
            moni::saveerrlog "$moni::MSG(wait_showboard_faillog)"
            moni::savelog "$moni::MSG(wait_showboard_faillog)"
            moni::addtesterr
            catch { .testInfoDlg.labf2.t fastinsert end "\n$moni::MSG(wait_showboard_faillog)\n" }
            catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
            set ::moni::M(HandleString) 0
            if {$::moni::M(Manufactory) == "01" || $::moni::M(Manufactory) == "scc"} {
                set ::moni::M(HandleString) 0
                set ::moni::M(ERROR_CODE) "T479"
            }
            #moni::get_result
            return 0
        }
    }

    return 1

}
proc moni::test_end {} {
    catch {destroy .butCommonDlg}
    catch {destroy .ledCpldOffTestDlg}
    catch {destroy .commonDlg}
    catch {destroy .power6TestDlg}
    catch {destroy .power8TestDlg}
    catch {destroy .testFailedDlg}
    catch {.testInfoDlg.but configure -state disabled}
    catch {.testInfoDlg.but2 configure -state disabled}
    catch {destroy .sigCommonDlg}

    ::moni::get_result
    return

}

proc moni::get_result {} {
    catch {destroy .butCommonDlg}
    catch {destroy .ledCpldOffTestDlg}
    catch {destroy .commonDlg}
    catch {destroy .power6TestDlg}
    catch {destroy .power8TestDlg}
    catch {destroy .testFailedDlg}
    catch {destroy .sigCommonDlg}
    if {$::moni::M(GetResult) == 1} {
        return
    }
    if {$::moni::M(Manufactory) == "01"} {
        if {$::moni::M(ErrorFound) == 1} {
            #tk_messageBox -message "create_result_file ErrorFound M(CHECK)=$::moni::M(CHECK)"
            if {$::moni::M(CHECK) == "PASS"} {
                set ::moni::M(RESULT) "F"
            } elseif {$::moni::M(CHECK) == "RETEST"} {
                set ::moni::M(RESULT) "RF"
            }
        } else {
            if {$::moni::M(CHECK) == "PASS"} {
                set ::moni::M(RESULT) "P"
            } elseif {$::moni::M(CHECK) == "RETEST"} {
                set ::moni::M(RESULT) "RP"
            }
        }
        moni::create_result_file
    }

    if {$::moni::M(ErrorFound) == 0} {

        #/*Begin:当测试复测测试全部成功后，删除mantest.img以及老化日志,bug[45928]*/
		if { $::moni::M(BoardType) != "S4200-28P-SI" \
			&& $::moni::M(BoardType) != "S4200-28P-P-SI" } {
			if {$::moni::M(TestType) == "F/T"} {	
				::moni::send $::moni::Cfg(name) "en\n"
				#::moni::wait 2000
				#::moni::send $::moni::Cfg(name) "boot img flash:/nos.img primary\n"
				::moni::wait 2000
				::moni::send $::moni::Cfg(name) "delete mantest.log\r"
				::moni::wait 500
				::moni::send $::moni::Cfg(name) "y\r"
				::moni::wait 5000
				::moni::send $::moni::Cfg(name) "delete mantest.img\r"
				::moni::wait 500
				::moni::send $::moni::Cfg(name) "y\r"
				#::moni::wait 5000				
				#::moni::send $::moni::Cfg(name) "reload\r"
				#::moni::wait 3000
				#::moni::send $::moni::Cfg(name) "y\r"
				#::moni::wait 3000
				#/*End:当测试复测测试全部成功后，删除mantest.img以及老化日志,bug[45928]*/
			}
		} 
    }

    moni::sendlogfile

    toplevel .testEndDlg
    wm withdraw .testEndDlg
    update
    BWidget::place .testEndDlg 500 300 center

    wm transient .testEndDlg .
    wm title     .testEndDlg "Testing END..."
    wm deiconify .testEndDlg
    wm resizable .testEndDlg 0 0

	  set win .testEndDlg
    set f [frame $win.cfg]
    pack $f -side top

    Label $win.label1 -text "$moni::MSG(get_result_text1)" \
	    -font { 宋体 15 bold } -bg ForestGreen -fg white \
        -width 50 -anchor w	-justify left -relief sunken -wraplength 440

    place $win.label1 \
        -in $win -x 30 -y 30 -width 440 -height 80 -anchor nw \
        -bordermode ignore

    if {$::moni::M(ErrorFound) == 0} {
        set label2 [Label $win.label2 -image [bitmap OK] ]
        set label3 [Label $win.label3 -text "OK!" -anchor w \
            -font { 宋体 20 normal } -fg blue ]

        place $label2 \
            -in $win -x 180 -y 150 -width 80 -height 80 -anchor nw \
            -bordermode ignore
        place $label3 \
            -in $win -x 280 -y 180 -width 200 -height 30 -anchor nw \
            -bordermode ignore
    } else {
        set label2 [Label $win.label2 -image [bitmap ERROR] ]
        set label3 [Label $win.label3 -text "ERROR!" -anchor w \
            -font { 宋体 20 normal } -fg red ]

        place $label2 \
            -in $win -x 180 -y 150 -width 80 -height 80 -anchor nw \
            -bordermode ignore
        place $label3 \
            -in $win -x 280 -y 180 -width 250 -height 30 -anchor nw \
            -bordermode ignore
    }
    pack $f -side top


    button $win.but1 -text "$moni::MSG(retest_but_text)" -font { 宋体 14 bold } -width 10 \
        -command {::moni::next_test} -fg brown \
        -highlightthickness 0 -takefocus 0 -borderwidth 2
    button $win.but2 -text "$moni::MSG(close_but_text)" -font { 宋体 14 bold } -width 10 \
        -command {::moni::finish_test_no_new_test} -fg brown \
        -highlightthickness 0 -takefocus 0 -borderwidth 2

    place $win.but1 \
        -in $win -x 100 -y 250 -anchor nw -bordermode ignore
    place $win.but2 \
        -in $win -x 300 -y 250 -anchor nw -bordermode ignore

    grab .testEndDlg
    focus -force .testEndDlg
    set ::moni::M(GetResult) 1
}

proc moni::delete_mantestimg_and_log {} {
	::moni::send $::moni::Cfg(name) "en\n"
	#::moni::wait 2000
	#::moni::send $::moni::Cfg(name) "boot img flash:/nos.img primary\n"
	::moni::send $::moni::Cfg(name) "delete mantest.log\r"
	::moni::wait 500
	::moni::send $::moni::Cfg(name) "y\r"
	::moni::wait 500
	::moni::send $::moni::Cfg(name) "delete mantest.img\r"
	::moni::wait 500
	::moni::send $::moni::Cfg(name) "y\r"
	::moni::wait 1000
}

proc moni::update_nosimg {} {
	set ans [tk_messageBox -message "请将升级网线连接到端口1，确认端口up后开始升级img" -type okcancel -icon info]
	switch -- $ans {
		ok {
			::moni::send $::moni::Cfg(name) "en\n"
			::moni::wait 500
			::moni::send $::moni::Cfg(name) "config\n"
			::moni::wait 500
			::moni::send $::moni::Cfg(name) "vlan 100\n"
			::moni::wait 500
			::moni::send $::moni::Cfg(name) "interface ethernet 1/0/1\n"
			::moni::wait 500
			::moni::send $::moni::Cfg(name) "switchport mode access\n"
			::moni::wait 500
			::moni::send $::moni::Cfg(name) "switchport access vlan 100\n"
			::moni::wait 500
			::moni::send $::moni::Cfg(name) "interface vlan 100\n"
			::moni::wait 500
			::moni::send $::moni::Cfg(name) "ip address 1.1.1.122 255.255.255.0\n"
			::moni::wait 500
			::moni::send $::moni::Cfg(name) "end\n"
			::moni::wait 2000
			::moni::send $::moni::Cfg(name) "\ncopy tftp://1.1.1.1/DCN-S4200-10.17.0-vendor_7.0.3.5(R0241.0198)_nos.img nos.img\n"
			# ::moni::wait 300000
			catch { .testInfoDlg.labf2.t fastinsert end "\nUpdate nos.img start!!\n" }
			# ::moni::wait_result_string "Write ok." "Update nos.img Failed!!" 30
			if {1 == [ ::moni::wait_result_string "Write ok." "Update nos.img Failed!!" 360 ] } {
				catch { .testInfoDlg.labf2.t fastinsert end "\nUpdate img OK!!\n" }
			}
			# catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
		}
		cancel {
			set ::moni::M(ErrorFound) 1
			::moni::get_result
		}
	}

}

proc moni::wait_result_string { result err_msg timeout} {
	variable M
	set i 0
	set waitTime 1000
	set name $::moni::Cfg(name)
	# ::moni::wait $waitTime

	while {1} {
		::moni::wait $waitTime
		set vStringChk [string first $result $::moni::M(RecvBufAll.$name)]
		if { $vStringChk >= 0 } {
			return 1
		}

		if {$i == $timeout * 1000/$waitTime} {
			set ::moni::M(ErrorFound) 1
			# set ::moni::M(HandleString) 0
			::moni::send $::moni::Cfg(name) "\x0A"
			moni::saveerrlog "$err_msg"
			moni::savelog "$err_msg"
			moni::addtesterr
			catch { .testInfoDlg.labf2.t fastinsert end "\n$err_msg\n" }
			catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
			# set ::moni::M(HandleString) 0

			moni::get_result
			return 0
		}
		incr i
	}
}

proc moni::atem_license_is_support {} {
	if { $::moni::M(BoardType) == "S4200-28P-SI" \
		|| $::moni::M(BoardType) == "S4200-28P-P-SI" } {
		return 0
	} else {
		return 1
	}
}

proc moni::next_test {} {
    catch {destroy .testEndDlg}
    catch {destroy .testFailedDlg}
#    catch {destroy .testInfoDlg}
    ::moni::finish_test
    wm state . normal  ;#yueql,恢复主窗口
    ::moni::set_mac
}

proc moni::wait {millisecond} {
    set y 0
    after $millisecond {set y 1}
    vwait y
}


##
##返回值
##  1，正确
##  2，错误，并且已经getresult
##  0, 错误，没有getresult
##
proc moni::set_boot_variable {} {
    variable M

    ::moni::get_time
    ::moni::send_config
    ::moni::wait 500
    ::moni::send_type
    ::moni::wait 500
    # 主控卡才有RTC
    if {$::moni::M(BoardTypeNum) == 1 || $::moni::M(BoardTypeNum) == 13 \
        || $::moni::M(BoardTypeNum) == 15 || $::moni::M(BoardTypeNum) == 16 \
        || $::moni::M(BoardTypeNum) == 18 || $::moni::M(BoardTypeNum) == 31 \
        || $::moni::M(BoardTypeNum) == 38 || $::moni::M(BoardTypeNum) == 102 \
        || $::moni::M(BoardTypeNum) == 39 || $::moni::M(BoardTypeNum) == 103 \
        || $::moni::M(BoardTypeNum) == 65 || $::moni::M(BoardTypeNum) == 77 \
        || $::moni::M(BoardTypeNum) == 79 || $::moni::M(BoardTypeNum) == 80 \
        || $::moni::M(BoardTypeNum) == 82 || $::moni::M(BoardTypeNum) == 86 \
        || $::moni::M(BoardTypeNum) == 128 || $::moni::M(BoardTypeNum) == 129} {

        if {$::moni::M(IsChassis) == 1} {
            ::moni::wait 500
            ::moni::send_rtc
            ::moni::wait 500
            ::moni::send_show_rtc
            ::moni::wait 500
        }
    }


    ;#BEGIN: Modified by jianghtc, 2010/04/13 bug[42248],只有机箱测试不需要设置mac
    if {$::moni::M(BoardTypeNum) != 6 && $::moni::M(BoardTypeNum) != 9 \
        && $::moni::M(BoardTypeNum) != 70 && $::moni::M(BoardTypeNum) != 73 \
        && $::moni::M(BoardTypeNum) != 199 && $::moni::M(BoardTypeNum) != 200} {
        ;#END:   Modified by jianghtc, 2010/04/13 bug[42248]
        ::moni::send_mac
        ::moni::wait 500
    }

    if {$::moni::M(BoardTypeNum) != 6 && $::moni::M(BoardTypeNum) != 9 \
        && $::moni::M(BoardTypeNum) != 70 && $::moni::M(BoardTypeNum) != 73 \
        && $::moni::M(BoardTypeNum) != 153} {

        ::moni::send_sn
        ::moni::wait 500

        #BEGIN: Added by gujunqi, 2009/1/5
        #/* BEGIN: Modified by jianghtc, 2010/01/26 任务[40676] */
        if {$::moni::M(BoardTypeNum) == 128 || $::moni::M(BoardTypeNum) == 129 || $::moni::M(BoardTypeNum) == 130 \
            || $::moni::M(BoardTypeNum) == 131 || $::moni::M(BoardTypeNum) == 132 \
            || $::moni::M(BoardTypeNum) == 133 || $::moni::M(BoardTypeNum) == 134 \
            || $::moni::M(BoardTypeNum) == 136 || $::moni::M(BoardTypeNum) == 137 \
            || $::moni::M(BoardTypeNum) == 138 || $::moni::M(BoardTypeNum) == 145 \
            || $::moni::M(BoardTypeNum) == 199 || $::moni::M(BoardTypeNum) == 200 \
            || $::moni::M(BoardTypeNum) == 9 || $::moni::M(BoardTypeNum) == 73} {
            if { $::moni::M(IsChassis) == 1} {
                ::moni::send_cardflag
                 #/* BEGIN: Added by yueql, 2010/11/3 bug[41634] */
                ::moni::wait_cardflag
                if {$::moni::M(GetCardFlag) == 1} {
                    set ::moni::M(GetCardFlag) 0
                } else {
                    tk_messageBox -message "$moni::MSG(set_boot_variable_msg1)"
                    ::moni::get_result
                    return 2
                }
                #/* END: Added by yueql, 2010/11/3 bug[41634] */
                ::moni::wait 500
                ::moni::send_cardwatt
                #/* BEGIN: Added by yueql, 2010/11/3 bug[41634] */
                ::moni::wait_cardwatt
                if {$::moni::M(GetCardWatt) == 1} {
                    set ::moni::M(GetCardWatt) 0
                } else {
                    tk_messageBox -message "$moni::MSG(set_boot_variable_msg2)"
                    ::moni::get_result
                    return 2
                }
                #/*END: Added by yueql, 2010/11/3 bug[41634] */
                ::moni::wait 500
            }
        }
        #/* END:   Modified by jianghtc, 2010/01/26 任务[40676] */
        #END:   Added by gujunqi, 2009/1/5

        ::moni::send_sw
        ::moni::wait 500
        # 除背板外都有生产日期
        ::moni::send_date
        ::moni::wait 500
    }
    if { [::moni::send_show_board_info] == 0 } {
        return 2
    }
    ::moni::wait 500

    if {$::moni::M(BoardTypeNum) == 21 || $::moni::M(BoardTypeNum) == 85} {
        #tk_messageBox -message "请拔出所有环回网线、光纤和背板上的环接头，插入与PC相连的下载线，然后点击“确定”!"
    }

    return 1
}

proc moni::send_config {} {
    ::moni::send $::moni::Cfg(name) "setconfig\r"
    ::moni::wait 500
    
    if {$::moni::M(BoardTypeNum) == 145} {
       ::moni::send $::moni::Cfg(name) "10.1.1.1\r"
       ::moni::wait 500
       ::moni::send $::moni::Cfg(name) "10.1.1.2\r"
       ::moni::wait 500
       ::moni::send $::moni::Cfg(name) "saveconfig\r"    
   } else {
    ::moni::send $::moni::Cfg(name) "10.1.1.1\r"
    #::moni::send $::moni::Cfg(name) "192.168.1.10\r"
    ::moni::wait 500
    ::moni::send $::moni::Cfg(name) "10.1.1.2\r"
    #::moni::send $::moni::Cfg(name) "192.168.1.200\r"
    ::moni::wait 500
    ::moni::send $::moni::Cfg(name) "1\r"
    ::moni::wait 500
    ::moni::send $::moni::Cfg(name) "guest\r"
    #::moni::send $::moni::Cfg(name) "ZomaBSP\r"
    ::moni::wait 500
    ::moni::send $::moni::Cfg(name) "switch\r"
    ::moni::wait 500
    ::moni::send $::moni::Cfg(name) "saveconfig\r"
    }
}

proc moni::get_time {} {
    variable M

    set start [clock seconds]
    set ::moni::M(Year) [clock format $start -format %Y]
    set ::moni::M(Month) [clock format $start -format %m]
    set ::moni::M(Day) [clock format $start -format %d]
    set ::moni::M(Hour) [clock format $start -format %H]
    set ::moni::M(Minute) [clock format $start -format %M]
    set ::moni::M(Second) [clock format $start -format %S]

    set ::moni::M(Time) $M(Year)/$M(Month)/$M(Day)/$M(Hour):$M(Minute):$M(Second)
}

proc moni::send_rtc {} {
    variable M

    ::moni::get_time
    ::moni::send $::moni::Cfg(name) "rtcset $M(Year) $M(Month) $M(Day) $M(Hour) $M(Minute) $M(Second)\r"
}

proc moni::send_show_rtc {} {
    ::moni::send $::moni::Cfg(name) "rtcshow\r"
}

;#BEGIN: Added by jianghtc, 2010/03/26 bug[41903]
proc moni::send_show_manage_mac {} {
    ::moni::send $::moni::Cfg(name) "setmac cpu\r"
}
;#END:   Added by jianghtc, 2010/03/26 bug[41903]

proc moni::send_type {} {
    if {$::moni::M(BoardTypeNum) == 5 || $::moni::M(BoardTypeNum) == 69} {
        set settype_cmd "settype sw\r"
        ::moni::send $::moni::Cfg(name) $settype_cmd
        ::moni::wait 300
        ::moni::send $::moni::Cfg(name) "$::moni::M(BoardTypeNum)\r"
        set settype_cmd "settype cpu\r"
        ::moni::send $::moni::Cfg(name) $settype_cmd
        ::moni::wait 300
        ::moni::send $::moni::Cfg(name) "$::moni::M(BoardTypeNum)\r"
    } else {
        set settype_cmd "settype sw\r"
        ::moni::send $::moni::Cfg(name) $settype_cmd
        ::moni::wait 300
        ::moni::send $::moni::Cfg(name) "$::moni::M(BoardTypeNum)\r"
    }
}

#参数为 “FF-FF-FF-FF-FF-FF” 格式
proc incr_mac {mac_dash} {
    upvar macplusdash mac

    set machex1 [string range $mac_dash 0 1]
    set machex2 [string range $mac_dash 3 4]
    set machex3 [string range $mac_dash 6 7]
    set machex4 [string range $mac_dash 9 10]
    set machex5 [string range $mac_dash 12 13]
    set machex6 [string range $mac_dash 15 17]
    set machex "$machex1$machex2$machex3$machex4$machex5$machex6"

    set mac6f [string range $machex 0 5]     ;#取前六位
    set mac6b [string range $machex 6 11]    ;#取后六位
    set mac6b [format "%#d" 0x$mac6b]                 ;#转换为十进制
    set mac6b1 [expr {$mac6b+1}]                      ;#进行加一操作
    set mac6b1 [format "%#X" $mac6b1]                 ;#转换为十六进制字母大写
    set len [string length $mac6b1]                      ;#获取转换后所得十六进制数的位数
    #不足6位（除‘0x’），则在前面补0
    if {$len < 8} {
        set mac6b1 [string range $mac6b1 2 $len]
        for {set i $len} {$i < 8} {incr i} {
            set mac6b1 "0$mac6b1"
        }
        set mac6b1 0x$mac6b1
    }
    set mac6b1 [string range $mac6b1 2 7]

    set mac $mac6f$mac6b1                             ;#得到输入原始MAC加一的MAC
    set macplus_dash [string range $mac 0 1]
    for {set i 2} {$i<11} {incr i 2} {
        set mac2digit [string range $mac $i [expr {$i+1}]]
        set dash -
        set macplus_dash $macplus_dash$dash$mac2digit
    }

    set mac_dash $macplus_dash
    set mac $mac_dash
}

proc putlog {file_str str} {
    set filename $file_str.txt
    file mkdir ./log
    set f [open ./log/$filename "a+"]
    puts $f $str
    close $f
}

proc moni::send_atemlicense {vlanmac} {

	set name $::moni::Cfg(name)

	::moni::send $::moni::Cfg(name) "showatemsn\r"
	if { [::moni::wait_string {atem sn:}] == 0 } {
		tk_messageBox -message "$moni::MSG(Invalid_atemsn_msg)" -icon error
		set ::moni::M(ErrorFound) 1
		::moni::get_result
		return;
	}

	set showatem [string first "showatemsn" $::moni::M(RecvBufAll.$name) 100]
	set index [string first "atem sn:" $::moni::M(RecvBufAll.$name) $showatem]
	set enter [string first "\x0A" $::moni::M(RecvBufAll.$name) $index]
	set atemsn [string range $::moni::M(RecvBufAll.$name) [expr {$index + 8}] [expr {$enter - 1}] ]

	set ::moni::M(ATEMSN) $atemsn

	#putlog $vlanmac $atemsn

	set atemlicense [exec java -jar java/HttpClient.jar get $atemsn $vlanmac]
	if {[string length $atemlicense] != 172} {
		tk_messageBox -message "$moni::MSG(Invalid_atemlicense_msg)" -icon error
		set ::moni::M(ErrorFound) 1
		::moni::get_result
	} else {
		::moni::send $::moni::Cfg(name) "setatemlicense\r"
		::moni::wait 5000
		::moni::send $::moni::Cfg(name) "$atemlicense\r"
		::moni::wait 5000
		#putlog $vlanmac $atemlicense
	}
}

proc moni::send_mac {} {
    variable M

    set mac $::moni::M(MacVlan)                             ;#获取输入原始MAC
    set macraw [string range $mac 0 1]
    for {set i 2} {$i<11} {incr i 2} {
        set mac2digit [string range $mac $i [expr {$i+1}]]
        set dash -
        set macraw $macraw$dash$mac2digit
    }

    set macraw6f [string range $::moni::M(MacVlan) 0 5]     ;#取前六位
    set macraw6b [string range $::moni::M(MacVlan) 6 11]    ;#取后六位
    set macraw6b [format "%#d" 0x$macraw6b]                 ;#转换为十进制
    set macraw6b1 [expr {$macraw6b+1}]                      ;#进行加一操作
    set macraw6b2 [expr {$macraw6b+2}]
    set macraw6b1 [format "%#x" $macraw6b1]                 ;#转换为十六进制
    set macraw6b2 [format "%#x" $macraw6b2]
    set len [string length $macraw6b1]                      ;#获取转换后所得十六进制数的位数
    #不足6位（除‘0x’），则在前面补0
    if {$len < 8} {
        set macraw6b1 [string range $macraw6b1 2 $len]
        for {set i $len} {$i < 8} {incr i} {
            set macraw6b1 "0$macraw6b1"
        }
        set macraw6b1 0x$macraw6b1
    }
    set macraw6b1 [string range $macraw6b1 2 7]

    set mac $macraw6f$macraw6b1                             ;#得到输入原始MAC加一的MAC
    set macplus [string range $mac 0 1]
    for {set i 2} {$i<11} {incr i 2} {
        set mac2digit [string range $mac $i [expr {$i+1}]]
        set dash -
        set macplus $macplus$dash$mac2digit
    }

    set len [string length $macraw6b2]                      ;#获取转换后所得十六进制数的位数
    #不足6位（除‘0x’），则在前面补0
    if {$len < 8} {
        set macraw6b2 [string range $macraw6b2 2 $len]
        for {set i $len} {$i < 8} {incr i} {
            set macraw6b2 "0$macraw6b2"
        }
        set macraw6b2 0x$macraw6b2
    }
    set macraw6b2 [string range $macraw6b2 2 7]

    set mac $macraw6f$macraw6b2                             ;#得到输入原始MAC加二的MAC
    set macplusplus [string range $mac 0 1]
    for {set i 2} {$i<11} {incr i 2} {
        set mac2digit [string range $mac $i [expr {$i+1}]]
        set dash -
        set macplusplus $macplusplus$dash$mac2digit
    }
  
	set setmac_cmd "setmac sw\r"
	::moni::send $::moni::Cfg(name) $setmac_cmd
	::moni::wait 2000
	::moni::send $::moni::Cfg(name) "$macraw\r"
	::moni::wait 2000
	::moni::send $::moni::Cfg(name) "$macplus\r"
	::moni::wait 2000
	if { $::moni::M(BoardType) == "S5750E-52X-SI" \
		|| $::moni::M(BoardType) == "CS6200-52X-EI" \
		|| $::moni::M(BoardType) == "S5750E-28X-P-SI" \
		|| $::moni::M(BoardType) == "S5750E-28X-SI" \
		|| $::moni::M(BoardType) == "S5750E-28C-SI" \
		|| $::moni::M(BoardType) == "CS6200-28X-P-EI" \
		|| $::moni::M(BoardType) == "CS6200-28X-EI" } {
		set setmac_cmd "setmac cpu\r"
		::moni::send $::moni::Cfg(name) $setmac_cmd
		::moni::wait 2000
		::moni::send $::moni::Cfg(name) "$macplusplus\r"
		::moni::wait 2000
	}
	
	if { $::moni::M(BoardType) != "S4200-28P-SI" \
		&& $::moni::M(BoardType) != "S4200-28P-P-SI" } {
		::moni::send_atemlicense $macraw
	}
}

proc moni::send_sn {} {
    variable M

    if {$::moni::M(BoardTypeNum) == 5 || $::moni::M(BoardTypeNum) == 69} {
        set setsn_cmd "setsn cpu\r"
    } else {
        set setsn_cmd "setsn sw\r"
    }
    ::moni::send $::moni::Cfg(name) $setsn_cmd
    ::moni::wait 500
    ::moni::send $::moni::Cfg(name) "$::moni::M(SN)\r"
}

#BEGIN: Added by gujunqi, 2009/1/5
proc moni::send_cardflag {} {
    variable M

    if {$::moni::M(BoardTypeNum) == 128 || $::moni::M(BoardTypeNum) == 129} {
        set setsn_cmd "setcardflag 1\r"
    } elseif {$::moni::M(BoardTypeNum) == 131 || $::moni::M(BoardTypeNum) == 132 \
          || $::moni::M(BoardTypeNum) == 134|| $::moni::M(BoardTypeNum) == 136 \
          || $::moni::M(BoardTypeNum) == 137 || $::moni::M(BoardTypeNum) == 138 \
	  || $::moni::M(BoardTypeNum) == 145} {
        set setsn_cmd "setcardflag 2\r"
    } else {

    }

    ::moni::send $::moni::Cfg(name) $setsn_cmd
}
#/* BEGIN: Added by yueql, 2010/11/3 bug[41634] */
proc moni::wait_cardflag {} {
    variable M
    set SuccessStr1 "set card flag success"
    set ErrorStr "set card flag error"
    set name $::moni::Cfg(name)

    set i 0
    while { $i < 10 } { ;#等待10次，每次500ms，共5s
        catch { .testInfoDlg.labf2.t fastinsert end "." }
        catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
        ::moni::wait 500
        set vCardFlag [string first $SuccessStr1 $::moni::M(RecvBufAll.$name)]
	set vCardFlagError [string first $ErrorStr $::moni::M(RecvBufAll.$name)]

        if {$vCardFlag >= 0} {
            set ::moni::M(GetCardFlag) 1
            return
        } elseif { $vCardFlagError >= 0} {
			break 
    	}
        incr i
    }
    set ::moni::M(GetCardFlag) 0
    set ::moni::M(ErrorFound) 1
    moni::saveerrlog "set card flag error\n"
    moni::savelog "set card flag error\n"
    moni::addtesterr
    catch { .testInfoDlg.labf2.t fastinsert end "\nset card flag error\n\n" }
    catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
    set ::moni::M(HandleString) 0
    if {$::moni::M(Manufactory) == "01"} {
        set ::moni::M(HandleString) 0
        set ::moni::M(ERROR_CODE) "T502"
    }
    return 
}
#/* END: Added by yueql, 2010/11/3 bug[41634] */
proc moni::send_cardwatt {} {
    variable M

    if {$::moni::M(BoardTypeNum) == 128} {
        set setsn_cmd "setcardwatt 75\r"
    } elseif {$::moni::M(BoardTypeNum) == 129} {
        set setsn_cmd "setcardwatt 85\r"
    } elseif {$::moni::M(BoardTypeNum) == 131 } {
        set setsn_cmd "setcardwatt 58\r"
    } elseif {$::moni::M(BoardTypeNum) == 132 } {
        set setsn_cmd "setcardwatt 43\r"
    } elseif { $::moni::M(BoardTypeNum) == 134} {
        set setsn_cmd "setcardwatt 60\r"
    } elseif { $::moni::M(BoardTypeNum) == 136} {
        set setsn_cmd "setcardwatt 60\r"
    } elseif { $::moni::M(BoardTypeNum) == 137} {
        set setsn_cmd "setcardwatt 65\r"
    } elseif { $::moni::M(BoardTypeNum) == 138} {
        set setsn_cmd "setcardwatt 130\r"
    } elseif { $::moni::M(BoardTypeNum) == 145} {
        set setsn_cmd "setcardwatt 130\r"
    }
    ::moni::send $::moni::Cfg(name) $setsn_cmd
}
#/* BEGIN: Added by yueql, 2010/11/3 bug[41634] */
proc moni::wait_cardwatt {} {
    variable M
    set SuccessStr1 "set card watt success"

    set name $::moni::Cfg(name)
    while {1} {
        catch { .testInfoDlg.labf2.t fastinsert end "." }
        catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
        ::moni::wait 500
        set vCardWatt [string first $SuccessStr1 $::moni::M(RecvBufAll.$name)]

        if {$vCardWatt >= 0} {
            set ::moni::M(GetCardWatt) 1
            break
        }
    }
}
#/*END: Added by yueql, 2010/11/3 bug[41634] */
#END:   Added by gujunqi, 2009/1/5

proc moni::send_sw {} {
    variable M

    if {$::moni::M(BoardTypeNum) == 5 || $::moni::M(BoardTypeNum) == 69} {
        set setver_cmd "setver cpu\r"
    } else {
        set setver_cmd "setver sw\r"
    }
    ::moni::send $::moni::Cfg(name) $setver_cmd
    ::moni::wait 500
    ::moni::send $::moni::Cfg(name) "$::moni::M(HWVersion)\r"
}

proc moni::send_date {} {
    variable M

    if {$::moni::M(BoardTypeNum) == 5 || $::moni::M(BoardTypeNum) == 69} {
        set setdate_cmd "setdate cpu\r"
    } else {
        set setdate_cmd "setdate sw\r"
    }
    ::moni::send $::moni::Cfg(name) $setdate_cmd
    ::moni::wait 500
    ::moni::send $::moni::Cfg(name) "$::moni::M(Year)/$::moni::M(Month)/$::moni::M(Day)\r"
}

proc moni::send_show_board_info {} {
    variable M

    if {$::moni::M(BoardTypeNum) == 5 || $::moni::M(BoardTypeNum) == 69} {
        set show_board_cmd "show cpuboard\r"
        ::moni::send $::moni::Cfg(name) $show_board_cmd
    } else {
        #set show_board_cmd "show cpuboard\r"
        #::moni::send $::moni::Cfg(name) $show_board_cmd
        #::moni::wait 1000
        if { [moni::wait_showboard] == 0 } {
            return 0
        } else {
            return 1
        }
    }
}

proc moni::send_dir {} {
    ::moni::send $::moni::Cfg(name) "dir\r"
}

proc moni::check_cable {} {
    if {$::moni::M(TestType) == "F/T" } {
        if {$::moni::M(BoardTypeNum) == 0 || $::moni::M(BoardTypeNum) == 0 \
            || $::moni::M(BoardTypeNum) == 0} {
            if {$::moni::M(AllCableOut) == 0} {
                set ::moni::M(AllCableOut) 1
                tk_messageBox -message "$moni::MSG(check_cable_msg)"
            }
        }
    }
}


proc moni::send_load_boot_loop {} {
    for {set i 0} {$i<60} {incr i} {
		if {$::moni::M(BootLoaded) == 1} {
			break
        }
        ::moni::wait 1000
	}
}

proc moni::resend_load_boot {} {
    catch { destroy .checkBootromDlg }
    set ::moni::M(FileError) 0
    ::moni::send $::moni::Cfg(name) "loading boot.rom\r"
    .testInfoDlg.labf2.t fastinsert end "loading boot.rom...\n"

    while {1} {
        for {set i 0} {$i<60} {incr i} {
            catch { .testInfoDlg.labf2.t fastinsert end "." }
            catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
    		if {$::moni::M(BootLoaded) == 1} {
    			break
            }
            if {$::moni::M(FileError) == 1} {
                ::moni::bootrom_check
                return
            }
            ::moni::wait 1000
    	}

        if {$::moni::M(BootLoaded) == 0} {
            ::moni::bootrom_check
            return
        } elseif {$::moni::M(BootLoaded) == 1} {
            catch { destroy .checkBootromDlg }
            moni::addtestok
            moni::savelog "loading boot.rom OK!\n"
            # 设置写boot.rom超时为4分钟
            for {set i 0} {$i<240} {incr i} {
                catch { .testInfoDlg.labf2.t fastinsert end "." }
                catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
        		if {$::moni::M(BootWrited) == 1} {
        			break
                }
                ::moni::wait 1000
        	}

            ::moni::write_boot_result
            return
        }
    }
}


proc moni::bootrom_check {} {
    variable M
    variable Cfg
    update

    catch { destroy .checkBootromDlg }
    toplevel .checkBootromDlg

    wm withdraw .checkBootromDlg
    update
    BWidget::place .checkBootromDlg 400 160 center

    wm transient .checkBootromDlg .
    wm title     .checkBootromDlg "Please check the port connection!"
    wm deiconify .checkBootromDlg
    wm resizable .checkBootromDlg 0 0

    set win .checkBootromDlg
    set f [frame $win.cfg]



    Label $win.label -text "  Can't load boot.rom, please put boot.rom to FTP server, then click “Confirm”!" \
        -font { 宋体 12 normal } -bg ForestGreen -fg white \
        -width 50 -anchor w	-justify center -relief sunken -wraplength 460

    place $win.label \
        -in $win -x 20 -y 20 -width 390 -height 80 -anchor nw \
        -bordermode ignore

    pack $f -side top

    button $win.but1 -text "Confirm" -font { 宋体 12 normal } -width 10 \
        -command {::moni::resend_load_boot} -fg brown \
        -highlightthickness 0 -takefocus 0 -borderwidth 2
    button $win.but2 -text "Close" -font { 宋体 12 normal } -width 10 \
        -command {::moni::exit_after_bootrom_check} -fg brown -state normal \
        -highlightthickness 0 -takefocus 0 -borderwidth 2

    place $win.but1 \
        -in $win -x 130 -y 120 -anchor nw -bordermode ignore
    place $win.but2 \
        -in $win -x 270 -y 120 -anchor nw -bordermode ignore

    grab .checkBootromDlg
}

proc moni::exit_after_bootrom_check {} {

    catch { destroy .checkNosimgDlg }
    set ::moni::M(ErrorFound) 1
    set ::moni::M(ERROR_CODE) "T479"
    moni::addtesterr
    moni::saveerrlog "load boot.rom FAILED!\n"
    moni::savelog "load boot.rom FAILED!\n"
    ::moni::get_result
}

proc moni::send_load_boot {} {
    set ::moni::M(FileError) 0
    ::moni::send $::moni::Cfg(name) "loading boot.rom\r"
    .testInfoDlg.labf2.t fastinsert end "loading boot.rom...\n"
    .testInfoDlg.labf2.t yview 10000        ;#ctext显示到10000行

    for {set i 0} {$i<60} {incr i} {
        catch { .testInfoDlg.labf2.t fastinsert end "." }
        catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
		if {$::moni::M(BootLoaded) == 1} {
			break
        }
        if {$::moni::M(FileError) == 1} {
            ::moni::bootrom_check
            return
        }
        ::moni::wait 1000
	}

    if {$::moni::M(BootLoaded) == 0} {
        ::moni::bootrom_check
    } elseif {$::moni::M(BootLoaded) == 1} {
        catch { destroy .checkBootDlg }
        moni::addtestok
        moni::savelog "load boot.rom OK!\n"
        # 设置写boot.rom超时为4分钟
        for {set i 0} {$i<240} {incr i} {
            catch { .testInfoDlg.labf2.t fastinsert end "." }
            catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
    		if {$::moni::M(BootWrited) == 1} {
    			break
            }
            ::moni::wait 1000
    	}

        ::moni::write_boot_result
    }
}




proc moni::send_load_img_loop {} {
    for {set i 0} {$i<60} {incr i} {
		if {$::moni::M(ImageLoaded) == 1} {
			break
        }
        ::moni::wait 1000
	}
}

proc moni::resend_load_img {} {
    catch { destroy .checkNosimgDlg }
    set ::moni::M(FileError) 0
    ::moni::send $::moni::Cfg(name) "loading nos.img\r"
    .testInfoDlg.labf2.t fastinsert end "loaing nos.img...\n"

    while {1} {
        for {set i 0} {$i<60} {incr i} {
            catch { .testInfoDlg.labf2.t fastinsert end "." }
            catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
    		if {$::moni::M(ImageLoaded) == 1} {
    			break
            }
            if {$::moni::M(FileError) == 1} {
                ::moni::nosimg_check
                return
            }
            ::moni::wait 1000
    	}

        if {$::moni::M(ImageLoaded) == 0} {
            ::moni::nosimg_check
            return
        } elseif {$::moni::M(ImageLoaded) == 1} {
            catch { destroy .checkNosimgDlg }
            moni::addtestok
            moni::savelog "load nos.img OK!\n"
            # 设置写nos.img超时为10分钟
            for {set i 0} {$i<600} {incr i} {
                catch { .testInfoDlg.labf2.t fastinsert end "." }
                catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
        		if {$::moni::M(ImageWrited) == 1} {
        			break
                }
                ::moni::wait 1000
        	}

            ::moni::write_img_result
            return
        }
    }
}

proc moni::resend_load_vendorcfg {} {
    catch { destroy .checkVendorCfgDlg }
    set ::moni::M(FileError) 0
    ::moni::send $::moni::Cfg(name) "loading vendor.cfg\r"
    .testInfoDlg.labf2.t fastinsert end "loading vendor.cfg...\n"

    while {1} {
        for {set i 0} {$i<60} {incr i} {
            catch { .testInfoDlg.labf2.t fastinsert end "." }
            catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
    		if {$::moni::M(VendorCfgLoaded) == 1} {
    			break
            }
            if {$::moni::M(FileError) == 1} {
                ::moni::vendorcfg_check
                return
            }
            ::moni::wait 1000
    	}

        if {$::moni::M(VendorCfgLoaded) == 0} {
            ::moni::vendorcfg_check
            return
        } elseif {$::moni::M(VendorCfgLoaded) == 1} {
            catch { destroy .checkVendorCfgDlg }
            moni::addtestok
            moni::savelog "load vendor.cfg OK!\n"
            # 设置写vendor.cfg超时为2分钟
            for {set i 0} {$i<120} {incr i} {
                catch { .testInfoDlg.labf2.t fastinsert end "." }
                catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
        		if {$::moni::M(VendorCfgWrited) == 1} {
        			break
                }
                ::moni::wait 1000
        	}

            ::moni::write_vendor_cfg_result
            return
        }
    }
}


proc moni::nosimg_check {} {
    variable M
    variable Cfg
    update

    catch { destroy .checkNosimgDlg }
    toplevel .checkNosimgDlg

    wm withdraw .checkNosimgDlg
    update
    BWidget::place .checkNosimgDlg 500 160 center

    wm transient .checkNosimgDlg .
    wm title     .checkNosimgDlg "Please check the port connection!"
    wm deiconify .checkNosimgDlg
    wm resizable .checkNosimgDlg 0 0

    set win .checkNosimgDlg
    set f [frame $win.cfg]



    Label $win.label -text "  Can't load nos.img, please put nos.img to FTP server, then click “Confirm”!" \
        -font { 宋体 12 normal } -bg ForestGreen -fg white \
        -width 50 -anchor w	-justify left -relief sunken -wraplength 460

    place $win.label \
        -in $win -x 20 -y 20 -width 460 -height 80 -anchor nw \
        -bordermode ignore

    pack $f -side top

    button $win.but1 -text "Confirm" -font { 宋体 12 normal } -width 10 \
        -command {::moni::resend_load_img} -fg brown \
        -highlightthickness 0 -takefocus 0 -borderwidth 2
    button $win.but2 -text "Close" -font { 宋体 12 normal } -width 10 \
        -command {::moni::exit_after_nosimg_check} -fg brown -state normal \
        -highlightthickness 0 -takefocus 0 -borderwidth 2

    place $win.but1 \
        -in $win -x 130 -y 120 -anchor nw -bordermode ignore
    place $win.but2 \
        -in $win -x 270 -y 120 -anchor nw -bordermode ignore

    grab .checkNosimgDlg
}

proc moni::vendorcfg_check {} {
    variable M
    variable Cfg
    update

    catch { destroy .checkVendorCfgDlg }
    toplevel .checkVendorCfgDlg

    wm withdraw .checkVendorCfgDlg
    update
    BWidget::place .checkVendorCfgDlg 500 160 center

    wm transient .checkVendorCfgDlg .
    wm title     .checkVendorCfgDlg "Please check the port connection!"
    wm deiconify .checkVendorCfgDlg
    wm resizable .checkVendorCfgDlg 0 0

    set win .checkVendorCfgDlg
    set f [frame $win.cfg]



    Label $win.label -text "  Can't load vendor.cfg, please put vendor.cfg to FTP server, then click “Confirm”!" \
        -font { 宋体 12 normal } -bg ForestGreen -fg white \
        -width 50 -anchor w	-justify left -relief sunken -wraplength 460

    place $win.label \
        -in $win -x 20 -y 20 -width 460 -height 80 -anchor nw \
        -bordermode ignore

    pack $f -side top

    button $win.but1 -text "Confirm" -font { 宋体 12 normal } -width 10 \
        -command {::moni::resend_load_vendorcfg} -fg brown \
        -highlightthickness 0 -takefocus 0 -borderwidth 2
    button $win.but2 -text "Close" -font { 宋体 12 normal } -width 10 \
        -command {::moni::exit_after_vendorcfg_check} -fg brown -state normal \
        -highlightthickness 0 -takefocus 0 -borderwidth 2

    place $win.but1 \
        -in $win -x 130 -y 120 -anchor nw -bordermode ignore
    place $win.but2 \
        -in $win -x 270 -y 120 -anchor nw -bordermode ignore

    grab .checkVendorCfgDlg
}

proc moni::exit_after_nosimg_check {} {

    catch { destroy .checkNosimgDlg }
    set ::moni::M(ErrorFound) 1
    set ::moni::M(ERROR_CODE) "T479"
    moni::addtesterr
    moni::saveerrlog "load nos.img FAILED!\n"
    moni::savelog "load nos.img FAILED!\n"
    ::moni::get_result
}

proc moni::exit_after_vendorcfg_check {} {

    catch { destroy .checkVendorCfgDlg }
    set ::moni::M(ErrorFound) 1
    set ::moni::M(ERROR_CODE) "T479"
    moni::addtesterr
    moni::saveerrlog "load vendor.cfg FAILED!\n"
    moni::savelog "load vendor.cfg FAILED!\n"
    ::moni::get_result
}

proc moni::send_load_img {} {
    set ::moni::M(FileError) 0
    ::moni::send $::moni::Cfg(name) "loading nos.img\r"
    .testInfoDlg.labf2.t fastinsert end "loading nos.img...\n"
    .testInfoDlg.labf2.t yview 10000        ;#ctext显示到10000行

    for {set i 0} {$i<60} {incr i} {
        catch { .testInfoDlg.labf2.t fastinsert end "." }
        catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
		if {$::moni::M(ImageLoaded) == 1} {
			break
        }
        if {$::moni::M(FileError) == 1} {
            ::moni::nosimg_check
            return
        }
        ::moni::wait 1000
	}

    if {$::moni::M(ImageLoaded) == 0} {
        ::moni::nosimg_check
    } elseif {$::moni::M(ImageLoaded) == 1} {
        catch { destroy .checkNosimgDlg }
        moni::addtestok
        moni::savelog "load nos.img OK!\n"
        # 设置写nos.img超时为10分钟
        for {set i 0} {$i<600} {incr i} {
            catch { .testInfoDlg.labf2.t fastinsert end "." }
            catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
    		if {$::moni::M(ImageWrited) == 1} {
    			break
            }
            ::moni::wait 1000
    	}

        ::moni::write_img_result
    }
}

proc moni::send_load_vendor_cfg {} {
    set ::moni::M(FileError) 0
    ::moni::send $::moni::Cfg(name) "loading vendor.cfg\r"
    .testInfoDlg.labf2.t fastinsert end "loading vendor.cfg...\n"
    .testInfoDlg.labf2.t yview 10000        ;#ctext显示到10000行

    for {set i 0} {$i<60} {incr i} {
        catch { .testInfoDlg.labf2.t fastinsert end "." }
        catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
		if {$::moni::M(VendorCfgLoaded) == 1} {
			break
        }
        if {$::moni::M(FileError) == 1} {
            ::moni::vendorcfg_check
            return
        }
        ::moni::wait 1000
	}

    if {$::moni::M(VendorCfgLoaded) == 0} {
        ::moni::vendorcfg_check
    } elseif {$::moni::M(VendorCfgLoaded) == 1} {
        catch { destroy .checkVendorCfgDlg }
        moni::addtestok
        moni::savelog "加载vendor.cfg成功!\n"
        # 设置写vendor.cfg超时为2分钟
        for {set i 0} {$i<120} {incr i} {
            catch { .testInfoDlg.labf2.t fastinsert end "." }
            catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
    		if {$::moni::M(VendorCfgWrited) == 1} {
    			break
            }
            ::moni::wait 1000
    	}

        ::moni::write_vendor_cfg_result
    }
}

proc moni::send_write_boot {} {
	set ::moni::M(OverWrite) 0
    ::moni::send $::moni::Cfg(name) "write boot.rom\r"
}

proc moni::send_write_img {} {
	set ::moni::M(OverWrite) 0
    ::moni::send $::moni::Cfg(name) "write nos.img\r"
}

proc moni::send_write_vendor_cfg {} {
	set ::moni::M(OverWrite) 0
    ::moni::send $::moni::Cfg(name) "suwrite vendor.cfg\r"
}

proc moni::write_boot_result {} {
    if {$::moni::M(BootWrited) == 0} {
        tk_messageBox -message "Write boot.rom FAILED!"
        ::moni::wait 2000
        moni::addtesterr
        set ::moni::M(ErrorFound) 1
        ::moni::saveerrlog "Write boot.rom FAILED!\n"
        ::moni::savelog "Write boot.rom FAILED!\n"
        if {$::moni::M(Manufactory) == "01"} {
            set ::moni::M(HandleString) 0
            set ::moni::M(ERROR_CODE) "T478"
            ::moni::get_result
            return
        }
        ::moni::get_result
    } elseif {$::moni::M(BootWrited) == 1} {

    }
}

proc moni::write_img_result {} {
    if {$::moni::M(ImageWrited) == 0} {
        tk_messageBox -message "Write nos.img FAILED!"
        ::moni::wait 2000
        moni::addtesterr
        set ::moni::M(ErrorFound) 1
        ::moni::saveerrlog "Write nos.img FAILED!\n"
        ::moni::savelog "Write nos.img FAILED!\n"
        if {$::moni::M(Manufactory) == "01"} {
            set ::moni::M(HandleString) 0
            set ::moni::M(ERROR_CODE) "T478"
            ::moni::get_result
            return
        }
        ::moni::get_result
    } elseif {$::moni::M(ImageWrited) == 1} {
      if {$::moni::M(Producer) != "01"} {
        ::moni::get_result
        }
    }
}

proc moni::write_vendor_cfg_result {} {
    if {$::moni::M(VendorCfgWrited) == 0} {
        tk_messageBox -message "Write vendor.cfg FAILED!"
        ::moni::wait 2000
        moni::addtesterr
        set ::moni::M(ErrorFound) 1
        ::moni::saveerrlog "Write vendor.cfg FAILED!\n"
        ::moni::savelog "Write vendor.cfg FAILED!\n"
        if {$::moni::M(Manufactory) == "01"} {
            set ::moni::M(HandleString) 0
            set ::moni::M(ERROR_CODE) "T478"
            ::moni::get_result
            return
        }
        ::moni::get_result
    } elseif {$::moni::M(VendorCfgWrited) == 1} {
        ::moni::get_result
    }
}

proc moni::send_run_testimg {} {
    set ::moni::M(FileError) 0
    if {$::moni::M(BoardTypeNum) == 21 || $::moni::M(BoardTypeNum) == 85} {
        #tk_messageBox -message "请拔出和PC机相连的网线，插上环回网线、光纤和背板上的环接头，然后点击“确定”!"
        #不再提示，在初测准备中插好线再进行测试
        #tk_messageBox -message "Please insert all the twisted-pair/fiber/self-loop, then click “Confirm”!"
    }
    if {$::moni::M(TestType) == "F/T" } {
        if {$::moni::M(BoardTypeNum) == 0 || $::moni::M(BoardTypeNum) == 0 \
            || $::moni::M(BoardTypeNum) == 0} {
            if {$::moni::M(AllCableOut) == 0} {
                set ::moni::M(AllCableOut) 1
                tk_messageBox -message "$moni::MSG(send_run_testimg_msg)"
            }
        }
    }

    set ::moni::M(TestImageStart) 1

#产测优化后产测img和正式img已经整合到一起，不需要再“@”加载到内存了
#    #Modified by gujunqi: 9800的产测img和主机img已经整合在一起，不需要通过“@”加载到内存测试。
#    if {$::moni::M(BoardTypeNum) != 128 && $::moni::M(BoardTypeNum) != 129 && $::moni::M(BoardTypeNum) != 131 \
#        && $::moni::M(BoardTypeNum) != 132 && $::moni::M(BoardTypeNum) != 134 \
#        && $::moni::M(BoardTypeNum) != 199 && $::moni::M(BoardTypeNum) != 200} {
#        ::moni::send $::moni::Cfg(name) "@\r"
#    }
}

proc moni::resend_run_testimg {} {
    set ::moni::M(FileError) 0
    catch { destroy .checkFileDlg }

    set ::moni::M(TestImageStart) 1
    ::moni::send $::moni::Cfg(name) "@\r"
    ::moni::wait_run
}

proc moni::exit_after_filecheck {} {

    catch { destroy .checkFileDlg }
    set ::moni::M(ErrorFound) 1
    set ::moni::M(ERROR_CODE) "T479"
    moni::addtesterr
    moni::saveerrlog "load VxWorks_Release FAILED!\n"
    moni::savelog "load VxWorks_Release FAILED!\n"
    ::moni::get_result
}

proc moni::filecheck {} {
    variable M
    variable Cfg
    update

    toplevel .checkFileDlg

    wm withdraw .checkFileDlg
    update
    BWidget::place .checkFileDlg 500 160 center

    wm transient .checkFileDlg .
    wm title     .checkFileDlg "Please check the port connection!"
    wm deiconify .checkFileDlg
    wm resizable .checkFileDlg 0 0

    set win .checkFileDlg
    set f [frame $win.cfg]



    Label $win.label -text "  Can't load VxWorks_Release, please put VxWorks_Release to FTP server, then click “Confirm”!" \
        -font { 宋体 12 normal } -bg ForestGreen -fg white \
        -width 50 -anchor w	-justify left -relief sunken -wraplength 460

    place $win.label \
        -in $win -x 20 -y 20 -width 460 -height 80 -anchor nw \
        -bordermode ignore

    pack $f -side top

    button $win.but1 -text "Confirm" -font { 宋体 12 normal } -width 10 \
        -command {::moni::resend_run_testimg} -fg brown \
        -highlightthickness 0 -takefocus 0 -borderwidth 2
    button $win.but2 -text "Close" -font { 宋体 12 normal } -width 10 \
        -command {::moni::exit_after_filecheck} -fg brown -state normal \
        -highlightthickness 0 -takefocus 0 -borderwidth 2

    place $win.but1 \
        -in $win -x 130 -y 120 -anchor nw -bordermode ignore
    place $win.but2 \
        -in $win -x 270 -y 120 -anchor nw -bordermode ignore

    grab .checkFileDlg
}

proc moni::exit_after_unknownfilecheck {} {

    catch { destroy .checkUnFileDlg }
    set ::moni::M(ErrorFound) 1
    set ::moni::M(ERROR_CODE) "T479"
    moni::addtesterr
    moni::saveerrlog "Wrong VxWorks_Release file!\n"
    moni::savelog "Wrong VxWorks_Release file!\n"
    ::moni::get_result
}

proc moni::unknownfilecheck {} {
    variable M
    variable Cfg
    update

    toplevel .checkUnFileDlg

    wm withdraw .checkUnFileDlg
    update
    BWidget::place .checkUnFileDlg 500 160 center

    wm transient .checkUnFileDlg .
    wm title     .checkUnFileDlg "Wrong VxWorks_Release file!\n"
    wm deiconify .checkUnFileDlg
    wm resizable .checkUnFileDlg 0 0

    set win .checkUnFileDlg
    set f [frame $win.cfg]



    Label $win.label -text "  please put VxWorks_Release to FTP server, then click “Close”!" \
        -font { 宋体 12 normal } -bg ForestGreen -fg white \
        -width 50 -anchor w	-justify left -relief sunken -wraplength 460

    place $win.label \
        -in $win -x 20 -y 20 -width 460 -height 80 -anchor nw \
        -bordermode ignore

    pack $f -side top

    button $win.but1 -text "Close" -font { 宋体 12 normal } -width 10 \
        -command {::moni::exit_after_unknownfilecheck} -fg brown -state normal \
        -highlightthickness 0 -takefocus 0 -borderwidth 2

    place $win.but1 \
        -in $win -x 200 -y 120 -anchor nw -bordermode ignore

    grab .checkUnFileDlg
}

#add by duzqa 131028
proc moni::wait_Script {num} {
	set fend ".txt"
	set filename [format "业务端口测试脚本%d%s" $num $fend]
	set fileExists [ file exists $filename ]
	if { 0 == $fileExists } {
	    tk_messageBox -message [format "No File: %s !" $filename]
		return 1
	}

	#打开文件
	set file [ open $filename r]
	::moni::term_clear
	#（选环读取）
	set empLine 0
	while { [eof $file] != 1 } {
	    gets $file line

		set empLine 0
		#set line [string trim $line]
		if { [string length $line] < 1 } {
            continue
		}
		#moni::messageInfo "$line"
		#提取全局变量的名字
		set name [ string range $line 0 end ]
		::moni::send $::moni::Cfg(name) "$name\n"
		::moni::wait 1000
	}
	#关闭文件
	#set ::moni::M(TEST_VER)         $moni::MSG(TEST_VERSION) 
	close $file	
}
proc moni::wait_PortTest {} {
	set i 1
	while { $i <= 1 } {
		::moni::wait_Script $i
		incr i
	}
}

proc moni::wait_PortLedTest {} {
	set ans [tk_messageBox -message "开始进行端口LED灯测试，请点击“确认”后开始进行LED全亮测试！" -type okcancel -icon info]
	switch -- $ans {
		ok ::moni::wait_PortLedLightOn
		cancel {
			set ::moni::M(ErrorFound) 1
			::moni::get_result
		}
	}
}
proc moni::wait_PortLedLightOn {} {
	::moni::wait 1000
	::moni::send $::moni::Cfg(name) "mantest portled on\n"
	::moni::wait 1000
	if { $::moni::M(BoardType) != "S4200-28P-P-SI" } {
		::moni::send $::moni::Cfg(name) "mantest diagled on\n"
		::moni::wait 1000
	}
	if { $::moni::M(BoardType) == "S5750E-52X-SI" \
			|| $::moni::M(BoardType) == "CS6200-52X-EI" \
			|| $::moni::M(BoardType) == "S5750E-28X-SI" \
			|| $::moni::M(BoardType) == "S5750E-28C-SI" \
			|| $::moni::M(BoardType) == "S5750E-28X-P-SI" \
			|| $::moni::M(BoardType) == "CS6200-28X-P-EI" \
			|| $::moni::M(BoardType) == "CS6200-28X-EI"  } {

		set ans [tk_messageBox -message "请检查所有的LED灯是否全亮(不用检查网管口灯)，若是请点击”确认“接着测试，若不是请取消重新断电测试！" -type okcancel -icon info]
	} elseif { $::moni::M(BoardType) == "S4200-28P-P-SI" } {
		set ans [tk_messageBox -message "请检查所有的Link/Act和POWER的LED灯是否全亮绿灯，若是请点击”确认“接着测试，若不是请取消重新断电测试！" -type okcancel -icon info]
	} else {

		set ans [tk_messageBox -message "请检查所有的LED灯是否全亮，若是请点击”确认“接着测试，若不是请取消重新断电测试！" -type okcancel -icon info]

	}
	switch -- $ans {
		ok {
			if { $::moni::M(BoardType) == "S4200-28P-P-SI" } {
				::moni::send $::moni::Cfg(name) "mantest portled yellowon\n"
				::moni::wait 1000
				set ans [tk_messageBox -message "请检查所有的LED灯是否全亮黄灯(不用检查POWER灯)，若是请点击”确认“接着测试，若不是请取消重新断电测试！" -type okcancel -icon info]
				switch -- $ans {		
					ok ::moni::wait_PortLedLightOff
					cancel {
						set ::moni::M(ErrorFound) 1
						::moni::get_result
					}				
				}
			} else {
				::moni::wait_PortLedLightOff
			}
		}
		cancel {
			set ::moni::M(ErrorFound) 1
			::moni::get_result
		}
	}
}

proc moni::wait_PortLedLightOff {} {
	::moni::wait 1000
	::moni::send $::moni::Cfg(name) "mantest portled off\n"
	::moni::wait 1000
	if { $::moni::M(BoardType) != "S4200-28P-P-SI" } {
		::moni::send $::moni::Cfg(name) "mantest diagled off\n"
		::moni::wait 1000	
	}
	if { $::moni::M(BoardType) == "SNR-S2985G-24T-UPS" \
		|| $::moni::M(BoardType) == "SNR-S2965-24T" } {

		set ans [tk_messageBox -message "请检查所有的LED灯是否全灭(不用检查POWER灯以及RPS灯)，若是请点击”确认“接着测试，若不是请取消重新断电测试！" -type okcancel -icon info]

	} elseif { $::moni::M(BoardType) == "S5750E-28X-P-SI" || $::moni::M(BoardType) == "CS6200-28X-P-EI" } {

		set ans [tk_messageBox -message "请检查所有的LED灯是否全灭(不用检查POWER灯、POE灯以及网管口灯)，若是请点击”确认“接着测试，若不是请取消重新断电测试！" -type okcancel -icon info]
	
	} elseif { $::moni::M(BoardType) == "S5750E-52X-SI" \
			|| $::moni::M(BoardType) == "CS6200-52X-EI" \
			|| $::moni::M(BoardType) == "S5750E-28X-SI" \
			|| $::moni::M(BoardType) == "S5750E-28C-SI" \
			|| $::moni::M(BoardType) == "CS6200-28X-EI"  } {

		set ans [tk_messageBox -message "请检查所有的LED灯是否全灭(不用检查POWER灯以及网管口灯)，若是请点击”确认“接着测试，若不是请取消重新断电测试！" -type okcancel -icon info]
	} else {

		set ans [tk_messageBox -message "请检查所有的LED灯是否全灭(不用检查POWER灯)，若是请点击”确认“接着测试，若不是请取消重新断电测试！" -type okcancel -icon info]
	}
	switch -- $ans {		
		ok {
			if { $::moni::M(BoardType) == "S5750E-52X-SI" \
					|| $::moni::M(BoardType) == "CS6200-52X-EI" \
					|| $::moni::M(BoardType) == "S5750E-28X-P-SI" \
					|| $::moni::M(BoardType) == "S5750E-28X-SI" \
					|| $::moni::M(BoardType) == "S5750E-28C-SI" \
					|| $::moni::M(BoardType) == "CS6200-28X-P-EI" \
					|| $::moni::M(BoardType) == "CS6200-28X-EI"  } {
			::moni::wait_FanCtrlTest
			} elseif { $::moni::M(BoardType) == "S4600-28P-P-SI" \
						|| $::moni::M(BoardType) == "S4200-28P-P-SI" } {
			::moni::wait_FanTest
			} else {
			::moni::wait_ResetButtonTest
			}
		}
		cancel {
			set ::moni::M(ErrorFound) 1
			::moni::get_result
		}				
	}
}

proc moni::wait_FanCtrlTest {} {
	::moni::wait 1000
	::moni::send $::moni::Cfg(name) "mantest fanspeed low\n"
	set ans [tk_messageBox -message "请检查风扇是否低速转动，若是请点击”确认“接着测试，若不是请取消重新断电测试！" -type okcancel -icon info]
	switch -- $ans {
		ok {
			::moni::wait 1000
			::moni::send $::moni::Cfg(name) "mantest fanspeed high\n"
			set ans [tk_messageBox -message "请检查风扇是否高速转动，若是请点击”确认“接着测试，若不是请取消重新断电测试！" -type okcancel -icon info]
			switch -- $ans {
				ok ::moni::wait_ResetButtonTest
				cancel {
				set ::moni::M(ErrorFound) 1
				::moni::get_result
				}
			}
		}
		cancel {
			set ::moni::M(ErrorFound) 1
			::moni::get_result
		}
	}
}

proc moni::wait_FanTest {} {	
	set ans [tk_messageBox -message "请检查风扇是否在转动，若是请点击”确认“接着测试，若不是请取消重新断电测试！" -type okcancel -icon info]
	switch -- $ans {
		ok ::moni::wait_ResetButtonTest
		cancel {
			set ::moni::M(ErrorFound) 1
			::moni::get_result
		}
	}
}


proc moni::wait_ResetButtonTest {} {

	if {$::moni::M(TestType) == "F/T"} {
		if { $::moni::M(BoardType) == "S4200-28P-SI" \
			|| $::moni::M(BoardType) == "S4200-28P-P-SI" } {
			::moni::send $::moni::Cfg(name) "mantest portled normal\n"
			::moni::wait 1000
			::moni::delete_mantestimg_and_log
			::moni::update_nosimg
		}
			
		::moni::send $::moni::Cfg(name) "en\n"
		::moni::wait 2000
		 ::moni::send $::moni::Cfg(name) "boot img flash:/nos.img primary\n"
	}

	if { $::moni::M(BoardType) == "SNR-S2985G-24T-UPS" \
		|| $::moni::M(BoardType) == "SNR-S2965-24T" \
		|| $::moni::M(BoardType) == "SNR-S2985G-8T-POE" \
		|| $::moni::M(BoardType) == "S4200-28P-SI" \
		|| $::moni::M(BoardType) == "S4200-28P-P-SI" } {
		
		if {$::moni::M(TestType) == "P/T"} {
			::moni::send $::moni::Cfg(name) "mantest aging start\n"
			::moni::wait_result_string "Aging test" "mantest aging start FAILED!!" 60
			::moni::send $::moni::Cfg(name) "mantest aging timeset $::moni::M(AgingTime)\n"
			::moni::wait_result_string "Aging test" "mantest aging timeset FAILED!!" 10

			::moni::test_end

			return 
		} else {
			::moni::send $::moni::Cfg(name) "reload\r"
			::moni::wait 3000
			::moni::send $::moni::Cfg(name) "y\r"
		}
		
	} else {
		set ::moni::M(GetMantest) 0
		set ans [tk_messageBox -message "请按下复位键并松开，然后3秒内点击确定！" -type okcancel -icon info]
	}


	::moni::wait 5000
	::moni::term_clear
	::moni::wait 3000

	if {$::moni::M(TestType) == "P/T"} {
		::moni::wait_mantest
	} else {

		if { $::moni::M(BoardType) == "SNR-S2985G-24T-UPS" \
			|| $::moni::M(BoardType) == "SNR-S2965-24T" \
			|| $::moni::M(BoardType) == "SNR-S2985G-8T-POE" } {
			::moni::wait_SNRnosimg
		} else {
			::moni::wait_nosimg
		}
		
		if {$::moni::M(ErrorFound) == 1} {
            return
        }
	}

	if {$::moni::M(GetMantest) == 1} {
		set ::moni::M(GetMantest) 0
		::moni::send $::moni::Cfg(name) "\x0A"

		if {$::moni::M(TestType) == "P/T"} {
			::moni::send $::moni::Cfg(name) "mantest aging start\n"
			::moni::wait_result_string "Aging test" "mantest aging start FAILED!!" 60
			::moni::send $::moni::Cfg(name) "mantest aging timeset $::moni::M(AgingTime)\n"
			::moni::wait_result_string "Aging test" "mantest aging timeset FAILED!!" 10
		} else {
			if { $::moni::M(BoardType) == "S5750E-52X-SI" \
				|| $::moni::M(BoardType) == "CS6200-52X-EI" \
				|| $::moni::M(BoardType) == "S5750E-28X-P-SI" \
				|| $::moni::M(BoardType) == "S5750E-28X-SI" \
				|| $::moni::M(BoardType) == "S5750E-28C-SI" \
				|| $::moni::M(BoardType) == "CS6200-28X-P-EI" \
				|| $::moni::M(BoardType) == "CS6200-28X-EI" } {
				::moni::send $::moni::Cfg(name) "en\n"
				::moni::wait 500
				::moni::send $::moni::Cfg(name) "config\n"
				::moni::wait 500
				::moni::send $::moni::Cfg(name) "interface ethernet 0\n"
				::moni::wait 500
				::moni::send $::moni::Cfg(name) "ip address 192.168.1.1 255.255.255.0\n"
				::moni::wait 1000
				::moni::send $::moni::Cfg(name) "quit\n"
				::moni::wait 100
				::moni::send $::moni::Cfg(name) "quit\n"
				::moni::wait 500
				::moni::send $::moni::Cfg(name) "ping 192.168.1.66\n"

				if { [::moni::wait_string {Success rate}] == 1 } {
					set ans [tk_messageBox -message "请检查网管口灯是否闪烁，PC是否有回复，若是请点击”确认“接着测试，若不是请取消并记录网管口错误！" -type okcancel -icon info]
					switch -- $ans { 
						ok {
							::moni::savelog "MANAGE PORT TEST OK"
							::moni::addtestok
						}
						cancel {
							::moni::saveerrlog "MANAGE PORT TEST ERROR"
							::moni::addtesterr
							::moni::get_result
							tk_messageBox -message "$moni::MSG(manage_port_test_error_msg)" -icon error
						}
						
					}
				}
			}
		}

		::moni::test_end
	} else {
		tk_messageBox -message "复位键测试失败！" -type ok -icon error
		set ::moni::M(ErrorFound) 1
		::moni::get_result
		return
	}	
}


proc moni::wait_string { string } {
	set name $::moni::Cfg(name)
	set i 0
	::moni::wait 1000

	while {1} {

		set testResChk [string first $string $::moni::M(RecvBufAll.$name)]	
		if { $testResChk > 0 } {
			return 1
		} 

		::moni::wait 1000
		
		incr i

		#等待1分钟
		if { $i > 60 } {
		    set ::moni::M(ErrorFound) 1
		    return 0
		}
	}
}

proc moni::wait_return_string { rstring } {
	set name $::moni::Cfg(name)
	set i 0
	::moni::wait 1000

	set testok $rstring
	set testerror $rstring

	append testok " TEST OK"
	append testerror " TEST ERROR"

	while {1} {

		set testResChk [string first $testok $::moni::M(RecvBufAll.$name)]	
		if { $testResChk > 0 } {
			return 1
		} 

		set testResChk [string first $testerror $::moni::M(RecvBufAll.$name)]	
		if { $testResChk > 0 } {
			return 0
		} 

		::moni::wait 1000
		
		incr i

		#等待3分钟
		if { $i > 180 } {
		    return 0
		}
	}
}

proc moni::wait_FirstTest {} {
	::moni::reinit 
	::moni::wait 3000
	set name $::moni::Cfg(name)
	
	if { $::moni::M(BoardType) == "SNR-S2985G-24T-UPS" } {

		tk_messageBox -message "请接上DC蓄电池，使用万用表量测电压约为13V，再拔掉AC电源线，以上完成请按确认!"
		::moni::wait 3000
		set ans [tk_messageBox -message "请检查POWER灯是否亮着，若不是请取消重新断电测试！" -type okcancel -icon info]
		switch -- $ans {
			ok {
				moni::savelog "DC TEST OK"
				::moni::addtestok
			}
			cancel {
				moni::saveerrlog "DC TEST ERROR"
				::moni::addtesterr
				::moni::get_result
				return 0
			}
		}

		::moni::send $name "\x0A"
		::moni::send $name "mantest item rpsStatus\n"
		if {[::moni::wait_return_string {RPS}] == 1 } {
			moni::savelog "UPS TEST OK"
			::moni::addtestok
		} else {
			moni::saveerrlog "UPS TEST ERROR"
			::moni::addtesterr
			::moni::get_result
			tk_messageBox -message "$moni::MSG(ups_test_error_msg)" -icon error
			return 0
		}
	}

	if { $::moni::M(BoardType) == "SNR-S2965-24T" } {

		tk_messageBox -message "请接上12V DC电源，再拔掉AC电源线，以上完成请按确认!"
		::moni::wait 3000
		set ans [tk_messageBox -message "请检查POWER灯是否亮着，若不是请取消重新断电测试！" -type okcancel -icon info]
		switch -- $ans {
			ok {
				moni::savelog "DC TEST OK"
				::moni::addtestok
			}
			cancel {
				moni::saveerrlog "DC TEST ERROR"
				::moni::addtesterr
				::moni::get_result
				return 0
			}
		}
	}

	::moni::send $name "\x0A"
	::moni::send $name "mantest item memsize\n"
	if {[::moni::wait_return_string {MEMORY SIZE}] == 1 } {
		moni::savelog "MEMSIZE TEST OK"
		::moni::addtestok
	} else {
		moni::saveerrlog "MEMSIZE TEST ERROR"
		::moni::addtesterr
		::moni::get_result
		tk_messageBox -message "$moni::MSG(memsize_test_error_msg)" -icon error
		return 0
	}
	
	#::moni::reinit 
	::moni::wait 3000
	::moni::send $name "\x0A"
	::moni::send $name "mantest item flash\n"
	if {[::moni::wait_return_string {FLASH}] == 1 } {
		moni::savelog "FLASH TEST OK"
		::moni::addtestok
	} else {
		moni::saveerrlog "FLASH TEST ERROR"
		::moni::addtesterr
		::moni::get_result
		tk_messageBox -message "$moni::MSG(flash_test_error_msg)" -icon error
		return 0
	}

	if { $::moni::M(BoardType) == "S5750E-52X-SI" \
		|| $::moni::M(BoardType) == "CS6200-52X-EI" \
		|| $::moni::M(BoardType) == "S5750E-28X-P-SI" \
		|| $::moni::M(BoardType) == "S5750E-28X-SI" \
		|| $::moni::M(BoardType) == "S5750E-28C-SI" \
		|| $::moni::M(BoardType) == "CS6200-28X-P-EI" \
		|| $::moni::M(BoardType) == "CS6200-28X-EI" } {
		::moni::wait 3000
		::moni::send $name "\x0A"
		::moni::send $name "mantest item nandflash\n"
		if {[::moni::wait_return_string {NANDFLASH}] == 1 } {
			moni::savelog "NANDFLASH TEST OK"
			::moni::addtestok
		} else {
			moni::saveerrlog "NANDFLASH TEST ERROR"
			::moni::addtesterr
			::moni::get_result
			tk_messageBox -message "$moni::MSG(nandflash_test_error_msg)" -icon error
			return 0
		}
		
		::moni::wait 3000
		::moni::send $name "\x0A"
		::moni::send $name "mantest item usb\n"
		if {[::moni::wait_return_string {USB}] == 1 } {
			moni::savelog "USB TEST OK"	
			::moni::addtestok
		} else {
			moni::saveerrlog "USB TEST ERROR"
			::moni::addtesterr
			::moni::get_result
			tk_messageBox -message "$moni::MSG(usb_test_error_msg)" -icon error
			return 0
		}

		::moni::wait 3000
		::moni::send $name "\x0A"
		::moni::send $name "mantest item rtc\n"
		if {[::moni::wait_return_string {RTC}] == 1 } {
			moni::savelog "RTC TEST OK"
			::moni::addtestok
		} else {
			moni::saveerrlog "RTC TEST ERROR"
			::moni::addtesterr
			::moni::get_result
			tk_messageBox -message "$moni::MSG(rtc_test_error_msg)" -icon error
			return 0
		}

		::moni::wait 3000
		::moni::send $name "\x0A"
		::moni::send $name "mantest item temp\n"
		if {[::moni::wait_return_string {TEMP}] == 1 } {
			moni::savelog "TEMP TEST OK"
			::moni::addtestok
		} else {
			moni::saveerrlog "TEMP TEST ERROR"
			::moni::addtesterr
			::moni::get_result
			tk_messageBox -message "$moni::MSG(temp_test_error_msg)" -icon error
			return 0
		}
	}

	if { $::moni::M(BoardType) == "S4600-28P-P-SI" } {
		::moni::wait 3000
		::moni::send $name "\x0A"
		::moni::send $name "mantest item temp\n"
		if {[::moni::wait_return_string {TEMP}] == 1 } {
			moni::savelog "TEMP TEST OK"
			::moni::addtestok
		} else {
			moni::saveerrlog "TEMP TEST ERROR"
			::moni::addtesterr
			::moni::get_result
			tk_messageBox -message "$moni::MSG(temp_test_error_msg)" -icon error
			return 0
		}
	}

	::moni::wait 3000
	::moni::send $name "\x0A"
	::moni::send $name "mantest item memory\n"
	if {[::moni::wait_return_string {MEMORY}] == 1 } {
		moni::savelog "MEMORY TEST OK"
		::moni::addtestok
	} else {
		moni::saveerrlog "MEMORY TEST ERROR"
		::moni::addtesterr
		::moni::get_result
		tk_messageBox -message "$moni::MSG(memory_test_error_msg)" -icon error
		return 0
	}
	

	if { $::moni::M(BoardType) == "S4600-10P-P-SI" \
		|| $::moni::M(BoardType) == "S4600-28P-P-SI" \
		|| $::moni::M(BoardType) == "SNR-S2965-24T" \
		|| $::moni::M(BoardType) == "S4600-28P-SI" \
		|| $::moni::M(BoardType) == "SNR-S2985G-24T-UPS" \
		|| $::moni::M(BoardType) == "S4600-28C-SI" \
		|| $::moni::M(BoardType) == "SNR-S2985G-8T-POE" \
		|| $::moni::M(BoardType) == "S4200-28P-SI" \
		|| $::moni::M(BoardType) == "S4200-28P-P-SI" } {
		#::moni::reinit 
		::moni::wait 3000
		::moni::send $name "\x0A"
		::moni::send $name "mantest item smi\n"
		if {[::moni::wait_return_string {SMI}] == 1 } {
			moni::savelog "SMI TEST OK"
			::moni::addtestok
		} else {
			moni::saveerrlog "SMI TEST ERROR"
			::moni::addtesterr
			::moni::get_result
			tk_messageBox -message "$moni::MSG(smi_test_error_msg)" -icon error
			return 0
		}
	}

	if { $::moni::M(BoardType) == "S4600-10P-P-SI" \
		|| $::moni::M(BoardType) == "CS6200-28X-P-EI" \
		|| $::moni::M(BoardType) == "S5750E-28X-P-SI"} {
		tk_messageBox -message "POE测试，请确保电口和PD设备一一对接后点击确定!"
		#::moni::reinit 
		::moni::wait 3000
		::moni::send $name "\x0A"
		::moni::send $name "mantest poe on\n"
		if {[::moni::wait_return_string {POE ON}] == 1 } {
			moni::savelog "POE ON TEST OK"
			::moni::addtestok
		} else {
			moni::saveerrlog "POE ON TEST ERROR"
			::moni::addtesterr
			::moni::get_result
			tk_messageBox -message "$moni::MSG(poeon_test_error_msg)" -icon error
			return 0
		}
	}

	if { $::moni::M(BoardType) == "S4600-28P-P-SI" \
			|| $::moni::M(BoardType) == "S4200-28P-P-SI" } {
		tk_messageBox -message "POE测试，请确保电口1-12和PD设备一一对接后点击确定!"
		#::moni::reinit 
		::moni::wait 3000
		::moni::send $name "\x0A"
		::moni::send $name "mantest poe on 1to12\n"
		if {[::moni::wait_return_string {POE ON 1to12}] == 1 } {
			moni::savelog "POE ON TEST OK"
			::moni::addtestok
		} else {
			moni::saveerrlog "POE ON TEST ERROR"
			::moni::addtesterr
			::moni::get_result
			tk_messageBox -message "$moni::MSG(poeon_test_error_msg1)" -icon error
			return 0
		}

		tk_messageBox -message "POE测试，请确保电口13-24和PD设备一一对接后点击确定!"
		#::moni::reinit 
		::moni::wait 3000
		::moni::send $name "\x0A"
		::moni::send $name "mantest poe on 13to24\n"
		if {[::moni::wait_return_string {POE ON 13to24}] == 1 } {
			moni::savelog "POE ON TEST OK"
			::moni::addtestok
		} else {
			moni::saveerrlog "POE ON TEST ERROR"
			::moni::addtesterr
			::moni::get_result
			tk_messageBox -message "$moni::MSG(poeon_test_error_msg2)" -icon error
			return 0
		}
	}
	
	return 1
	
}

proc moni::wait_RepeatTest {} {
	set name $::moni::Cfg(name)
	
	tk_messageBox -message "端口流量测试，请确保端口两两对接环境正确后点击确定!"
	::moni::reinit 
	::moni::wait 3000
	set name $::moni::Cfg(name)
	::moni::send $name "\x0A"
	::moni::send $name "mantest item port\n"

	if {[::moni::wait_return_string {PORT}] == 1 } {
		moni::savelog "PORT TEST OK"
		::moni::addtestok
	} else {

		moni::saveerrlog "PORT TEST ERROR"
		::moni::addtesterr
		::moni::get_result
		tk_messageBox -message "$moni::MSG(port_test_error_msg)" -icon error
		return 0
	}

	#::moni::reinit 
	#::moni::wait 3000
	::moni::send $name "\x0A"
	::moni::send $name "mantest item sfpinfo\n"

	if {[::moni::wait_return_string {SFPINFO}] == 1 } {
		moni::savelog "SFPINFO TEST OK"
		::moni::addtestok
	} else {

		moni::saveerrlog "SFPINFO TEST ERROR"
		::moni::addtesterr
		::moni::get_result
		tk_messageBox -message "$moni::MSG(sfpinfo_test_error_msg)" -icon error
		return 0
	}

	if { $::moni::M(BoardType) == "S5750E-52X-SI" \
		|| $::moni::M(BoardType) == "CS6200-52X-EI" \
		|| $::moni::M(BoardType) == "S5750E-28X-P-SI" \
		|| $::moni::M(BoardType) == "S5750E-28X-SI" \
		|| $::moni::M(BoardType) == "S5750E-28C-SI" \
		|| $::moni::M(BoardType) == "CS6200-28X-P-EI" \
		|| $::moni::M(BoardType) == "CS6200-28X-EI" } {

		::moni::wait 3000
		::moni::send $name "\x0A"
		::moni::send $name "mantest item fastlink\n"
		if {[::moni::wait_return_string {FASTLINK}] == 1 } { 
			moni::savelog "FASTLINK TEST OK"
			::moni::addtestok
		} else {

			moni::saveerrlog "FASTLINK TEST ERROR"
			::moni::addtesterr
			::moni::get_result
			tk_messageBox -message "$moni::MSG(fastlink_test_error_msg)" -icon error
			return 0
		}
	}

	return 1

}


proc moni::wait_AgingTest {} {
	set name $::moni::Cfg(name)
	::moni::send $name "\x0A"
	::moni::send $name "mantest aging start\n"
	::moni::wait 2000
	set agingTestResChk [string first {You can not start aging test because first mantest is not pass} $::moni::M(RecvBufAll.$name)]
	if { $agingTestResChk >= 0 } {
		tk_messageBox -message "由于初测未通过，不能进行老化测试，请重新进行初测!" -icon error
	} else {
		#set ans [tk_messageBox -message "初测通过，请选择‘确认’后断电进行老化测试，否则选择‘取消’！"  -type okcancel -icon info]
		::moni::test_end
	}
}



proc moni::check_AgingResult {} {
	set name $::moni::Cfg(name)
	::moni::reinit 
	::moni::wait 3000
	::moni::send $name "\x0A"
	::moni::send $name "mantest aging getresult\n"
	if {[::moni::wait_return_string {AGING}] == 1 } {
		set  ::moni::M(GetAgingResult) 1
	} else {
		set  ::moni::M(GetAgingResult) 0 
	}
	
}
#end of add by duzqa
proc moni::wait_run {} {

    set name $::moni::Cfg(name)
    set FmtErrStr1 "File system DevCreate failed"
    set FmtErrStr2 "cd: error = 0xc0009"
    set UnFileErrStr "The current card is UNKNOWN"
    set vRun1 -1
    set vRun2 -1
    set vRun3 -1



    ::moni::test_hw
    return





    #设置超时报错，超时120秒
    for {set i 0} {$i<120} {incr i} {
        catch { .testInfoDlg.labf2.t fastinsert end "." }
        catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
        ::moni::wait 1000
        set vFmtErr1 [string first $FmtErrStr1 $::moni::M(RecvBufAll.$name)]
        set vFmtErr2 [string first $FmtErrStr2 $::moni::M(RecvBufAll.$name)]
        if {$::moni::M(FmtErrStrChecked) == 0} {
            if {$vFmtErr1 > 0 || $vFmtErr2 > 0} {
                set ::moni::M(FmtErrStrChecked) 1
                set ::moni::M(ErrorFound) 1
                moni::saveerrlog "$moni::MSG(wait_run_log1)"
                moni::savelog "$moni::MSG(wait_run_log1)"
                moni::addtesterr
                catch { .testInfoDlg.labf2.t fastinsert end "\n$moni::MSG(wait_run_log1)\n" }
                catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行
                tk_messageBox -message "$moni::MSG(wait_run_log1)"
                if {$::moni::M(Manufactory) == "01"} {
                    set ::moni::M(HandleString) 0
                    set ::moni::M(ERROR_CODE) "T452"
                    ::moni::get_result
        	        return
        	    }
            }

            set vRun3 [string first $UnFileErrStr $::moni::M(RecvBufAll.$name)]
            if {$vRun3 > 0} {
                ::moni::unknownfilecheck
                return
            }

        }

        if {$::moni::M(FileError) == 1} {
            break
        }

        set vRun1 [string first {[HwTest]:} $::moni::M(RecvBufAll.$name)]
        set vRun2 [string first {[manTest]:} $::moni::M(RecvBufAll.$name)]
        if {$vRun1>=0 || $vRun2>=0} {
            moni::addtestok
            moni::savelog "$moni::MSG(wait_run_log2)\n"

            if {$::moni::M(TestType) == "F/T" } {
                if {$::moni::M(BoardTypeNum) == 0  || $::moni::M(BoardTypeNum) == 0 \
                      || $::moni::M(BoardTypeNum) == 0} {
        	        tk_messageBox -message "$moni::MSG(wait_run_msg)"
        	    }
            }

            ::moni::test_hw
            return
        }
    }
    if {$vRun1<=0 && $vRun2<=0} {
        #tk_messageBox -message "不能运行测试软件，请将正确的VxWorks_Release放入FTP目录下!"
        ::moni::filecheck
        return
    }
}

proc moni::test_hw {} {
    ::moni::wait 5000

#初测开始时执行agingtest stop/agingtest cleartime/agingtest clearresult清除老化信息
    if {$::moni::M(TestType) == "P/T" } {
         #既然已经进入mantest，就没有必要进行aingtest stop
	     # ::moni::send $::moni::Cfg(name) "agingtest stop\r"
	     # ::moni::wait 500
	      ::moni::send $::moni::Cfg(name) "agingtest\r"
	      ::moni::wait 500
	      ::moni::send $::moni::Cfg(name) "cleartime\r"
	      ::moni::wait 500
	      ::moni::send $::moni::Cfg(name) "clearresult\r"
              ::moni::wait 500
              ::moni::send $::moni::Cfg(name) "exit\r"
#复测开始时执行agingtest gettime/agingtest getresult,捕捉老化时间和老化结果是否有错误
    } elseif {$::moni::M(TestType) == "F/T" } {
        #在这里需要做一个适当的等待，因为如果板卡进入了老化测试的话前面几项的测试结果需要清空才进行老化时间和结果的判断
        #否则老化的测试项的测试结果会影响复测时对老化测试时间和总的测试结果的判断，如果不进行等待的话老化的测试项的结果
        #不管是OK和ERR都会对复测造成影响
        ::moni::wait 10000
        ::moni::reinit
		::moni::send $::moni::Cfg(name) "agingtest \r"
		::moni::wait 500
        ::moni::send $::moni::Cfg(name) "gettime\r"

        ::moni::wait_aging

        if {$::moni::M(GetAging) == 1} {
            tk_messageBox -message "$moni::MSG(test_hw_msg1)"
            ::moni::wait 500
            set ::moni::M(ErrorFound) 1
            ::moni::get_result
            return
        }

        ::moni::wait 500
        ::moni::reinit
		::moni::send $::moni::Cfg(name) "agingtest \r"
		::moni::wait 500		
        ::moni::send $::moni::Cfg(name) "getresult\r"
		::moni::wait 500
        ::moni::send $::moni::Cfg(name) "exit \r"
		::moni::wait 500
	      ::moni::wait_aging
	      ::moni::wait_aging_detail
          if {$::moni::M(GetAging) == 1} {
              tk_messageBox -message "$moni::MSG(test_hw_msg2)"
              ::moni::wait 500
              set ::moni::M(ErrorFound) 1
              ::moni::get_result
        	  return
          }
          if {$::moni::M(GetAgingDetail) == 1} {
              tk_messageBox -message "$moni::MSG(test_hw_msg3)"
              ::moni::wait 500
              set ::moni::M(ErrorFound) 1
              ::moni::get_result
        	  return
          }
    }

    #9800_24SFP_PLUS卡, 初测之前需要对phy烧写微码
    if {$::moni::M(TestType) == "P/T" } {
    	if {$::moni::M(BoardTypeNum) == 138} {
    		::moni::wait 500
    		::moni::send $::moni::Cfg(name) "ucodedown\r"
    		::moni::wait 500
            catch { .testInfoDlg.labf2.t fastinsert end "\nNow Firmware unicode downloading..........\n" }
            catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext显示到10000行    		
    		moni::wait_ucode_download
    		if {$::moni::M(GetUcodeDownOK) == 1} {
    			set ::moni::M(GetUcodeDownOK) 0    			
    		} else {
    			return
    		}    	
    		::moni::wait 500
    	}
    	
    }
    
    # BEGIN: Added by jianghtc, 2010/01/26 任务[40676]
    if {$::moni::M(BoardTypeNum) == 128 || $::moni::M(BoardTypeNum) == 129 || $::moni::M(BoardTypeNum) == 131 \
        || $::moni::M(BoardTypeNum) == 132 || $::moni::M(BoardTypeNum) == 134 \
        || $::moni::M(BoardTypeNum) == 136 || $::moni::M(BoardTypeNum) == 137 \
        || $::moni::M(BoardTypeNum) == 138 || $::moni::M(BoardTypeNum) == 145 \
        || $::moni::M(BoardTypeNum) == 9 || $::moni::M(BoardTypeNum) == 73\
        || $::moni::M(BoardTypeNum) == 199 || $::moni::M(BoardTypeNum) == 200} {
        if {$::moni::M(BoardTypeNum) == 131 || $::moni::M(BoardTypeNum) == 132 \
            || $::moni::M(BoardTypeNum) == 134 || $::moni::M(BoardTypeNum) == 136 \
            || $::moni::M(BoardTypeNum) == 137 || $::moni::M(BoardTypeNum) == 138} {
            #不再提示，在初测准备中说明先插好线再进行测试
            #tk_messageBox -message "Please connect twisted-pair/fiber to the port in sequence(1 to 2, 3 to 4, etc.), then click “Confirm”!"
        } elseif {$::moni::M(BoardTypeNum) == 129 &&  $::moni::M(IsChassis) == 0} {
            #不再提示，在初测准备中说明先插好线再进行测试
            #tk_messageBox -message "Please connect twisted-pair/fiber to the port in sequence(1 to 2, 3 to 4, etc.), then click “Confirm”!"
        }
        ::moni::wait 5000
        ::moni::wait 5000
        ::moni::send $::moni::Cfg(name) "autotest\r"
    } else {
        if {$::moni::M(BoardTypeNum) != 16 } {
            #不再提示，在初测准备中说明先插好线再进行测试
            #tk_messageBox -message "Please connect twisted-pair/fiber to the port in sequence(1 to 2, 3 to 4, etc.), then click “Confirm”!"
        }
        ::moni::wait 12000;#Modified by jianghtc, 2010/04/01 bug[40611]
        ::moni::send $::moni::Cfg(name) "autotest\r"
    }
    # END:   Added by jianghtc, 2010/01/26 任务[40676]
}


proc moni::confirm_local01_set {} {

    ::moni::save_test_variable $::moni::M(LOCAL_01) "local_01:" $::moni::M(LOCAL_01)
    destroy .testlocal01Dlg
    update
}
proc moni::select_local_01 {} {
    toplevel .testlocal01Dlg

    wm withdraw .testlocal01Dlg
    update
    BWidget::place .testlocal01Dlg 400 200 center
    wm transient .testlocal01Dlg .
    wm title     .testlocal01Dlg "Local simulation"
    wm deiconify .testlocal01Dlg
    wm resizable .testlocal01Dlg 0 0

    set win .testlocal01Dlg

    LabelFrame $win.labf \
        -text TestType -font { 宋体 10 normal } -bg LightBlue -fg black  -side top \
                   -anchor w -relief groove -borderwidth 1

    place $win.labf \
        -in $win -x 50 -y 25 -width 300 -height 100 -anchor nw \
        -bordermode ignore

	set rad1 [radiobutton $win.labf.rad1 -text "local 01 simulation" \
	    -command {moni::set_is_local_01} \
	    -font { 宋体 12 normal } -bg LightBlue -fg blue -value en ]

    place $win.labf.rad1 \
        -in $win.labf -x 18 -y 30 -width 200 -height 30 -anchor nw \
        -bordermode ignore


    set rad2 [radiobutton $win.labf.rad2 -text "no local 01 simulation" \
        -command {moni::set_no_local_01} \
        -font { 宋体 12 normal } -bg LightBlue -fg blue -value fr]

    place $win.labf.rad2 \
        -in $win.labf -x 30 -y 60 -width 200 -height 30 -anchor nw \
        -bordermode ignore

    set bbox [ButtonBox $win.bbox -spacing 10 -padx 1 -pady 1]

    $bbox add -text "Close" -font { 宋体 12 normal } -fg brown -width 10 -height 1 \
        -command {::moni::confirm_local01_set} \
        -highlightthickness 0 -takefocus 0 -borderwidth 2 -padx 4 -pady 1
   # if {$::moni::M(TestType) == "local 01"} {
    #    $win.labf.rad1 select
    #} elseif {$::moni::M(TestType) == "no local 01"} {
    #    $win.labf.rad2 select
    #}
    place $win.bbox -in .testlocal01Dlg -x 150 -y 140 -width 100 -height 36 \
        -anchor nw -bordermode ignore

    grab .testlocal01Dlg
    focus -force .testlocal01Dlg
}

proc moni::set_is_local_01 {} {
    set ::moni::M(LOCAL_01)               "y"
    set ::moni::M(REQUEST_DIR)         "C:/REQUEST"
    set ::moni::M(RESPONSE_DIR)       "C:/RESPONSE"
    set ::moni::M(RESULT_DIR)            "C:/RESULT"
}

proc moni::set_no_local_01 {} {
    set ::moni::M(LOCAL_01)               "n"
    set ::moni::M(REQUEST_DIR)         "M:/REQUEST"
    set ::moni::M(RESPONSE_DIR)       "M:/RESPONSE"
    set ::moni::M(RESULT_DIR)            "M:/RESULT"
}

proc moni::get_time {} {
    variable M

    set start [clock seconds]
    set ::moni::M(Year) [clock format $start -format %Y]
    set ::moni::M(Month) [clock format $start -format %m]
    set ::moni::M(Day) [clock format $start -format %d]
    set ::moni::M(Hour) [clock format $start -format %H]
    set ::moni::M(Minute) [clock format $start -format %M]
    set ::moni::M(Second) [clock format $start -format %S]

    set ::moni::M(Time) $M(Year)/$M(Month)/$M(Day)/$M(Hour):$M(Minute):$M(Second)
}

proc moni::create_request_file {} {

    #if {$::moni::M(WS_ID) == "P/T"} {
    #   set ::moni::M(TestType) "P/T"
    #} elseif {$::moni::M(WS_ID) == "F/T"} {
    #    set ::moni::M(TestType) "F/T"
    #}
    set start [clock seconds]
    set Hour [clock format $start -format %H]
    set Minute [clock format $start -format %M]
    set Second [clock format $start -format %S]

    if {$::moni::M(LOCAL_01) == "n"} {
	set filename $::moni::M(SN)_$Hour$Minute$Second.txt
	set f [open $moni::M(REQUEST_DIR)/$filename "a+"]
	puts $f $::moni::M(SN),$::moni::M(LINE),$::moni::M(TestType),$::moni::M(MAC_ID),$::moni::M(MAC_QTY)
	close $f
    } else {
	set filename1 $::moni::M(SN).sf
	set f1 [open $moni::M(RESPONSE_DIR)/$filename1 "a+"]
	puts $f1 $::moni::M(SN),PASS,PASS
	close $f1
    }
}

proc moni::search_response_file {} {

    set i 0

    while {1} {
        # 设置超时为20秒
        ::moni::wait 1000
        incr i
        #/*在本地模拟01测试时，将M:/response改为C:/response*/
        foreach file [glob -nocomplain -directory $moni::M(RESPONSE_DIR) *.sf] {
            set filename [file tail [file rootname $file]].sf
            #tk_messageBox -message "Got file: $::moni::M(SN) $filename"
            if {[string first $::moni::M(SN) $filename 0] == 0} {
                #tk_messageBox -message "SN is OK"
                # 处理response文件内容
                set curfile [open $moni::M(RESPONSE_DIR)/$filename r]
                set filestr ""
                set newfilestr ""
                set cursp 0
                set nextsp 0
                set errormsg ""
                set enter \x0A
                set sp ","
                if {[gets $curfile line] >= 0} {
                    set filestr $line
                    set cursp [string first "," $filestr $cursp]
                    set nextsp [string first "," $filestr [expr {$cursp+1}]]
                    set ::moni::M(CHECK) [string range $filestr [expr {$cursp+1}] [expr {$nextsp-1}]]
                    #tk_messageBox -message "$::moni::M(CHECK)"
                    close $curfile
                    if {$::moni::M(CHECK) == "PASS" || $::moni::M(CHECK) == "RETEST"} {
                        # 正常测试
                        catch {file delete -force $moni::M(RESPONSE_DIR)/$filename}
                        return
                    } else {
                        # 退出测试
                        set cursp $nextsp
                        set nextsp [string first "," $filestr [expr {$cursp+1}]]
                        set errormsg [string range $filestr [expr {$cursp+1}] [expr {$nextsp-1}]]
                        catch {destroy .commonDlg}
                        catch {file delete -force $moni::M(RESPONSE_DIR)/$filename}
                        tk_messageBox -message "$moni::MSG(search_response_file_msg1)($errormsg)."
                        exit
                    }
                } else {
                    catch {destroy .commonDlg}
                    catch {file delete -force $moni::M(RESPONSE_DIR)/$filename}
                    tk_messageBox -message "$moni::MSG(search_response_file_msg2)"
                    exit
                }
            }
        }

        if {$i > 20} {
            catch {destroy .commonDlg}
            tk_messageBox -message "$moni::MSG(search_response_file_msg3)"
            exit
        }
    }

}

proc moni::create_result_file {} {


    set start [clock seconds]
    set Hour [clock format $start -format %H]
    set Minute [clock format $start -format %M]
    set Second [clock format $start -format %S]
    set filename $::moni::M(SN)_$Hour$Minute$Second.dat
    set f [open $moni::M(RESULT_DIR)/$filename "a+"]
    puts $f $::moni::M(LINE),$::moni::M(SHIFT),$::moni::M(TestType),$::moni::M(OPERATOR),$::moni::M(RACK),$::moni::M(LOT_NO),$::moni::M(TEST_VER),$::moni::M(SN),$::moni::M(RESULT),$::moni::M(ERROR_CODE),$::moni::M(MAC_ID),$::moni::M(MAC_QTY)
    close $f
}


#带有参数以及按钮的通用提示对话框，包括set_mac以及set_sn以及set_pn以及set_license
proc moni::paraComDlgCreate { title strs } {
    variable M
    catch {destroy .paraCommonDlg}
    update

    toplevel .paraCommonDlg

    wm withdraw .paraCommonDlg
    update
    BWidget::place .paraCommonDlg 500 200 center

    wm transient .paraCommonDlg .
    wm title     .paraCommonDlg "$title"
    wm deiconify .paraCommonDlg
    wm resizable .paraCommonDlg 0 0

    set win .paraCommonDlg
    set f [frame $win.cfg]
    Label $win.label -text "$strs" \
        -font { 宋体 15 bold } -bg ForestGreen -fg white \
        -width 20 -anchor w	-justify left -relief sunken -wraplength 460
    place $win.label \
        -in $win -x 20 -y 20 -width 460 -height 80 -anchor nw \
        -bordermode ignore

    pack $f -side top

    if {$::moni::M(TestItem) == "set_mac"} {
        set M(MacVlan) ""
        set ent [Entry $win.entry -bg white -fg blue -width 25 \
            -textvariable ::moni::M(MacVlan) -font { 宋体 12 normal } -justify center \
            -command {::moni::confirmCommand} -state normal]
    } elseif {$::moni::M(TestItem)== "set_sn"} {
        set M(SN) ""
        set ent [Entry $win.entry -bg white -fg blue -width 25 \
	        -textvariable ::moni::M(SN) -font { 宋体 12 normal } -justify center \
	        -command {::moni::confirmCommand} -state normal]
    } elseif {$::moni::M(TestItem)== "set_pn"} {
	    set M(PN) ""
        set ent [Entry $win.entry -bg white -fg blue -width 25 \
	        -textvariable ::moni::M(PN) -font { 宋体 12 normal } -justify center \
	        -command {::moni::confirmCommand} -state normal]
    } elseif {$::moni::M(TestItem)== "set_license"} {
	    set M(LICENSE) ""
        set ent [Entry $win.entry -bg white -fg blue -width 25 \
	        -textvariable ::moni::M(LICENSE) -font { 宋体 12 normal } -justify center \
	        -command {::moni::confirmCommand} -state normal]
    } 
    place $ent \
        -in $win -x 100 -y 120 -width 300 -height 20 -anchor nw \
        -bordermode ignore

    button $win.but1 -text "$moni::MSG(confirm_but_text)" -font { 宋体 14 bold } -width 10 \
        -command {::moni::confirmCommand} -fg brown \
        -highlightthickness 0 -takefocus 0 -borderwidth 2
    button $win.but2 -text "$moni::MSG(cancel_but_text)" -font { 宋体 14 bold } -width 10 \
        -command {::moni::cancelCommand} -fg brown -state normal \
        -highlightthickness 0 -takefocus 0 -borderwidth 2

    place $win.but1 \
        -in $win -x 80 -y 160 -anchor nw -bordermode ignore
    place $win.but2 \
        -in $win -x 300 -y 160 -anchor nw -bordermode ignore

    grab .paraCommonDlg
    focus -force $ent

}
#不带参数，也不带按钮的通用提示对话框，包括提示power up,search_response，以及复位键测试
proc moni::comDlgCreate { title strs } {
    catch {destroy .commonDlg}
    update

    toplevel .commonDlg
    wm withdraw .commonDlg
    update
    BWidget::place .commonDlg 500 160 center

    wm transient .commonDlg .
    wm title     .commonDlg "$title"
    wm deiconify .commonDlg
    wm resizable .commonDlg 0 0

    set win .commonDlg
    set f [frame $win.cfg]

    Label $win.label -text "$strs" \
        -font { 宋体 15 bold } -bg ForestGreen -fg white \
        -width 20 -anchor w	-justify left -relief sunken -wraplength 460

    place $win.label \
        -in $win -x 20 -y 20 -width 460 -height 120 -anchor nw \
        -bordermode ignore

    pack $f -side top

    grab .commonDlg
    focus -force .commonDlg
}
#不带参数，但是带按钮的通用提示对话框，包括提示linkcheck以及LED测试
proc moni::butComDlgCreate { title strs } {
    variable M
    catch {destroy .butCommonDlg}
    update

    set ledtest [string first "led" $::moni::M(TestItem)]
    set powertest [string first "power" $::moni::M(TestItem)]

    toplevel .butCommonDlg

    wm withdraw .butCommonDlg
#    wm state . iconic
    update
    BWidget::place .butCommonDlg 500 160 center

    wm transient .butCommonDlg .
    wm title     .butCommonDlg "$title"
    wm deiconify .butCommonDlg
    wm resizable .butCommonDlg 0 0

    set win .butCommonDlg
    set f [frame $win.cfg]
    pack $f -side top

    Label $win.label -text "$strs" \
        -font { 宋体 15 bold } -bg ForestGreen -fg white \
        -width 20 -anchor w -justify left -relief sunken -wraplength 460

    place $win.label \
        -in $win -x 20 -y 20 -width 460 -height 80 -anchor nw \
        -bordermode ignore

    pack $f -side top
    if { $ledtest >= 0 } {

        button $win.but1 -text "$moni::MSG(ok_but_text)" -font { 宋体 14 bold } -width 10 \
            -command {::moni::confirmCommand} -fg brown -state disabled \
            -highlightthickness 0 -takefocus 0 -borderwidth 2
        button $win.but2 -text "$moni::MSG(fail_but_text)" -font { 宋体 14 bold } -width 10 \
            -command {::moni::cancelCommand} -fg brown -state disabled \
            -highlightthickness 0 -takefocus 0 -borderwidth 2
    } elseif {$powertest >= 0 } {
        button $win.but1 -text "$moni::MSG(confirm_but_text)" -font { 宋体 14 bold } -width 10 \
            -command {::moni::confirmCommand} -fg brown \
            -highlightthickness 0 -takefocus 0 -borderwidth 2
        button $win.but2 -text "$moni::MSG(continue_but_text)" -font { 宋体 14 bold } -width 10 \
            -command {::moni::cancelCommand} -fg brown -state disabled \
            -highlightthickness 0 -takefocus 0 -borderwidth 2
    } else {
        button $win.but1 -text "$moni::MSG(confirm_but_text)" -font { 宋体 14 bold } -width 10 \
            -command {::moni::confirmCommand} -fg brown \
            -highlightthickness 0 -takefocus 0 -borderwidth 2
        button $win.but2 -text "$moni::MSG(cancel_but_text)" -font { 宋体 14 bold } -width 10 \
            -command {::moni::cancelCommand} -fg brown \
            -highlightthickness 0 -takefocus 0 -borderwidth 2
    }

    place $win.but1 \
        -in $win -x 80 -y 120 -anchor nw -bordermode ignore
    place $win.but2 \
        -in $win -x 300 -y 120 -anchor nw -bordermode ignore

    grab .butCommonDlg
    focus -force .butCommonDlg

}

#单按钮窗口
proc moni::sigleButComDlgCreate { title strs } {
    variable M
    catch {destroy .sigCommonDlg}
    update

    toplevel .sigCommonDlg

    wm withdraw .sigCommonDlg
#    wm state . iconic
    update
    BWidget::place .sigCommonDlg 500 160 center

    wm transient .sigCommonDlg .
    wm title     .sigCommonDlg "$title"
    wm deiconify .sigCommonDlg
    wm resizable .sigCommonDlg 0 0

    set win .sigCommonDlg
    set f [frame $win.cfg]
    pack $f -side top

    Label $win.label -text "$strs" \
        -font { 宋体 15 bold } -bg ForestGreen -fg white \
        -width 20 -anchor w -justify left -relief sunken -wraplength 460

    place $win.label \
        -in $win -x 20 -y 20 -width 460 -height 80 -anchor nw \
        -bordermode ignore

    pack $f -side top

    button $win.but1 -text "$moni::MSG(confirm_but_text)" -font { 宋体 14 bold } -width 10 \
        -command {::moni::confirmCommand} -fg brown -state disabled \
        -highlightthickness 0 -takefocus 0 -borderwidth 2

    place $win.but1 \
        -in $win -x 190 -y 120 -anchor nw -bordermode ignore

    grab .sigCommonDlg
    focus -force .sigCommonDlg

}

proc moni::confirmCommand { } {
    switch -- $::moni::M(TestItem) {
        "commonDlgTest" {::moni::commonDlgConfirm }
        "set_mac" { ::moni::check_mac }
        "set_sn" { ::moni::check_sn }
		"set_pn" { ::moni::check_pn }
		"set_license" { ::moni::check_license }
        "ledAllRedTest" { ::moni::ledAllRedTestPassed }
        "ledAllGreenTest" { ::moni::ledAllGreenTestPassed }
        "ledAllOrangeTest" { ::moni::ledAllOrangeTestPassed }
        "ledAllOffTest" { ::moni::ledAllOffTestPassed }
        "ledFanIndexTest" { ::moni::ledFanIndexTestPassed }
        "ledFanNoIndexTest" { ::moni::ledFanNoIndexTestPassed }
        "ledRunFastFlashTest" { ::moni::ledRunFastFlashTestPassed }
        "ledRunSlowFlashTest" { ::moni::ledRunSlowFlashTestPassed }
        "ledCFIndexTest" { ::moni::ledCFIndexTestPassed }
        "ledCFNoIndexTest" { ::moni::ledCFNoIndexTestPassed  }
        "ledPortOnTest" { ::moni::ledPortOnTestPassed }
        "ledPortOffTest" { ::moni::ledPortOffTestPassed }
        "ledRunRedTest" { ::moni::ledRunRedTestPassed }
        "ledRunGreenTest" { ::moni::ledRunGreenTestPassed  }
        "ledRunGFTest" { ::moni::ledRunGFTestPassed }
        "ledRunGSTest" { ::moni::ledRunGSTestPassed }
        "ledRunOrangeOnTest" { ::moni::ledRunOrangeOnTestPassed }
        "ledRunOffTest" { ::moni::ledRunOffTestPassed }
        "ledMSOnTest" { ::moni::ledMSOnTestPassed }
        "ledMSOffTest" { ::moni::ledMSOffTestPassed }
        "power1Test" { ::moni::sendPower1Test }
        "power2Test" { ::moni::sendPower2Test }
        "power3Test" { ::moni::sendPower3Test }
        "power4Test" { ::moni::sendPower4Test }
        "power5Test" { ::moni::sendPower5Test }
        "power7Test" { ::moni::sendPower7Test }
        "linkcheck" { ::moni::linkcheckup }
        "powerswitch" { ::moni::test_end }
        "powerswitchdlg" { ::moni::powerSwitchTest }
	default {return }
    }

}
proc moni::cancelCommand { } {
    switch -- $::moni::M(TestItem) {
        "commonDlgTest" {::moni::commonDlgError }
    "set_mac" { ::moni::exit_set_mac }
    "set_sn" { ::moni::exit_set_sn }
	"set_pn" { ::moni::exit_set_pn }
	"set_license" { ::moni::check_license }
    "ledAllRedTest" { ::moni::ledAllRedTestNotPassed }
    "ledAllGreenTest" { ::moni::ledAllGreenTestNotPassed }
    "ledAllOrangeTest" { ::moni::ledAllOrangeTestNotPassed }
    "ledAllOffTest" { ::moni::ledAllOffTestNotPassed }
    "ledFanIndexTest" { ::moni::ledFanIndexTestNotPassed }
    "ledFanNoIndexTest" { ::moni::ledFanNoIndexTestNotPassed }
    "ledRunFastFlashTest" { ::moni::ledRunFastFlashTestNotPassed}
    "ledRunSlowFlashTest" { ::moni::ledRunSlowFlashTestNotPassed}
    "ledCFIndexTestDlg" { ::moni::ledCFIndexTestNotPassed}
    "ledCFNoIndexTest" { ::moni::ledCFNoIndexTestNotPassed}
    "ledPortOnTest" { ::moni::ledPortOnTestNotPassed}
    "ledPortOffTest" { ::moni::ledPortOffTestNotPassed}
    "ledRunRedTest" { ::moni::ledFanNoIndexTestPassed}
    "ledRunGreenTest" { ::moni::ledRunGreenTestNotPassed}
    "ledRunGFTest" { ::moni::ledRunGFTestNotPassed}
    "ledRunGSTest" { ::moni::ledRunGSTestNotPassed}
    "ledRunOrangeOnTest" { ::moni::ledRunOrangeOnTestNotPassed}
    "ledRunOffTest" { ::moni::ledRunOffTestNotPassed}
    "ledMSOnTest" { ::moni::ledMSOnTestNotPassed}
    "ledMSOffTest" { ::moni::ledMSOffTestNotPassed}
    "power1Test" { ::moni::power2Test }
    "power2Test" { ::moni::power3Test }
    "power3Test" { ::moni::power4Test }
    "power4Test" { ::moni::power5Test }
    "power5Test" { ::moni::power6Test }
    "power7Test" { ::moni::power8Test }
    "linkcheck" { ::moni::linkcheckdown "$::moni::M(LinkErrStr)" }
    default {return }
    }
}
proc moni::fastinsertend {item str} {
    if {$::moni::M(waitdot) == 1 && $item == "handle"} {

        catch {.testInfoDlg.labf2.t fastinsert end "\n$str"}
    } else {
        catch {.testInfoDlg.labf2.t fastinsert end "$str"}
    }
    catch {.testInfoDlg.labf2.t yview 10000}        ;#ctext显示到10000行

}


proc moni::waitNewline {offtime } {
	set start [clock seconds]
    variable M
    set i 0
    upvar newline match
    
    while {1} {
        
        set result [ regexp {([^\n]*\n)} $moni::M(strTemp) match ]
        if {$result == 1} {
			set matchlen [string length "$match" ]
			set moni::M(strTemp) [string range "$moni::M(strTemp)" $matchlen end]
			return 1
        }
                
  		set end [clock seconds]

        ;#等待时间是否超时
        if { $end > [expr $offtime + $start]} {
            return 0
        }

		::moni::wait 1
    }

}


#等待某个字符串
#overtime时间单位为妙
#tempStr 可以是以等号分割的多个字符串
#		第一个字符串匹配返回ok
#		第二个字符串匹配返回error
#okNum 返回OK结果的字符串个数，默认为一个
#
proc moni::waitSomeStr { tempStr overTime {okNum 1}} {
	upvar fixline newline
	set start [clock seconds]
	variable M
	set newline ""
	#if {okNum < 0}

	#set okstr ""
	set okstr {}
	set errstr {}
	if {[string first "=" $tempStr] > 0} {
		set strlist [split "$tempStr" "="]    ;#将参数划分为列表
		set okstr [lrange $strlist 0 [expr $okNum -1]]
		set errstr [lrange $strlist $okNum end] 
	} else {
		set okstr [list "$tempStr"]
	}
	
    while {1} {
    	set now [clock seconds]
    	set offtime [expr {$start + $overTime - $now}]
    	if { $offtime < 1 } {
    		set newline ""
            return 0
        } 

        set ret [moni::waitNewline [expr $offtime<4 ? $offtime:4]]
        if { $ret == 0} {
            ::moni::send $::moni::Cfg(name) "\x0A"
            continue
        }


	if {[llength $okstr]} {
            foreach xok $okstr {
		if {[string length [string trim $xok]]} {
	            set okchk	[string first "$xok" $newline]           
	            if {$okchk >= 0} {
		         return 1
		    } 
		}
	    }
	}

	if {[llength $errstr]} {
		foreach xerr $errstr {
			if {[string length [string trim $xerr]]} {
			        set errchk	[string first "$xerr" $newline]           
			        if {$errchk >= 0} {
			            return 0
			        } 
			}
		}
	}

	::moni::send $::moni::Cfg(name) "\x0A"
    }

}
