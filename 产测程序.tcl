package require Tk
package require BWidget
package require ctext
#package require thread

namespace eval moni {
    variable M
    #����message.txt�е�������ʾ�����������
    variable MSG

    set M(MAC_DASH)            0
    set M(SHOWBOARDPOSGOT)     0
    set M(SHOWCPUBOARDPOSGOT)  0
    set M(SHOWRTC)  0
    set M(SHOWMANAGEMAC) 0
    set M(LOCAL_01)         "n"
    #/*�ڱ���ģ��01����ʱ����M:/REQUEST��ΪC:/REQUEST;M:/RESPONSE��ΪC:/RESPONSE;M:/RESULT��ΪC:/RESULT,*/
    set M(REQUEST_DIR)         "M:/REQUEST"
    set M(RESPONSE_DIR)        "M:/RESPONSE"
    set M(RESULT_DIR)          "M:/RESULT"
    set M(SN)                  ""      ;# DUT���, ��ҵԱ���� Char(30)
    set M(LINE)                ""      ;# �߱�, ��ҵԱ���� Char(6)
    set M(SHIFT)               ""      ;# ���, ��ҵԱ���� Char(4)
    set M(WS_ID)               ""      ;# վ��, ��ҵԱ���� or ������� Char(6)
    set M(MAC_ID)              ""      ;# ��ʼMac ID, ��ҵԱ���� or ������� Char(12)
    set M(MAC_QTY)             0       ;# Mac ID ʹ����, ��������0
    set M(USED)                0       ;# ���Mac ID�ж��ٸ�S/N�ù�����������0
    set M(CHECK)               ""      ;# Shop floor������֤�룬��PASS�� or ��FAIL�� or ��RETEST��
    set M(CHECK_MESSAGE)       ""      ;# Shop floor������֤��Ϣ
    set M(OPERATOR)            ""      ;# ��ҵԱ���ţ���ҵԱ���� Char(10)
    set M(RACK)                ""      ;# ����վ��ţ���ҵԱ���� Char(6)
    set M(LOT_NO)              ""      ;# ջ���ţ���ҵԱ���� Char(30)
    set M(TEST_VER)            ""      ;# ���Գ���汾��С����2λ
    set M(RESULT)              ""      ;# ���Խ����������� Char(1)
    set M(ERROR_CODE)          ""      ;# ����������룬������� Char(6)

    set M(ScriptTimes)      1
    set M(ScriptInterval)   1000
    set M(ScriptName)       ""

    set Setup(MaxLines)     1000
    set Setup(Ticker)       100

    set M(HandleString)     0
    set M(FmtErrStrChecked) 0

    set M(Producer)         ""
    set M(Manufactory)      ""
    set M(Agingflag)        ""
    set M(Debug)            ""
    set M(Ispullcables)                 ""
    set M(BpFirstTested)    0
    set M(BpSecondTested)   0
    set M(GetBoot)          0
    set M(GetRam)           0
    set M(GetAging)         0
    set M(GetAgingDetail)   0
    set M(GetPower1)        0
    set M(GetPower2)        0
    set M(GetMemOk)         0
    set M(GetSuccess)       0
    set M(GetFail)          0
    set M(StartWaitRam)     0
    set M(ExitWaitRam)      0
    set M(waitdot)          0
    set M(GetUcodeDownOK)   0

    set M(GetMantest)       0
    set M(StartWaitMantest) 0
    set M(ExitWaitMantest)  0
	set M(GetAgingResult)	0

    set M(FileError)        0
    set M(ErrorFound)       0
    set M(FirstError)       1
    set M(Dir)              0
    set M(BOOTROMSame)      0
    set M(NOSIMGSame)       0
    set M(Reboot1)          0
    set M(Reboot2)          0
    set M(Reboot3)          0
    set M(OverWrite)        0
    set M(Time)             0
    set M(HWVersion)        1.0.0.0
    set M(GetResult)        0      ;# �Ѿ�������get_result
#   set M(SetupFile)        [file join $_DIR(moni) moni.cfg]

