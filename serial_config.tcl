namespace eval serialconfig {
    variable ComPorts
    variable HandshakeModes {none xonxoff rtscts}

    switch -glob -- $::tcl_platform(os) {
        Linux* {
            set ComPorts {/dev/ttyS0 /dev/ttyS1 /dev/ttyS2 /dev/ttyS3}
        }
        SunOS* {
            set ComPorts {/dev/ttya /dev/ttyb}
        }
        Windows* {
			#Modified by ligc: add com ports to 128
        	for {set i 1} {$i < 128} {incr i} {
        		lappend ComPorts com$i
        	}
            #set ComPorts {com1 com2 com3 com4}
            lappend HandshakeModes dtrdsr
        }
        default {
            error "Unsupported OS"
        }
    }
}

proc serialconfig::Scroll_Set {scrollbar geoCmd offset size} {
	if {$offset != 0.0 || $size != 1.0} {
		eval $geoCmd					;# Make sure it is visible
	}
	$scrollbar set $offset $size
}

proc serialconfig::Scrolled_Listbox { f args } {
	frame $f
	listbox $f.list \
		-xscrollcommand [list ::serialconfig::Scroll_Set $f.xscroll \
			[list grid $f.xscroll -row 1 -column 0 -sticky we]] \
		-yscrollcommand [list ::serialconfig::Scroll_Set $f.yscroll \
			[list grid $f.yscroll -row 0 -column 1 -sticky ns]]
	eval {$f.list configure} $args
	scrollbar $f.xscroll -orient horizontal \
		-command [list $f.list xview]
	scrollbar $f.yscroll -orient vertical \
		-command [list $f.list yview]
	grid $f.list -sticky news
	grid rowconfigure $f 0 -weight 1
	grid columnconfigure $f 0 -weight 1
	return $f.list
}

proc serialconfig::SelectListItem {} {
    set cursel [.sdlg.selection.list curselection]
    set name [.sdlg.selection.list get $cursel $cursel]
    variable CONF
    #name
    .sdlg.entry delete 0 [string length [.sdlg.entry get]]
    .sdlg.entry insert 0 $name

    #Port
    .sdlg.combo configure -text $::serialconfig::CONF($name.Port)

    return
}

################################################################################
#                                < 串口设置 >