    set M(AllCableOut)      0
    set M(TestImageStart)   0
    set M(ImageLoaded)      0
    set M(ImageWrited)      0
    set M(BootLoaded)       0
    set M(BootWrited)       0
    set M(VendorCfgLoaded)  0
    set M(VendorCfgWrited)  0
    set M(ResetCpu)         0
    set M(Reset1)           0
    set M(Reset2)           0
    set M(Reset3)           0
    set M(TestType)         ""
    set M(autoTestFinished) 0
    set M(strTemp)          ""
    set M(sym1)             0           ;# "[" �� M(RecvBufAll.$name) �е�λ��
    set M(sym2)             0           ;# "\r" �� M(RecvBufAll.$name) �е�λ��
    set M(symenter)         0           ;# "\A" �� M(RecvBufAll.$name) �е�λ��

    set M(LinkErrStr)       ""
    set M(tested)           0
    set M(passed)           0
    set M(failed)           0
#   set M(finished)         0
    set M(Handled)          0
    set M(bigindex)         ""
    set M(Open)             0           ;# Is channel open
    set M(Chan)             {}          ;# The open channel
    set M(ProductType)      ""
    set M(IsChassis)		1
    set M(BoardType)        ""
    set M(AgingTime)        8
    set M(BoardTypeNum)     0
    set M(MacVlan)          ""
    set M(BTGot)            0
    set M(SNGot)            0
    set M(MACGot)           0
    set M(HWGot)            0
    set M(Year)             0
    set M(Month)            0
    set M(Day)              0
    set M(Hour)             0
    set M(Minute)           0
    set M(Second)           0
    set M(FirstShowTestInfo)           1        ;#������ʾ������Ϣ��
    set M(KeySwapOK)        0
    set M(TestingFlash)     0
    set M(TestItem)         ""
    set M(ptshowmac)        0
	
	set M(DATE)				0					;#add by duzqa
	set M(PN)				0					;#add by duzqa
	set M(PROMPTS)			0					;#add by duzqa
	set M(USER)				0					;#add by duzqa
	set M(PASSWORD)			0					;#add by duzqa

    set M(Term.MaxLines)    $Setup(MaxLines)    ;# 0: No terminal truncation, <>0: Truncate input
    set M(Term.Ticker)      $Setup(Ticker)  ;# Terminal: RS-232 status update interval

    set M(Term.Stop)        0       ;# 1: Don't send data to terminal
    set M(Term.Hold)        0       ;# 1: Don't scroll terminal window after insert of incoming data
    set M(Term.Echo)        0       ;# 1: Echo input to terminal
    set M(Term.Log)         0       ;# 1: Log inoming data to file
    set M(Term.Count)       0       ;# Terminal: byte counter for text formatting
    set M(Term.TotalCount)  0       ;# Terminal: Total number of received bytes

    set M(TTY.OutQueue)     0       ;# TTY: Number of bytes in the output queue

    set M(TTY.Stat.RTS)     0       ;# RTS output control
    set M(TTY.Stat.DTR)     0       ;# DTR output control
    set M(TTY.Stat.BREAK)   0       ;# BREAK output control
    set M(TTY.Stat.CTS)     0       ;# CTS input status
    set M(TTY.Stat.DSR)     0       ;# DSR input status
    set M(TTY.Stat.RING)    0       ;# Input status RING indicator
    set M(TTY.Stat.DCD)     0       ;# Input status CARRIER detect

    set M(TTY.Errors)       0       ;# TTY: Error counter
    set M(TTY.LastError)    ""      ;# TTY: Last error

    set M(Win.Raw.Input)    {}      ;# Hex-Terminal: hex input string
    set M(Win.Raw.Input.W)  {}      ;# Widget containg hex input string

    set M(Font)             {}      ;# Selected font
    set M(Win.Font)         {}      ;# Font selector widget
    set M(ShowboardCheck) 1;#showboard�����
    set M(ATEMSN)           0       ;#atem sn
    set M(LOGFILE)          0
    set M(CURRSN)           0
}

set ret [ source test_funcs.tcl ]        ;#���Ժ���
set ret [ source serial_config.tcl ]     ;#�������öԻ���
#set ret [ source Moni-Config.tcl ]      ;#����̨����
set ret [ source main_window.tcl ]       ;#������
#set ret [ source receiver.tcl ]         ;#�����շ����ݴ���
set ret [ source term_handle.tcl ]       ;#����̨�༭

variable msg
variable portSetDlg
variable testSetDlg
variable portSortDlg

################################################################################
#                                < �ű�Ŀ¼ >

set _DIR(script)    [file dirname [info script]]

#                        < ͼƬĿ¼ >
set _DIR(images)    [file join $_DIR(script) images]

wm withdraw .


################################################################################
#                                < �����˵� >

proc moni::init { } {
    variable Cfg

    font create fn_fixed -family {Courier} -size 10 -weight normal -slant roman -underline 0 -overstrike 0
    option add *Text*font fn_fixed

    ::moni::config_init
    ::moni::message_init ;#��ȡmessage.txt�е���ʾ����
    ::moni::win       ;#����������

    wm title . "$moni::MSG(init_title)  $moni::M(TEST_VER)"
    wm protocol . WM_DELETE_WINDOW { ::moni::appExit }
    BWidget::place . [winfo screenwidth .] [winfo screenheight .] center
    wm deiconify .
    #wm state . iconic      ;#��С��
    #wm state . zoomed      ;#���
    #wm state . zoom        ;#���
    update idletasks

    #::moni::config_init
    ::moni::config_open_default
}

proc moni::get_boardtypenum {} {
    variable M
    if {$::moni::M(BoardType) == "ES450-28P-POE" } {
        set ::moni::M(BoardTypeNum) 284
    } elseif {$::moni::M(BoardType) == "SNR-S2985G-24T-POE"} {
        set ::moni::M(BoardTypeNum) 285
    } elseif {$::moni::M(BoardType) == "S4600-10P-P"} {
        set ::moni::M(BoardTypeNum) 286
    }  elseif {$::moni::M(BoardType) == "S3900E-28P-SI"} {
        set ::moni::M(BoardTypeNum) 281
    }  elseif {$::moni::M(BoardType) == "SNR-S2965-8T"} {
        set ::moni::M(BoardTypeNum) 288
    } elseif {$::moni::M(BoardType) == "CS6200-28X-EI"} {
        set ::moni::M(BoardTypeNum) 357
    } elseif {$::moni::M(BoardType) == "CS6200-28X-P-EI"} {
        set ::moni::M(BoardTypeNum) 358
    } elseif {$::moni::M(BoardType) == "S5750E-28C-SI"} {
        set ::moni::M(BoardTypeNum) 359
    } elseif {$::moni::M(BoardType) == "S5750E-28X-SI"} {
        set ::moni::M(BoardTypeNum) 360
    } elseif {$::moni::M(BoardType) == "S5750E-28X-P-SI"} {
        set ::moni::M(BoardTypeNum) 361
    } elseif {$::moni::M(BoardType) == "CS6200-52X-EI"} {
        set ::moni::M(BoardTypeNum) 362
    } elseif {$::moni::M(BoardType) == "S5750E-52X-SI"} {
        set ::moni::M(BoardTypeNum) 363
    } elseif {$::moni::M(BoardType) == "S4600-28C-SI"} {
        set ::moni::M(BoardTypeNum) 354
    } elseif {$::moni::M(BoardType) == "SNR-S2985G-24T-UPS"} {
        set ::moni::M(BoardTypeNum) 368
    } elseif {$::moni::M(BoardType) == "S4600-28P-SI"} {
        set ::moni::M(BoardTypeNum) 370
    } elseif {$::moni::M(BoardType) == "SNR-S2965-24T"} {
        set ::moni::M(BoardTypeNum) 371
    } elseif {$::moni::M(BoardType) == "S4600-28P-P-SI"} {
        set ::moni::M(BoardTypeNum) 372
    } elseif {$::moni::M(BoardType) == "S4600-10P-P-SI"} {
        set ::moni::M(BoardTypeNum) 373
    } elseif {$::moni::M(BoardType) == "SNR-S2985G-8T-POE"} {
        set ::moni::M(BoardTypeNum) 373
    }

}

proc moni::get_producttype {} {
    variable M   
    set ::moni::M(ProductType) "Bluelake"
    
}