proc serialconfig::portSetWin { win title var } {
    upvar $var Cfg
    variable Apply 0
    variable ComPorts
    variable HandshakeModes
    variable conf
    array set conf [array get Cfg]

    catch { destroy $win }
    toplevel $win
    wm title $win $title
    BWidget::place $win 400 160 center
    wm resizable $win 0 0

    catch {unset Edit}
    variable Edit
    array set Edit [array get Cfg]  ;# Copy config


    #================================ 串口选择列表 =============================
    set list [Scrolled_Listbox $win.selection -width 20 -height 10 -font { 宋体 12 normal }]
#    pack $win.selection -side left -padx 20 -pady 30 -anchor nw
    bind $list <ButtonRelease-1> \
         ::serialconfig::SelectListItem
    bind $list <Double-1> \
        ::serialconfig::DoubleClickList
    place $win.selection \
        -in $win -x 20 -y 20 -width 100 -height 120 -anchor nw \
        -bordermode ignore

    set f [frame $win.cfg -padx 30 -pady 50]

    Label $win.label1 -text "Name:" -font { 宋体 12 normal } -fg {blue} -width 15 -anchor w

    place $win.label1 \
        -in $win -x 160 -y 20 -width 50 -height 20 -anchor nw \
        -bordermode ignore

    set ent [Entry $win.entry -bg white -fg brown -width 20 \
	    -textvariable {::serialconfig::Edit(name)} -font { 宋体 12 normal } -justify left \
	    -state normal]
	place $ent \
        -in $win -x 250 -y 20 -width 100 -height 20 -anchor nw \
        -bordermode ignore

    Label $win.label2 -text "Serial:" -font { 宋体 12 normal } -fg {blue} -width 15 -anchor w

    place $win.label2 \
        -in $win -x 160 -y 60 -width 50 -height 20 -anchor nw \
        -bordermode ignore

    set combo [ComboBox $win.combo \
        -textvariable {::serialconfig::Edit(Port)} -editable 0 -fg brown \
        -values $ComPorts]

    place $combo \
        -in $win -x 250 -y 60 -width 100 -height 20 -anchor nw \
        -bordermode ignore

    pack $f -side top


    button $win.but1 -text "Confirm" -font { 宋体 12 normal } -width 10 \
        -command {serialconfig::comfirm_port} -fg brown \
        -highlightthickness 0 -takefocus 0 -borderwidth 2
    button $win.but2 -text "Cancel" -font { 宋体 12 normal } -width 10 \
        -command {set ::serialconfig::Apply 0} -fg brown -state normal \
        -highlightthickness 0 -takefocus 0 -borderwidth 2

    place $win.but1 \
        -in $win -x 160 -y 110 -anchor nw -bordermode ignore
    place $win.but2 \
        -in $win -x 260 -y 110 -anchor nw -bordermode ignore

    wm protocol $win WM_DELETE_WINDOW {set ::serialconfig::Apply 0}

    grab $win
    focus -force $win

    set file [open moni.con r]
    while {[gets $file line] >= 0} {
    	gets $file line
    	set title ""
    	::moni::get_param 1 $line
    	set name $title
    	set ::serialconfig::CONF($name.Title) $title

    	::moni::get_param 2 $line
    	set ::serialconfig::CONF($name.Port) $title

    	::moni::get_param 3 $line
    	set ::serialconfig::CONF($name.Baud) $title

    	::moni::get_param 4 $line
    	set ::serialconfig::CONF($name.DataBits) $title

    	::moni::get_param 5 $line
    	set ::serialconfig::CONF($name.StopBits) $title

    	::moni::get_param 6 $line
    	set ::serialconfig::CONF($name.Parity) $title

        ::moni::get_param 7 $line
    	set ::serialconfig::CONF($name.Handshake) $title

        ::moni::get_param 8 $line
    	set ::serialconfig::CONF($name.Handshake) $title

        ::moni::get_param 9 $line
    	set ::serialconfig::CONF($name.SysBuffer) $title

        ::moni::get_param 10 $line
    	set ::serialconfig::CONF($name.Pollinterval) $title

        $win.selection.list insert end $name
    }

    close $file

    tkwait variable ::serialconfig::Apply
    if { $Apply } {
    	if {[string length $Edit(name)] == 0 } {
			tk_messageBox -type ok -icon error \
        		-message "$moni::MSG(Serial_config_msg1)"
        	catch {destroy $win}
        	return 0
    	}

    	if {[string first " " $Edit(name)] >= 0 } {
     		tk_messageBox -type ok -icon error \
        		-message "$moni::MSG(Serial_config_msg2)"
        	catch {destroy $win}
        	return 0
        }

        array set Cfg [array get Edit]
    }
    catch {destroy $win}
    return $Apply
}

proc serialconfig::comfirm_port {} {
    variable M
	variable Edit
	variable ConChan

	set ::serialconfig::Apply 1

	if {[string length $Edit(name)] == 0 } {
		tk_messageBox -type ok -icon error \
    		-message "$moni::MSG(Serial_config_msg1)"
    	catch {destroy $win}
    	return 0
	}

	if {[string first " " $Edit(name)] >= 0 } {
 		tk_messageBox -type ok -icon error \
    		-message "$moni::MSG(Serial_config_msg2)"
    	catch {destroy $win}
    	return 0
    }

    array set ::moni::Cfg [array get Edit]

    set file [open config.ini r]
    set filestr ""
    set newfilestr ""
    set serialstrhead "serialmode:"
    set enter \x0A
    set sp "*"
    while {[gets $file line] >= 0} {
        set filestr $filestr$line$enter
    }
    set len [string length $filestr]
    set serialstrpos [string first $serialstrhead $filestr 0]
    set enterpos [string first $enter $filestr $serialstrpos]
    set newfilestr [string range $filestr 0 [expr {$serialstrpos-1}]]
    set newfilestr $newfilestr$serialstrhead$sp$Edit(name)$sp$Edit(Port)$sp$Edit(Baud)$sp$Edit(DataBits)$sp$Edit(StopBits)$sp$Edit(Parity)$sp$Edit(Handshake)$sp$Edit(SysBuffer)$sp$Edit(Pollinterval)$sp
    set strafterenter [string range $filestr $enterpos $len]
    set newfilestr $newfilestr$strafterenter

    close $file

    set file [open config.ini w]
    puts -nonewline $file $newfilestr
    close $file

    catch {destroy .sdlg}
#    ::moni::config_open
}