proc moni::get_param {index line} {
    variable M
    upvar title titlename

    set sp "*"

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
#������ʾ����,added by yueql,2010/12/28
proc moni::message_init { } {
    set fileExists [ file exists "message.txt" ]
	if { 0 == $fileExists } {
	    tk_messageBox -message "No File: message.txt"
		return 1
	}

	#���ļ�
	set file [ open "message.txt" r]

	#��ѡ����ȡ��
	set empLine 0
	while { [eof $file] != 1 } {
	    gets $file line

		set empLine 0
		set line [string trim $line]
		if { [string length $line] < 1 } {
            continue
		}
		if { [string index $line 0] == "#" } {
            continue
		}
		#�ҵ�ð�ŵ�λ��
		set sePos [ string first "::" $line ]

		#�Ϸ����ж�
		if { $sePos <= 1 } {
			continue
		}

		#moni::messageInfo "$line"
		#��ȡȫ�ֱ���������
		set sePos [expr $sePos - 1 ]
		set name [ string range $line 0 $sePos ]

		#��ȡȫ�ֱ�����ֵ
		set sePos [expr $sePos + 3 ]
		set value [ string range $line $sePos end ]

		#��ֵ
		set ::moni::MSG($name) $value
	}
	#�ر��ļ�
	set ::moni::M(TEST_VER)         $moni::MSG(TEST_VERSION) 
	close $file
}

proc moni::config_init {} {
    variable M

    set file [open config.ini r]
    set filestr ""
    set newfilestr ""
    set enter \x0A
    set sp "*"
    while {[gets $file line] >= 0} {
        set title ""
        ::moni::get_param 1 $line
        if {$title == "hardwareversion:"} {
            moni::get_param 2 $line
            set ::moni::M(HWVersion) $title
        }
        if {$title == "producer:"} {
            moni::get_param 2 $line
            set ::moni::M(Producer) $title
        }
        if {$title == "producttype:"} {
            moni::get_param 2 $line
            set ::moni::M(ProductType) $title
        }
        if {$title == "boardtype:"} {
            moni::get_param 2 $line
            set ::moni::M(BoardType) $title
        }
	if {$title == "agingtime:"} {
            moni::get_param 2 $line
            set ::moni::M(AgingTime) $title
        }
        if {$title == "testtype:"} {
            ::moni::get_boardtypenum
            if {$::moni::M(BoardTypeNum) == 5 || $::moni::M(BoardTypeNum) == 69} {
                ::moni::first_test_select
            } else {
                moni::get_param 2 $line
                set ::moni::M(TestType) $title
            }
        }
        if {$title == "date:"} {
            moni::get_param 2 $line
            set ::moni::M(DATE) $title
        }		
        if {$title == "prompts:"} {
            moni::get_param 2 $line
            set ::moni::M(PROMPTS) $title
        }				
        if {$title == "user:"} {
            moni::get_param 2 $line
            set ::moni::M(USER) $title
        }				
        if {$title == "password:"} {
            moni::get_param 2 $line
            set ::moni::M(PASSWORD) $title
        }				
        if {$title == "line:"} {
            moni::get_param 2 $line
            set ::moni::M(LINE) $title
        }
        if {$title == "shift:"} {
            moni::get_param 2 $line
            set ::moni::M(SHIFT) $title
        }
        if {$title == "ws_id:"} {
            moni::get_param 2 $line
            set ::moni::M(WS_ID) $title
        }
        if {$title == "operator:"} {
            moni::get_param 2 $line
            set ::moni::M(OPERATOR) $title
        }
        if {$title == "rack:"} {
            moni::get_param 2 $line
            set ::moni::M(RACK) $title
        }
        if {$title == "lot_no:"} {
            moni::get_param 2 $line
            set ::moni::M(LOT_NO) $title
        }
        if {$title == "manufactory:"} {
            moni::get_param 2 $line
            set ::moni::M(Manufactory) $title
        }
        if {$title == "agingflag:"} {
            moni::get_param 2 $line
            set ::moni::M(Agingflag) $title
        }
        if {$title == "debug:"} {
            moni::get_param 2 $line
            set ::moni::M(Debug) $title
        }
        if {$title == "local_01:"} {
            moni::get_param 2 $line
            set ::moni::M(LOCAL_01) $title
        }
        if {$title == "Ispullcables:"} {
            moni::get_param 2 $line
            set ::moni::M(Ispullcables) $title
        }
        if {$title == "wait ram:"} {
            moni::get_param 2 $line
            set ::moni::M(waitRamTime) $title
        }
        if {$title == "wait mem:"} {
            moni::get_param 2 $line
            set ::moni::M(waitMemTime) $title
        }
        if {$title == "wait aging:"} {
            moni::get_param 2 $line
            set ::moni::M(waitAingTime) $title
        }
        if {$title == "wait watchdog:"} {
            moni::get_param 2 $line
            set ::moni::M(waitWatchdogTime) $title
        }
        if {$title == "wait mantest:"} {
            moni::get_param 2 $line
            set ::moni::M(waitMantestTime) $title
        }
        if {$title == "wait boot:"} {
            moni::get_param 2 $line
            set ::moni::M(waitBootTime) $title
        }
        if {$title == "wait showboard:"} {
            moni::get_param 2 $line
            set ::moni::M(waitShowboardTime) $title
        }
        if {$title == "wait LED test:"} {
            moni::get_param 2 $line
            set ::moni::M(waitLEDtime) $title
        }

    }
    close $file
}

#��λʱ��������Ϣ�����²���ʱ����Ҫ��ʼ��
proc moni::sn_init {} {
    variable M

    set ::moni::M(MAC_DASH)            0
    set ::moni::M(SHOWBOARDPOSGOT)     0
    set ::moni::M(SHOWCPUBOARDPOSGOT)  0
    set ::moni::M(SHOWRTC)  0
    set ::moni::M(SHOWMANAGEMAC) 0
    set ::moni::M(SN)                  ""      ;# DUT���, ��ҵԱ���� Char(30)
    if {$::moni::M(LOCAL_01) == "n"} {
    set ::moni::M(LINE)                ""      ;# �߱�, ��ҵԱ���� Char(6)
    set ::moni::M(SHIFT)               ""      ;# ���, ��ҵԱ���� Char(4)
    }
    set ::moni::M(WS_ID)               ""      ;# վ��, ��ҵԱ���� or ������� Char(6)
    set ::moni::M(MAC_ID)              ""      ;# ��ʼMac ID, ��ҵԱ���� or ������� Char(12)
    set ::moni::M(MAC_QTY)             0       ;# Mac ID ʹ����, ��������0
    set ::moni::M(USED)                0       ;# ���Mac ID�ж��ٸ�S/N�ù�����������0
    set ::moni::M(CHECK)               ""      ;# Shop floor������֤�룬��PASS�� or ��FAIL�� or ��RETEST��
    set ::moni::M(CHECK_MESSAGE)       ""      ;# Shop floor������֤��Ϣ
if {$::moni::M(LOCAL_01) == "n"} {
    set ::moni::M(OPERATOR)            ""      ;# ��ҵԱ���ţ���ҵԱ���� Char(10)
    set ::moni::M(RACK)                ""      ;# ����վ��ţ���ҵԱ���� Char(6)
    set ::moni::M(LOT_NO)              ""      ;# ջ���ţ���ҵԱ���� Char(30)
    #set ::moni::M(TEST_VER)            ""      ;# ���Գ���汾��С����2λ
    }
    set ::moni::M(RESULT)              ""      ;# ���Խ����������� Char(1)
    set ::moni::M(ERROR_CODE)          ""      ;# ����������룬������� Char(6)

    set ::moni::M(FmtErrStrChecked) 0
    set ::moni::M(BpFirstTested)    0
    set ::moni::M(BpSecondTested)   0
    set ::moni::M(GetBoot)          0
    set ::moni::M(GetRam)           0
    set ::moni::M(GetAging)         0
    set ::moni::M(GetAgingDetail)   0
    set ::moni::M(GetPower1)        0
    set ::moni::M(GetPower2)        0
    set ::moni::M(GetMemOk)         0
    set ::moni::M(GetSuccess)       0
    set ::moni::M(GetFail)          0
    set ::moni::M(StartWaitRam)     0
    set ::moni::M(ExitWaitRam)      0
    set ::moni::M(FileError)        0
    set ::moni::M(ErrorFound)       0
    set ::moni::M(BTGot)            0
    set ::moni::M(SNGot)            0
    set ::moni::M(MACGot)           0
    set ::moni::M(HWGot)            0
    set ::moni::M(FirstError)       1
    set ::moni::M(Dir)              0
    set ::moni::M(BOOTROMSame)      0
    set ::moni::M(NOSIMGSame)       0
    set ::moni::M(Reboot1)          0
    set ::moni::M(Reboot2)          0
    set ::moni::M(Reboot3)          0
    set ::moni::M(AllCableOut)      0
    set ::moni::M(TestImageStart)   0
    set ::moni::M(ImageLoaded)      0
    set ::moni::M(ImageWrited)      0
    set ::moni::M(BootLoaded)       0
    set ::moni::M(BootWrited)       0
    set ::moni::M(OverWrite)        0
    set ::moni::M(Reset1)           0
    set ::moni::M(Reset2)           0
    set ::moni::M(Reset3)           0
    set ::moni::M(MacVlan)          ""
    set ::moni::M(FirstShowTestInfo)           1        ;#������ʾ������Ϣ��
    set ::moni::M(LinkErrStr)       ""
    set ::moni::M(tested)           0
    set ::moni::M(passed)           0
    set ::moni::M(failed)           0
    set ::moni::M(autoTestFinished) 0
    set M(ptshowmac)           0
    set M(TestItem)         ""
    set M(waitdot)          0
}

#���²���ʱ��Ҫ��ʼ������Ϣ
proc moni::global_init {} {
    variable M

    set ::moni::Setup(MaxLines)     1000
    set ::moni::Setup(Ticker)       100

    set ::moni::M(Time)             0
#   set M(SetupFile)                [file join $_DIR(moni) moni.cfg]

    set ::moni::M(ResetCpu)         0
    set ::moni::M(strTemp)          ""
    set ::moni::M(sym1)             0           ;#"[" �� M(RecvBufAll.$name) �е�λ��
    set ::moni::M(sym2)             0           ;#"\r" �� M(RecvBufAll.$name) �е�λ��
    set ::moni::M(symenter)         0           ;#"\A" �� M(RecvBufAll.$name) �е�λ��

#   set M(finished)                 0
    set ::moni::M(Handled)          0
    set ::moni::M(bigindex)         ""
    set ::moni::M(Open)             0           ;# Is channel open
    set ::moni::M(Chan)             {}          ;# The open channel
    set ::moni::M(Year)             0
    set ::moni::M(Month)            0
    set ::moni::M(Day)              0
    set ::moni::M(Hour)             0
    set ::moni::M(Minute)           0
    set ::moni::M(Second)           0
    set ::moni::M(KeySwapOK)        0
    set ::moni::M(TestingFlash)     0
    set ::moni::M(GetResult)        0

    set ::moni::M(Term.MaxLines)    $::moni::Setup(MaxLines)    ;# 0: No terminal truncation, <>0: Truncate input
    set ::moni::M(Term.Ticker)      $::moni::Setup(Ticker)  ;# Terminal: RS-232 status update interval

    set ::moni::M(Term.Stop)        0       ;# 1: Don't send data to terminal
    set ::moni::M(Term.Hold)        0       ;# 1: Don't scroll terminal window after insert of incoming data
    set ::moni::M(Term.Echo)        0       ;# 1: Echo input to terminal
    set ::moni::M(Term.Log)         0       ;# 1: Log inoming data to file
    set ::moni::M(Term.Count)       0       ;# Terminal: byte counter for text formatting
    set ::moni::M(Term.TotalCount)  0       ;# Terminal: Total number of received bytes

    set ::moni::M(TTY.OutQueue)     0       ;# TTY: Number of bytes in the output queue

    set ::moni::M(TTY.Stat.RTS)     0       ;# RTS output control
    set ::moni::M(TTY.Stat.DTR)     0       ;# DTR output control
    set ::moni::M(TTY.Stat.BREAK)   0       ;# BREAK output control
    set ::moni::M(TTY.Stat.CTS)     0       ;# CTS input status
    set ::moni::M(TTY.Stat.DSR)     0       ;# DSR input status
    set ::moni::M(TTY.Stat.RING)    0       ;# Input status RING indicator
    set ::moni::M(TTY.Stat.DCD)     0       ;# Input status CARRIER detect

    set ::moni::M(TTY.Errors)       0       ;# TTY: Error counter
    set ::moni::M(TTY.LastError)    ""      ;# TTY: Last error

    set ::moni::M(Win.Raw.Input)    {}      ;# Hex-Terminal: hex input string
    set ::moni::M(Win.Raw.Input.W)  {}      ;# Widget containg hex input string

    set ::moni::M(Font)             {}      ;# Selected font
    set ::moni::M(Win.Font)         {}      ;# Font selector widget
}

################################################################################
#                               < ��ȡbitmap >

proc moni::bitmap { name } {
    global _DIR
    Bitmap::get [file join $_DIR(images) $name]
}

################################################################################
#                                   < �˳� >

proc moni::appExit {} {
    exit
}

################################################################################
#                                   < ���� >

proc moni::appHelpAbout {} {
    tk_messageBox -message "$moni::MSG(appHelpAbout_msg1) \n\n $moni::MSG(appHelpAbout_msg2)  $moni::M(TEST_VER)"
}

################################################################################
#                                 < ������ >

::moni::init      ;#�������

update