proc serialconfig::DoubleClickList {} {
    variable M
	variable Edit
	variable ConChan

	if {[string length $Edit(name)] == 0 } {
		tk_messageBox -type ok -icon error \
    		-message "$moni::MSG(Serial_config_msg1)"
    	catch {destroy $win}
    	return 0
	}

	if {[string first " " $Edit(name)] >= 0 } {
 		tk_messageBox -type ok -icon error \
    		-message "$moni::MSG(Serial_config_msg2)"
    	catch {destroy $win}
    	return 0
    }

    array set ::moni::Cfg [array get Edit]

    set file [open config.ini r]
    set filestr ""
    set newfilestr ""
    set serialstrhead "serialmode:"
    set enter \x0A
    set sp "*"
    while {[gets $file line] >= 0} {
        set filestr $filestr$line$enter
    }
    set len [string length $filestr]
    set serialstrpos [string first $serialstrhead $filestr 0]
    set enterpos [string first $enter $filestr $serialstrpos]
    set newfilestr [string range $filestr 0 [expr {$serialstrpos-1}]]
    set newfilestr $newfilestr$serialstrhead$sp$Edit(name)$sp$Edit(Port)$sp$Edit(Baud)$sp$Edit(DataBits)$sp$Edit(StopBits)$sp$Edit(Parity)$sp$Edit(Handshake)$sp$Edit(SysBuffer)$sp$Edit(Pollinterval)$sp
    set strafterenter [string range $filestr $enterpos $len]
    set newfilestr $newfilestr$strafterenter

    close $file

    set file [open config.ini w]
    puts -nonewline $file $newfilestr
    close $file

    catch {destroy .sdlg}
    ::moni::config_open
    return 1
}


proc moni::config_open_default {} {
    variable M
    variable Cfg
    #current connection channel list
    variable ConChan

if {1} {
    set file [open config.ini r]
    while {[gets $file line] >= 0} {
    	#set title [lindex $line 0]
    	set title ""
        ::moni::get_param 1 $line
    	if {$title == "serialmode:"} {
    	    ::moni::get_param 2 $line
    	    set Cfg(name) $title
    	    ::moni::get_param 3 $line
    	    set Cfg(Port) $title
    	    ::moni::get_param 4 $line
    	    set Cfg(Baud) $title
    	    ::moni::get_param 5 $line
    	    set Cfg(DataBits) $title
    	    ::moni::get_param 6 $line
    	    set Cfg(StopBits) $title
    	    ::moni::get_param 7 $line
    	    set Cfg(Parity) $title
    	    ::moni::get_param 8 $line
    	    set Cfg(Handshake) $title
            ::moni::get_param 9 $line
    	    set Cfg(SysBuffer) $title
            ::moni::get_param 10 $line
    	    set Cfg(Pollinterval) $title
    	}
    }

    close $file
}

    set name $Cfg(name)

    #set ConChan($name) [open \\\\.\\$Cfg(Port) r+]
    if {[catch {set ConChan($name)  [open \\\\.\\$Cfg(Port) r+]} result]} {
    	tk_messageBox -message  [format  "%s can't open!" $Cfg(Port)]
    	moni::config_new
    	return
    }
    
    #for serial disconnect

    set M($name.Port) $Cfg(Port)
    set M($name.Baud) $Cfg(Baud)
    set M($name.Parity) $Cfg(Parity)
    set M($name.DataBits) $Cfg(DataBits)
    set M($name.StopBits) $Cfg(StopBits)
    set M($name.sysbuffer) $Cfg(SysBuffer)
    set M($name.pollinterval) $Cfg(Pollinterval)
    #end of add

    set M($name.Open) 1
    fconfigure $ConChan($name) -translation crlf -blocking 0

    set parity [string index $Cfg(Parity) 0]
    set mode $Cfg(Baud),$parity,$Cfg(DataBits),$Cfg(StopBits)
    fconfigure $ConChan($name) -buffering none
    fconfigure $ConChan($name) -mode $mode ;#-handshake $Cfg(Handshake) #comment by ligc:to use ixia wish
    fconfigure $ConChan($name)

    switch -glob -- $::tcl_platform(os) {
        Windows* {
            fconfigure $ConChan($name) -pollinterval $Cfg(Pollinterval)
        }
    }

    fileevent $ConChan($name) readable ::moni::reader

    set M(RecvBuf.$name) ""
    set M(RecvBufAll.$name) ""

    if {![info exist M(Win.TTY.$name)]} {
   		win_tty $M(Win.Notebook) $name
   	}
}

proc moni::config_open {} {
    variable M
    variable Cfg
    #current connection channel list
    variable ConChan
    set name $Cfg(name)

    #set ConChan($name) [open \\\\.\\$Cfg(Port) r+]
    if {[catch {set ConChan($name)  [open \\\\.\\$Cfg(Port) r+]} result]} {
    	tk_messageBox -message  [format  "%s can't open!" $Cfg(Port)]
    	moni::config_new
    	return
    }

    #for serial disconnect

    set M($name.Port) $Cfg(Port)
    set M($name.Baud) $Cfg(Baud)
    set M($name.Parity) $Cfg(Parity)
    set M($name.DataBits) $Cfg(DataBits)
    set M($name.StopBits) $Cfg(StopBits)
    set M($name.sysbuffer) $Cfg(SysBuffer)
    set M($name.pollinterval) $Cfg(Pollinterval)
    #end of add

    set M($name.Open) 1
    fconfigure $ConChan($name) -translation crlf -blocking 0

    set parity [string index $Cfg(Parity) 0]
    set mode $Cfg(Baud),$parity,$Cfg(DataBits),$Cfg(StopBits)
    fconfigure $ConChan($name) -buffering none
    fconfigure $ConChan($name) -mode $mode
    fconfigure $ConChan($name)

    switch -glob -- $::tcl_platform(os) {
        Windows* {
            fconfigure $ConChan($name) -pollinterval $Cfg(Pollinterval)
        }
    }

    fileevent $ConChan($name) readable ::moni::reader

    set M(RecvBuf.$name) ""
    set M(RecvBufAll.$name) ""

    if {![info exist M(Win.TTY.$name)]} {
   		win_tty $M(Win.Notebook) $name
   	}
}

proc moni::config_close {} {
    variable M

    if { ! $M(Open) } {
        return 1
    }

    set M(Open) 0
    catch { close $M(Chan) }

    ::moni::term_clear
    ::moni::log_close
    return 1
}

proc ::moni::term_clear {} {
    variable M

    set name [$M(Win.Notebook) raise]


     if {[info exist M(Win.TTY.$name)]} { ;#protected code
     	$M(Win.TTY.$name) delete 1.0 end
     }

    set M(Term.Count) 0
    set M(Term.TotalCount) 0
}

proc moni::config_setup {} {
    variable M
    catch {close $M(Chan)}
    ::moni::config_open
}

proc moni::config_edit {} {
    variable M
    variable Cfg

    ::moni::disconnect
    set result [::serialconfig::portSetWin .sdlg "Serial config" Cfg]
    if { $result } {
        moni::config_setup
    }
}

proc moni::config_new {} {
    variable M

#    if { $M(Open)} {
        ::moni::config_close
#    }

    ::moni::config_edit
}

proc moni::close_serial {} {
	variable M
	variable ConChan
	#get the activited page title
    set name [$M(Win.Notebook) raise]
    $M(Win.Notebook) delete $name

    #Raise the first page
    $M(Win.Notebook) raise [$M(Win.Notebook) page 0]

    catch {close $ConChan($name)}

    if {[info exist ConChan($name)]} {
    	unset ConChan($name)
    }

    if {[info exist M(Win.TTY.$name)]} {
        unset M(Win.TTY.$name)
    }
}

proc moni::disconnect {} {
	variable M
	variable ConChan
	#get the activited page title
    set name [$M(Win.Notebook) raise]
    #$M(Win.Notebook) delete $name

    #Raise the first page
    #$M(Win.Notebook) raise [$M(Win.Notebook) page 0]
    if {$name != ""} {
    	if {[info exist ConChan($name)]} {
    		catch [close $ConChan($name)]
    		unset ConChan($name)
    	}
    }
    #set ::moni::M($name.disconnect) 1
}

proc moni::send {com str} {
    variable M
    $::moni::M(Win.Notebook) raise $com
    ::moni::rs232_put $com $str
}