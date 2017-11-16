proc moni::ticker {} {
    variable M

    ::moni::update_status
    after $M(Term.Ticker) ::moni::ticker
}

proc moni::reader {} {
    variable M
    variable ConChan

    set name $::moni::Cfg(name)
    foreach name [array names ConChan] {
        if { [catch {read $ConChan($name)} str] } {
            incr M(TTY.Errors)
            if { [catch {fconfigure $ConChan($name) -lasterror} M(TTY.LastError)] } {
                set M(TTY.LastError) "read error"
            }
        } else {
            #begin��yueql,2011.01.07,����ӡ��Ϣ��ǰ���Խ����ӡ�ַ��ҵ�����
            if { ! $M(Term.Stop) } {
                ::moni::tty_in $name $str
            }
            #end,��yueql,2011.01.07,����ӡ��Ϣ��ǰ���Խ����ӡ�ַ��ҵ�����
            incr M(Term.TotalCount) [string length $str]
#            tk_messageBox -message $str

#            if {$M(RecvFlag.$name) == 1} {
                set M(RecvBuf.$name) ""
                append M(RecvBuf.$name) $str
                if {$::moni::M(FirstShowTestInfo) == 0} {
                    set ::moni::M(FirstShowTestInfo) 1
                    catch {destroy .commonDlg}
                    wm state . iconic  ;#yueql,��С��������
                    ::moni::show_test_info_dlg
                }
#                .testInfoDlg.labf2.t fastinsert end $str
#            }
            append M(RecvBufAll.$name) $str
 
            set ::moni::M(strTemp) $M(RecvBufAll.$name)
			
			::moni::logAddCom $str
			
            # �ղ��ȡSN��MAC��
                ;#�ж��Ƿ�õ���show cpuboard��������ʾ��
            if {$::moni::M(SHOWCPUBOARDPOSGOT) == 0} {
                set showcpuboardpos [string first "show cpuboard" $::moni::M(strTemp) 100]
                set mac_index [string first "CPU  MAC:" $::moni::M(strTemp) $showcpuboardpos]
                set enter1 [string first "\x0A" $::moni::M(strTemp) $showcpuboardpos]
                set enter2 [string first "\x0A" $::moni::M(strTemp) $mac_index]
                if {$showcpuboardpos>0 && $mac_index>$showcpuboardpos && $enter1>$showcpuboardpos && $enter2>$mac_index} {
                    set ::moni::M(SHOWCPUBOARDPOSGOT) 1

                    if {$::moni::M(BoardTypeNum) == 5 || $::moni::M(BoardTypeNum) == 69} {
                        if {$::moni::M(BTGot) == 0} {    ;#��ȡ�忨����
                            ::moni::wait 100
                            set bt_index [string first "Board Type is " $::moni::M(strTemp) $showcpuboardpos]
                            set enter [string first "\x0A" $::moni::M(strTemp) $bt_index]
                            if {$bt_index>$showcpuboardpos && $enter>$bt_index} {    ;#1-2λ�忨����
                                set boardtypenum [string range $::moni::M(strTemp) [expr {$bt_index + 14}] [expr {$enter - 1}]]
                                set ::moni::M(BTGot) 1
                                ::moni::get_boardtypenum
                                if {$::moni::M(BoardTypeNum) != $boardtypenum} {
                                    set ::moni::M(ErrorFound) 1
                                    set ::moni::M(HandleString) 0
                                    if {$::moni::M(Manufactory) == "01"} {
                                        set ::moni::M(ERROR_CODE) "T484"
                                    }
                                    catch { .testInfoDlg.labf2.t fastinsert end "\n$moni::MSG(reader_type_msg)!\n" }
                                    catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext��ʾ��10000��
                                    ::moni::savelog "$moni::MSG(reader_type_msg)\n"
                                    ::moni::saveerrlog "$moni::MSG(reader_type_msg)\n"
                                    if {$::moni::M(TestType) == "F/T"} {
                                        tk_messageBox -message "$moni::MSG(reader_type_msg) $::moni::M(BoardTypeNum) (should be $boardtypenum)!"
                                    } elseif {$::moni::M(TestType) == "P/T"} {
                                        tk_messageBox -message "$moni::MSG(reader_type_msg)!"
                                    }
                                    ::moni::get_result

                                  return
                                }
                                ::moni::get_producttype
                            }
                        }

                        if {$::moni::M(SNGot) == 0} {    ;#��ȡSN
                            ::moni::wait 100
                            set sn_index [string first "S/N: " $::moni::M(strTemp) $showcpuboardpos]
                            set enter [string first "\x0A" $::moni::M(strTemp) $sn_index]

                            if {$sn_index>100 && $enter>$sn_index} {    ;#10λ���к�
                                set ::moni::M(SNGot) 1
                                set sn [string range $::moni::M(strTemp) [expr {$sn_index + 5}] [expr {$enter - 1}]]

                                if {$::moni::M(SN) != $sn} {
                                    set ::moni::M(ErrorFound) 1
                                    set ::moni::M(HandleString) 0
                                    if {$::moni::M(Manufactory) == "01"} {
                                        set ::moni::M(ERROR_CODE) "T480"
                                    }
                                    catch { .testInfoDlg.labf2.t fastinsert end "\n$moni::MSG(reader_sn_msg)!\n" }
                                    catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext��ʾ��10000��
                                    ::moni::savelog "$moni::MSG(reader_sn_msg)\n"
                                    ::moni::saveerrlog "$moni::MSG(reader_sn_msg)\n"
                                    if {$::moni::M(TestType) == "F/T"} {
                                        tk_messageBox -message "$moni::MSG(reader_sn_msg) $::moni::M(SN)(should be $sn)!"
                                    } elseif {$::moni::M(TestType) == "P/T"} {
                                        tk_messageBox -message "$moni::MSG(reader_sn_msg)!"
                                    }
                                    ::moni::get_result
                                  return
                                }

                            }
                        }
                        if {$::moni::M(HWGot) == 0} {    ;#��ȡhardware version
                            ::moni::wait 100
                            set hw_index [string first "H/W: " $::moni::M(strTemp) $showcpuboardpos]
                            set enter [string first "\x0A" $::moni::M(strTemp) $hw_index]
                            set space1 [string first "\x20" $::moni::M(strTemp) $hw_index]
                            set space2 [string first "\x20" $::moni::M(strTemp) [expr {$space1 + 1}]]

                            if {$hw_index>0 && $enter>$hw_index} {
                                #BEGIN: Added by liuyce, 2010/4/19 bug 42375  ��׽�汾��ʱ��Ҫ���˵�����Ŀո�     
                                if {$hw_index<$space1 && $space1<$space2 && $space2<$enter} {
                                    set hwversion [string range $::moni::M(strTemp) [expr {$hw_index + 5}] [expr {$space2 - 1}]]
                                } else {
                                    set hwversion [string range $::moni::M(strTemp) [expr {$hw_index + 5}] [expr {$enter - 1}]]                                    		
                                }
                                #END:   Added by liuyce, 2010/4/19 
                                set ::moni::M(HWGot) 1
                                if {$::moni::M(BoardTypeNum) != 6 && $::moni::M(BoardTypeNum) != 9 \
                                    && $::moni::M(BoardTypeNum) != 70 && $::moni::M(BoardTypeNum) != 73} {
                                    catch {.testInfoDlg.labf1.label2 configure -text $::moni::M(MacVlan)}
                                    catch {.testInfoDlg.labf1.label4 configure -text $::moni::M(SN)}
                                }
                                catch {.testInfoDlg.labf1.label8 configure -text $::moni::M(HWVersion)}
                                catch {.testInfoDlg.labf1.label10 configure -text $::moni::M(PN)}
                                catch {.testInfoDlg.labf1.label12 configure -text $::moni::M(BoardType)}
                                if {$::moni::M(HWVersion) != $hwversion} {
                                    set ::moni::M(ErrorFound) 1
                                    set ::moni::M(HandleString) 0
                                    if {$::moni::M(Manufactory) == "01"} {
                                        set ::moni::M(ERROR_CODE) "T483"
                                    }
                                    catch { .testInfoDlg.labf2.t fastinsert end "\n$moni::MSG(reader_hw_msg)!\n" }
                                    catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext��ʾ��10000��
                                    ::moni::savelog "$moni::MSG(reader_hw_msg)\n"
                                    ::moni::saveerrlog "$moni::MSG(reader_hw_msg)\n"
                                    if {$::moni::M(TestType) == "F/T"} {
                                        tk_messageBox -message "$moni::MSG(reader_hw_msg) $::moni::M(HWVersion) (should be $hwversion)!"
                                    } elseif {$::moni::M(TestType) == "P/T"} {
                                        tk_messageBox -message "$moni::MSG(reader_hw_msg)!"
                                    }
                                    ::moni::get_result
                                    return
                                }
                            }
                        }

                    }



                    #CPU�۰�Ͳ���CPU�۰���߿�ֻ��Ҫ��CPU Ethernet MAC����һ����;
                    if {$::moni::M(BoardTypeNum) == 5 || $::moni::M(BoardTypeNum) == 19 \
                        || $::moni::M(BoardTypeNum) == 20 || $::moni::M(BoardTypeNum) == 23 \
                        || $::moni::M(BoardTypeNum) == 24 || $::moni::M(BoardTypeNum) == 25 \
                        || $::moni::M(BoardTypeNum) == 26 || $::moni::M(BoardTypeNum) == 27 \
                        || $::moni::M(BoardTypeNum) == 29 \
                        || $::moni::M(BoardTypeNum) == 33 || $::moni::M(BoardTypeNum) == 34 \
                        || $::moni::M(BoardTypeNum) == 36 || $::moni::M(BoardTypeNum) == 37 \
                        || $::moni::M(BoardTypeNum) == 42 || $::moni::M(BoardTypeNum) == 43 \
                        || $::moni::M(BoardTypeNum) == 69 || $::moni::M(BoardTypeNum) == 83 \
                        || $::moni::M(BoardTypeNum) == 84 || $::moni::M(BoardTypeNum) == 87 \
                        || $::moni::M(BoardTypeNum) == 88 || $::moni::M(BoardTypeNum) == 89 \
                        || $::moni::M(BoardTypeNum) == 90 || $::moni::M(BoardTypeNum) == 91 \
                        || $::moni::M(BoardTypeNum) == 93 || $::moni::M(BoardTypeNum) == 94 \
                        || $::moni::M(BoardTypeNum) == 97 || $::moni::M(BoardTypeNum) == 98 \
                        || $::moni::M(BoardTypeNum) == 100 || $::moni::M(BoardTypeNum) == 101 \
                        || $::moni::M(BoardTypeNum) == 15 || $::moni::M(BoardTypeNum) == 28 \
                        || $::moni::M(BoardTypeNum) == 31 || $::moni::M(BoardTypeNum) == 32 \
                        || $::moni::M(BoardTypeNum) == 79 || $::moni::M(BoardTypeNum) == 92 \
                        || $::moni::M(BoardTypeNum) == 95 || $::moni::M(BoardTypeNum) == 96 \
                        || $::moni::M(BoardTypeNum) == 106 || $::moni::M(BoardTypeNum) == 107 \
                        || $::moni::M(BoardTypeNum) == 131 || $::moni::M(BoardTypeNum) == 132 \
                        || $::moni::M(BoardTypeNum) == 136 || $::moni::M(BoardTypeNum) == 137 \
                        || $::moni::M(BoardTypeNum) == 138 || $::moni::M(BoardTypeNum) == 145 \
                        || $::moni::M(BoardTypeNum) == 134 || $::moni::M(BoardTypeNum) == 103 \
                        || $::moni::M(BoardTypeNum) == 39 || $::moni::M(BoardTypeNum) == 38} {
                        ;#����CPU�۰�����ؿ�����M2����Zoma��ʽ����Ҫ��CPU Ethernet MAC��VLAN MAC�ͼ�Ⱥ����MAC����������;



                        set macvlan [string range $::moni::M(strTemp) [expr {$mac_index + 10}] [expr {$enter2 - 1}]]
                        set ::moni::M(MAC_DASH) $macvlan
                        set macvlan1 [string range $macvlan 0 1]
                        set macvlan2 [string range $macvlan 3 4]
                        set macvlan3 [string range $macvlan 6 7]
                        set macvlan4 [string range $macvlan 9 10]
                        set macvlan5 [string range $macvlan 12 13]
                        set macvlan6 [string range $macvlan 15 16]
                        set macvlan "$macvlan1$macvlan2$macvlan3$macvlan4$macvlan5$macvlan6"

                        if {$::moni::M(MacVlan) != $macvlan} {
                            set ::moni::M(ErrorFound) 1
                            set ::moni::M(HandleString) 0
                            if {$::moni::M(Manufactory) == "01"} {
                                set ::moni::M(ERROR_CODE) "T482"
                            }
                            catch { .testInfoDlg.labf2.t fastinsert end "\n$moni::MSG(reader_mac_msg)!\n" }
                            catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext��ʾ��10000��
                            ::moni::savelog "$moni::MSG(reader_mac_msg)\n"
                            ::moni::saveerrlog "$moni::MSG(reader_mac_msg)\n"
                            if {$::moni::M(TestType) == "F/T"} {
                                tk_messageBox -message "$moni::MSG(reader_mac_msg) $::moni::M(MacVlan) (should be $macvlan)!"
                            } elseif {$::moni::M(TestType) == "P/T"} {
                                tk_messageBox -message "$moni::MSG(reader_mac_msg)!"
                            }
                            ::moni::get_result
                          return
                        }
                    }

                    set moni::M(ShowboardCheck) 1
                }
            }

            ;#�ж��Ƿ�õ���show board��������ʾ��
            if {$::moni::M(SHOWBOARDPOSGOT) == 0} {
                set showboardpos [string first "show board" $::moni::M(strTemp) 100]
                set macvlan_index [string first "Vlan MAC:" $::moni::M(strTemp) $showboardpos]
                set maccpu_index [string first "CPU  MAC:" $::moni::M(strTemp) $showboardpos]
                set enter1 [string first "\x0A" $::moni::M(strTemp) $showboardpos]
                set enter2 [string first "\x0A" $::moni::M(strTemp) $macvlan_index]
                set enter3 [string first "\x0A" $::moni::M(strTemp) $maccpu_index]

                if {$showboardpos>0 && $macvlan_index>$showboardpos && $maccpu_index>$macvlan_index && $enter1>$showboardpos && $enter2>$macvlan_index && $enter3>$maccpu_index} {
                    set ::moni::M(SHOWBOARDPOSGOT) 1
                    ;#tk_messageBox -message "$::moni::M(strTemp)"

                    if {$::moni::M(BoardTypeNum) != 5 && $::moni::M(BoardTypeNum) != 69} {
                        if {$::moni::M(BTGot) == 0} {    ;#��ȡ�忨����
                            ::moni::wait 100
                            set bt_index [string first "Board Type is " $::moni::M(strTemp) $showboardpos]
                            set enter [string first "\x0A" $::moni::M(strTemp) $bt_index]
                            if {$bt_index>$showboardpos && $enter>$bt_index} {    ;#1-2λ�忨����
                                set boardtypenum [string range $::moni::M(strTemp) [expr {$bt_index + 14}] [expr {$enter - 1}]]
                                set ::moni::M(BTGot) 1
                                #::moni::get_boardtype
                                ::moni::get_boardtypenum
                                if {$::moni::M(BoardTypeNum) != $boardtypenum} {
                                    set ::moni::M(ErrorFound) 1
                                    set ::moni::M(HandleString) 0
                                    set moni::M(ShowboardCheck) 2
                                    if {$::moni::M(Manufactory) == "01"} {
                                        set ::moni::M(ERROR_CODE) "T484"
                                    }
                                    catch { .testInfoDlg.labf2.t fastinsert end "\n$moni::MSG(reader_type_msg)!\n" }
                                    catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext��ʾ��10000��
                                    ::moni::savelog "$moni::MSG(reader_type_msg)\n"
                                    ::moni::saveerrlog "$moni::MSG(reader_type_msg)\n"
                                    if {$::moni::M(TestType) == "F/T"} {
                                        tk_messageBox -message "$moni::MSG(reader_type_msg) $::moni::M(BoardTypeNum) (should be $boardtypenum)!"
                                    } elseif {$::moni::M(TestType) == "P/T"} {
                                        tk_messageBox -message "$moni::MSG(reader_type_msg)!"
                                    }
                                    ::moni::get_result
                                  return
                                }
                                ::moni::get_producttype
                            }
                        }
                    }

                    ;#BEGIN: Added by jianghtc, 2010/03/26 bug[41903]
                    ;#��֤���ؿ���5950-24/26��vlan mac��cpu mac�����ؿ�mac�ں�����֤
                    if {$::moni::M(BoardTypeNum) == 1 || $::moni::M(BoardTypeNum) == 65\
        		        || $::moni::M(BoardTypeNum) == 13 || $::moni::M(BoardTypeNum) == 77 \
        		        || $::moni::M(BoardTypeNum) == 15 || $::moni::M(BoardTypeNum) == 79 \
        		        || $::moni::M(BoardTypeNum) == 16 || $::moni::M(BoardTypeNum) == 80 \
        		        || $::moni::M(BoardTypeNum) == 18 || $::moni::M(BoardTypeNum) == 82 \
        		        || $::moni::M(BoardTypeNum) == 28 || $::moni::M(BoardTypeNum) == 92 \
        		        || $::moni::M(BoardTypeNum) == 31 || $::moni::M(BoardTypeNum) == 95 \
        		        || $::moni::M(BoardTypeNum) == 32 || $::moni::M(BoardTypeNum) == 96 \
        		        || $::moni::M(BoardTypeNum) == 38 || $::moni::M(BoardTypeNum) == 102 \
        		        || $::moni::M(BoardTypeNum) == 39 || $::moni::M(BoardTypeNum) == 103 \
        		        || $::moni::M(BoardTypeNum) == 128 || $::moni::M(BoardTypeNum) == 129 \
        		        || $::moni::M(BoardTypeNum) == 170 || $::moni::M(BoardTypeNum) == 171 \
				|| $::moni::M(BoardTypeNum) == 362 || $::moni::M(BoardTypeNum) == 363 \
        		        || $::moni::M(BoardTypeNum) == 130 || [expr {$::moni::M(BoardTypeNum) == 131 \
        		        || $::moni::M(IsChassis) == 0}]} {

                        set macvlan $::moni::M(MacVlan)
                        set macvlan1 [string range $macvlan 0 1]
                        set macvlan2 [string range $macvlan 2 3]
                        set macvlan3 [string range $macvlan 4 5]
                        set macvlan4 [string range $macvlan 6 7]
                        set macvlan5 [string range $macvlan 8 9]
                        set macvlan6 [string range $macvlan 10 11]
                        set macdash "$macvlan1-$macvlan2-$macvlan3-$macvlan4-$macvlan5-$macvlan6";#���������ԭʼmac

                        set macvlandash [string range $::moni::M(strTemp) [expr {$macvlan_index + 10}] [expr {$enter2 - 1}]];#�Ӵ��ڽ���ȡ����vlan mac
                        set maccpudash [string range $::moni::M(strTemp) [expr {$maccpu_index + 10}] [expr {$enter3 - 1}]];#�Ӵ��ڽ���ȡ����cpu mac

                        if {[expr {$::moni::M(BoardTypeNum) == 129 || $::moni::M(BoardTypeNum) == 131}] \
                    		&& $::moni::M(IsChassis) == 0} {
                            set macplusdash $macdash
                            set rawmacplusdash $macplusdash;#���������ԭʼmac+1
                            incr_mac $rawmacplusdash
                            set rawmacplusplusdash $macplusdash;#���������ԭʼmac+1+1                               		                             		
                        } else {
                            set macplusdash 0
                            incr_mac $macdash
                            set rawmacplusdash $macplusdash;#���������ԭʼmac+1
                            incr_mac $rawmacplusdash
                            set rawmacplusplusdash $macplusdash;#���������ԭʼmac+1+1                             
                        }
                         
                        if {$macdash != $macvlandash} {
                            set ::moni::M(ErrorFound) 1
                            set ::moni::M(HandleString) 0
                            set moni::M(ShowboardCheck) 2
                            if {$::moni::M(Manufactory) == "01"} {
                                set ::moni::M(ERROR_CODE) "T482"
                            }
                            catch { .testInfoDlg.labf2.t fastinsert end "\n$moni::MSG(reader_vlanmac_msg)!\n" }
                            catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext��ʾ��10000��
                            ::moni::savelog "$moni::MSG(reader_vlanmac_msg)\n"
                            ::moni::saveerrlog "$moni::MSG(reader_vlanmac_msg)\n"
                            if {$::moni::M(TestType) == "F/T"} {
                                tk_messageBox -message "$moni::MSG(reader_vlanmac_msg) $macdash (should be $macvlandash)!"
                            } elseif {$::moni::M(TestType) == "P/T"} {
                                tk_messageBox -message "$moni::MSG(reader_vlanmac_msg)!"
                            }
                            ::moni::get_result
                            return
                        }

		    } 
                    ;#END:   Added by jianghtc, 2010/03/26 bug[41903]

                    #/* BEGIN: Modified by jianghtc, 2010/01/26 ����[40676] */
                    if {$::moni::M(SNGot) == 0 && $::moni::M(BoardTypeNum) != 199 && $::moni::M(BoardTypeNum) != 200
                        && $::moni::M(BoardTypeNum) != 9 && $::moni::M(BoardTypeNum) != 73} {    ;#��ȡSN
                        ::moni::wait 100
                        #tk_messageBox -message "$::moni::M(strTemp)"
                        set sn_index [string first "S/N: " $::moni::M(strTemp) $showboardpos]
                        #tk_messageBox -message "M(SN) = $::moni::M(SN), showboardpos = $showboardpos"
                        set enter [string first "\x0A" $::moni::M(strTemp) $sn_index]
                        set after_sn [string range $::moni::M(strTemp) $sn_index [expr {$sn_index + 100}]]
                        #tk_messageBox -message "sn_index = $sn_index, enter = $enter, after_sn = $after_sn"
                        if {$sn_index>0 && $enter>$sn_index} {    ;#10λ���к�
                            set ::moni::M(SNGot) 1
                            set sn [string range $::moni::M(strTemp) [expr {$sn_index + 5}] [expr {$enter - 1}]]
                            if {$::moni::M(SN) != $sn} {
                                set ::moni::M(ErrorFound) 1
                                set ::moni::M(HandleString) 0
                                set moni::M(ShowboardCheck) 2
                                if {$::moni::M(Manufactory) == "01"} {
                                    set ::moni::M(ERROR_CODE) "T480"
                                }
                                catch { .testInfoDlg.labf2.t fastinsert end "\n$moni::MSG(reader_sn_msg)!\n" }
                                catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext��ʾ��10000��
                                ::moni::savelog "$moni::MSG(reader_sn_msg)\n"
                                ::moni::saveerrlog "$moni::MSG(reader_sn_msg)\n"
                                if {$::moni::M(TestType) == "F/T"} {
                                    tk_messageBox -message "$moni::MSG(reader_sn_msg) $::moni::M(SN) (should be $sn)!"
                                } elseif {$::moni::M(TestType) == "P/T"} {
                                    tk_messageBox -message "$moni::MSG(reader_sn_msg)!"
                                }
                                ::moni::get_result
                              return
                            }

                        }

                    }

		#��ȡPN
		::moni::wait 100
		#tk_messageBox -message "$::moni::M(strTemp)"
		set pn_index [string first "P/N: " $::moni::M(strTemp) $showboardpos]
		#tk_messageBox -message "M(PN) = $::moni::M(PN), showboardpos = $showboardpos"
		set enter [string first "\x0A" $::moni::M(strTemp) $pn_index]
		set after_pn [string range $::moni::M(strTemp) $pn_index [expr {$pn_index + 100}]]
		#tk_messageBox -message "sn_index = $sn_index, enter = $enter, after_sn = $after_sn"
		if {$pn_index>0 && $enter>$pn_index} {    ;#10λ���к�
		    set ::moni::M(SNGot) 1
		    set pn [string range $::moni::M(strTemp) [expr {$pn_index + 5}] [expr {$enter - 1}]]
		    if {$::moni::M(PN) != $pn} {
			set ::moni::M(ErrorFound) 1
			set ::moni::M(HandleString) 0
			set moni::M(ShowboardCheck) 2
			if {$::moni::M(Manufactory) == "01"} {
			    set ::moni::M(ERROR_CODE) "T480"
			}
			catch { .testInfoDlg.labf2.t fastinsert end "\n$moni::MSG(reader_sn_msg)!\n" }
			catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext��ʾ��10000��
			::moni::savelog "$moni::MSG(reader_pn_msg)\n"
			::moni::saveerrlog "$moni::MSG(reader_pn_msg)\n"
			if {$::moni::M(TestType) == "F/T"} {
			    tk_messageBox -message "$moni::MSG(reader_pn_msg) $::moni::M(PN) (should be $pn)!"
			} elseif {$::moni::M(TestType) == "P/T"} {
			    tk_messageBox -message "$moni::MSG(reader_pn_msg)!"
			}
			::moni::get_result
		      return
		    }

		}

                    #/* END:   Modified by jianghtc, 2010/01/26 ����[40676] */
                    if {$::moni::M(HWGot) == 0} {    ;#��ȡhardware version
                        ::moni::wait 100
                        set hw_index [string first "H/W: " $::moni::M(strTemp) $showboardpos]
                        set enter [string first "\x0A" $::moni::M(strTemp) $hw_index]
                        set space1 [string first "\x20" $::moni::M(strTemp) $hw_index]
                        set space2 [string first "\x20" $::moni::M(strTemp) [expr {$space1 + 1}]]

                        if {$hw_index>0 && $enter>$hw_index} {
                            #tk_messageBox -message "enter = $enter, hw_index = $hw_index"
                            #tk_messageBox -message "$::moni::M(strTemp)"
                            #BEGIN: Added by liuyce, 2010/4/19 bug 42375  ��׽�汾��ʱ��Ҫ���˵�����Ŀո�                                                               
                            if {$hw_index<$space1 && $space1<$space2 && $space2<$enter} {
                                set hwversion [string range $::moni::M(strTemp) [expr {$hw_index + 5}] [expr {$space2 - 1}]]
                            } else {
                                set hwversion [string range $::moni::M(strTemp) [expr {$hw_index + 5}] [expr {$enter - 1}]]                                    		
                            }
                            #END:   Added by liuyce, 2010/4/19 
                            #set hwversion [string range $::moni::M(strTemp) $hw_index [expr {$hw_index + 160}]]
                            set ::moni::M(HWGot) 1
                            if {$::moni::M(BoardTypeNum) != 6 && $::moni::M(BoardTypeNum) != 9 \
                                && $::moni::M(BoardTypeNum) != 70 && $::moni::M(BoardTypeNum) != 73} {
                                catch {.testInfoDlg.labf1.label2 configure -text $::moni::M(MacVlan)}
                                catch {.testInfoDlg.labf1.label4 configure -text $::moni::M(SN)}
                            }
                            catch {.testInfoDlg.labf1.label8 configure -text $::moni::M(HWVersion)}
                            catch {.testInfoDlg.labf1.label10 configure -text $::moni::M(PN)}
                            catch {.testInfoDlg.labf1.label12 configure -text $::moni::M(BoardType)}
                            #BEGIN: Modified by jianghtc, 2010/03/16 bug[41485]
                            #ȥ��$hwversion����Ŀո񣬷���Ƚϲ�ͨ��
                            #set hwversion [string range $hwversion [expr 0] [expr 6]]
                            #END:   Modified by jianghtc, 2010/03/16 bug[41485]
                            if {$::moni::M(HWVersion) != $hwversion} {
                                set ::moni::M(ErrorFound) 1
                                set ::moni::M(HandleString) 0
                                set moni::M(ShowboardCheck) 2
                                if {$::moni::M(Manufactory) == "01"} {
                                    set ::moni::M(ERROR_CODE) "T483"
                                }
                                catch { .testInfoDlg.labf2.t fastinsert end "\n$moni::MSG(reader_hw_msg)!\n" }
                                catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext��ʾ��10000��
                                ::moni::savelog "$moni::MSG(reader_hw_msg)\n"
                                ::moni::saveerrlog "$moni::MSG(reader_hw_msg)\n"
                                if {$::moni::M(TestType) == "F/T"} {
                                    tk_messageBox -message "$moni::MSG(reader_hw_msg) $::moni::M(HWVersion) (should be $hwversion)!"
                                } elseif {$::moni::M(TestType) == "P/T"} {
                                    tk_messageBox -message "$moni::MSG(reader_hw_msg)!"
                                }
                                ::moni::get_result
                                return
                            }
                        }
                    }
                    set moni::M(ShowboardCheck) 1
                }

            }

            ;# BEGIN: Added by liuyce, 2010/3/25   PN:41852 �����rtcshow�Ľ���, �жϰ忨ʱ���ʺ���pc���Ǻ�                
            ;#�ж��Ƿ�õ���rtcshow��������ʾ��
            if {$::moni::M(SHOWRTC) == 0} {   
                ;#��Щ�忨��Ҫ���Դ���
                if {$::moni::M(BoardTypeNum) == 38 || $::moni::M(BoardTypeNum) == 102 \
                    || $::moni::M(BoardTypeNum) == 39 || $::moni::M(BoardTypeNum) == 103} {
                    set showrtcpos [string first "rtcshow" $::moni::M(strTemp) 100]
                    set year_index [string first "20" $::moni::M(strTemp) $showrtcpos]
                    set time_index [string first " " $::moni::M(strTemp) $year_index]
                    set enter1 [string first "\x0A" $::moni::M(strTemp) $showrtcpos]
                    ;#�жϻ�ȡʱ��ĺϷ���
                    if {$showrtcpos>0 && $year_index>$showrtcpos && $time_index>$year_index && $enter1>$showrtcpos} {
                        set ::moni::M(SHOWRTC) 1

                        ;#��ȡ��ǰ����ʱ��
                        ::moni::get_time
                        ;#tk_messageBox -message "$M(Year) $M(Month) $M(Day) $M(Hour) $M(Minute) $M(Second)"
                        
                        ;#��ȡ�忨ʱ��
                        ::moni::wait 100
                        set slash1 [string first "/" $::moni::M(strTemp) $year_index]
                        set slash2 [string first "/" $::moni::M(strTemp) [expr {$slash1 + 1}]]
                        set year [string range $::moni::M(strTemp) [expr {$year_index - 2}] [expr {$slash1 - 1}]]
                        set month [string range $::moni::M(strTemp) [expr {$slash1 + 1}] [expr {$slash2 - 1}]]
                        set day [string range $::moni::M(strTemp) [expr {$slash2 + 1}] [expr {$time_index - 1}]]

                        ::moni::wait 100
                        set colon1 [string first ":" $::moni::M(strTemp) $time_index]
                        set colon2 [string first ":" $::moni::M(strTemp) [expr {$colon1 + 1}]]
                        set hour [string range $::moni::M(strTemp) [expr {$time_index + 1}] [expr {$colon1 - 1}]]
                        set minute [string range $::moni::M(strTemp) [expr {$colon1 + 1}] [expr {$colon1 + 2}]]
                        ;#tk_messageBox -message "-$year-$month-$day-$hour-$minute-"

                        ;#�Ƚϵ���ʱ����忨ʱ��,������Ҫ��Ϊ�˼��rtc����Ƿ���,���������Խϴ�.rtc׼ȷ�Ȳ�����autotest��rtc�����м���
                        set check_time 0
                        if {$M(Day) == $day} {                            
                            if {$M(Hour) == $hour} {
                                set check_time 1
                            } elseif {$M(Hour) - $hour > 0 && $M(Hour) - $hour < 2} {
                                set check_time 1
                            } elseif {$hour -$M(Hour) > 0 && $hour - $M(Hour) < 2} {
                                set check_time 1
                            }
                        }
                        
                        if {$check_time == 0} {
                            set ::moni::M(ErrorFound) 1
                            set ::moni::M(HandleString) 0
                            if {$::moni::M(Manufactory) == "01"} {
                                set ::moni::M(ERROR_CODE) "T510"
                            }                                  
                            catch { .testInfoDlg.labf2.t fastinsert end "\n$moni::MSG(reader_rtc_msg)\n" }
                            catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext��ʾ��10000��
                            ::moni::savelog "$moni::MSG(reader_rtc_msg)\n"
                            ::moni::saveerrlog "$moni::MSG(reader_rtc_msg)\n"
                            tk_messageBox -message "$moni::MSG(reader_rtc_msg)\n"
                            ::moni::get_result
                            return
                        }                           
                    }                        
                }
            }
            ;# END:   Added by liuyce, 2010/3/25 

            ;#BEGIN: Added by jianghtc, 2010/03/26 bug[41903],��֤���ؿڵ�mac
            if {$::moni::M(SHOWMANAGEMAC) == 0} {
                if {$::moni::M(TestType) == "F/T" || [expr {$::moni::M(TestType) == "P/T" && $::moni::M(ptshowmac) == 1}]} { ;#yueql
                    set setmaccpupos [string first "setmac cpu" $::moni::M(strTemp) 100]
                    set mac_index [string first "Management port mac: " $::moni::M(strTemp) $setmaccpupos]
                    set enter1 [string first "\x0A" $::moni::M(strTemp) $mac_index]
                    if {$::moni::M(TestType) == "P/T"} {
                        set setmaccpupos [string last "setmac cpu" $::moni::M(strTemp) 100]
                        set mac_index [string last "Management port mac: " $::moni::M(strTemp) $setmaccpupos]
                        set enter1 [string last "\x0A" $::moni::M(strTemp) $mac_index]
                    }
                    ;#�жϻ�ȡ���ؿ�mac�ĺϷ���
                    if {$setmaccpupos>0 && $mac_index>$setmaccpupos && $enter1>$setmaccpupos} {
                        set ::moni::M(SHOWMANAGEMAC) 1

                        ::moni::wait 100
                        set macmanagedash [string range $::moni::M(strTemp) [expr {$mac_index + 21}] [expr {$enter1 - 1}]];#�Ӵ��ڽ���ȡ����mac

                        set macmanage1 [string range $macmanagedash 0 1]
                        set macmanage2 [string range $macmanagedash 3 4]
                        set macmanage3 [string range $macmanagedash 6 7]
                        set macmanage4 [string range $macmanagedash 9 10]
                        set macmanage5 [string range $macmanagedash 12 13]
                        set macmanage6 [string range $macmanagedash 15 16]
                        set macmanage "$macmanage1$macmanage2$macmanage3$macmanage4$macmanage5$macmanage6";#�Ӵ��ڽ���ȡ����mac

                        if {$macmanage != $::moni::M(MacVlan)} {
                            set ::moni::M(ErrorFound) 1
                            set ::moni::M(HandleString) 0
                            if {$::moni::M(Manufactory) == "01"} {
                                set ::moni::M(ERROR_CODE) "T482"
                            }
                            catch { .testInfoDlg.labf2.t fastinsert end "\n$moni::MSG(reader_mamagemac_msg)!\n" }
                            catch { .testInfoDlg.labf2.t yview 10000 }       ;#ctext��ʾ��10000��
                            ::moni::savelog "$moni::MSG(reader_mamagemac_msg)\n"
                            ::moni::saveerrlog "$moni::MSG(reader_mamagemac_msg)\n"
                            if {$::moni::M(TestType) == "F/T"} {
                                tk_messageBox -message "$moni::MSG(reader_mamagemac_msg) $::moni::M(MacVlan) (should be $macmanage)!"
                            } elseif {$::moni::M(TestType) == "P/T"} {
                                tk_messageBox -message "$moni::MSG(reader_mamagemac_msg)!"
                            }
                            ::moni::get_result
                            return
                        }
                    }
                }
            }
		    ;#END:   Added by jianghtc, 2010/03/26 bug[41903]
            
            ;#endof if {$::moni::M(TestType) == "�忨���ղ���"}


            if { $::moni::M(HandleString) == 1} {
                ::moni::handleStr $::moni::M(strTemp)
            }
            
        }
    }
    ::moni::update_status
    update idletasks
}

proc moni::handleStr { str } {
    variable M

    set braket \[
    set enter \x0A
    set sym01   0
    set val1 [string first "VALID" $str 3000]
    set val2 [string first "SWAP" $str 3000]
    set linkdownstr 0
    set fileerrstr 0

    if {$val1 >= 0 || $val2 >= 0} {
        if {$::moni::M(KeySwapOK) == 0} {
            set ::moni::M(KeySwapOK) 1
            catch {.testInfoDlg.labf2.t fastinsert end "SWAP tested!\n"}
            catch {.testInfoDlg.labf2.t yview 10000}        ;#ctext��ʾ��10000��
        }
        return      ;#���ٴ���str
    }

    ;#������ʹ�CPU�۰�Ŀ���������������������ⲻ��Ҫ���ò�������������д��intest.img
    if {$::moni::M(BoardTypeNum) != 6 && $::moni::M(BoardTypeNum) != 9 \
        && $::moni::M(BoardTypeNum) != 70 && $::moni::M(BoardTypeNum) != 73} {

        set fl [string first "\[flash:\]" $str 300]
        if {$fl >= 0} {
            if {$::moni::M(TestingFlash) == 0} {
                set ::moni::M(TestingFlash) 1
                #catch {.testInfoDlg.labf2.t fastinsert end "���ڲ���Flash��������Ҫ��������ң���ȴ�!\n"}
                #catch {.testInfoDlg.labf2.t yview 10000}        ;#ctext��ʾ��10000��
            }
        }
    }
    if { 0 } {
        ;#�������CPU���⣬д��nos.img
        if {$::moni::M(BoardTypeNum) != 5 && $::moni::M(BoardTypeNum) != 6 \
            && $::moni::M(BoardTypeNum) != 9 && $::moni::M(BoardTypeNum) != 69 \
            && $::moni::M(BoardTypeNum) != 70 && $::moni::M(BoardTypeNum) != 73} {

            if {$::moni::M(Reboot2) == 2} {
              if {$::moni::M(Dir) == 0} {
                  # Zoma��ʽ��Ʒ�Բ��Խ���Ҫд��boot.rom
                  if  {$::moni::M(BoardTypeNum) == 0 || $::moni::M(BoardTypeNum) == 0 \
                            || $::moni::M(BoardTypeNum) == 0} {

                      if {$::moni::M(BootWrited) == 0} {
                          if {$::moni::M(BootLoaded) == 0} {
                              set loadboot [string first "load boot.rom" $str 0]
                              set loadfileok 0
                            if {$loadboot > 0} {
                                set loadfileok [string first "Loading file ok" $str $loadboot]
                            }
                                if {$loadfileok > 0} {
                                    set ::moni::M(BootLoaded) 1
                                    ::moni::send_write_boot
                                }
                            } elseif {$::moni::M(BootLoaded) == 1} {
                                if {$::moni::M(OverWrite) == 0} {
                                    if {[string first "overwrite" $str 0] > 0} {
                                        set ::moni::M(OverWrite) 1
                                    	::moni::send $::moni::Cfg(name) "y\n"
                                    }
                                }
                                if {$::moni::M(BootWrited) == 0} {
                                    if {([string first "Write boot.rom OK." $str 0] > 0) || ([string first "Write file OK." $str 0] > 0)} {
                                        set ::moni::M(BootWrited) 1
                                        catch {.testInfoDlg.labf2.t fastinsert end "\nboot.rom has been written!\n"}
                                        catch {.testInfoDlg.labf2.t yview 10000}        ;#ctext��ʾ��10000��
                                    }
                                }
                            }
                      } elseif {$::moni::M(ImageWrited) == 0} {
                        if {$::moni::M(ImageLoaded) == 0} {
                            set loadimg [string first "load nos.img" $str 0]
                            set loadfileok 0
                            if {$loadimg > 0} {
                                set loadfileok [string first "Loading file ok" $str $loadimg]
                            }
                                if {$loadfileok > 0} {
                                    set ::moni::M(ImageLoaded) 1
                                    ::moni::send_write_img
                                }
                            } elseif {$::moni::M(ImageLoaded) == 1} {
                              #savelog "in handlestr ImageLoaded\n"
                              #savelog "in handlestr OverWrite = $::moni::M(OverWrite)\n"
                                if {$::moni::M(OverWrite) == 0} {
                                    set loadimg [string first "load nos.img" $str 0]
                                    set overwrite [string first "overwrite" $str [expr {$loadimg + 10}]]
                                    if {$overwrite > 0} {
                                      #savelog "in handlestr get OverWrite\n"
                                        set ::moni::M(OverWrite) 1
                                        ::moni::send $::moni::Cfg(name) "y\n"
                                        #savelog "in handlestr sent y\n"
                                    }
                                }
                                if {$::moni::M(ImageWrited) == 0} {
                                    if {[string first "Write nos.img OK" $str 0] > 0} {
                                        set ::moni::M(ImageWrited) 1
                                        catch {.testInfoDlg.labf2.t fastinsert end "nos.img has been written!\n"}
                                        catch {.testInfoDlg.labf2.t yview 10000}        ;#ctext��ʾ��10000��
                                        #::moni::get_result
                                    }
                                }
                            }
                        } else {
                          if {$::moni::M(VendorCfgLoaded) == 0} {
                            set loadcfg [string first "load vendor.cfg" $str 0]
                            set loadfileok 0
                            if {$loadcfg > 0} {
                                set loadfileok [string first "Loading file ok" $str $loadcfg]
                            }
                                if {$loadfileok > 0} {
                                    set ::moni::M(VendorCfgLoaded) 1
                                    ::moni::send_write_vendor_cfg
                                }
                            } elseif {$::moni::M(VendorCfgLoaded) == 1} {
                              #savelog "in handlestr ImageLoaded\n"
                              #savelog "in handlestr OverWrite = $::moni::M(OverWrite)\n"
                                if {$::moni::M(OverWrite) == 0} {
                                    set loadcfg [string first "load vendor.cfg" $str 0]
                                    set overwrite [string first "overwrite" $str [expr {$loadcfg + 10}]]
                                    if {$overwrite > 0} {
                                      #savelog "in handlestr get OverWrite\n"
                                        set ::moni::M(OverWrite) 1
                                        ::moni::send $::moni::Cfg(name) "y\n"
                                        #savelog "in handlestr sent y\n"
                                    }
                                }
                                if {$::moni::M(VendorCfgWrited) == 0} {
                                    if {[string first "Write vendor.cfg OK" $str 0] > 0} {
                                        set ::moni::M(VendorCfgWrited) 1
                                        catch {.testInfoDlg.labf2.t fastinsert end "vendor.cfg has been written!\n"}
                                        catch {.testInfoDlg.labf2.t yview 10000}        ;#ctext��ʾ��10000��
                                        #::moni::get_result
                                    }
                                }
                            }
                         }
                  } else {
                    if {$::moni::M(ImageWrited) == 0} {
                      if {$::moni::M(ImageLoaded) == 0} {
                          set loadimg [string first "load nos.img" $str 0]
                          set loadfileok 0
                        if {$loadimg > 0} {
                            set loadfileok [string first "Loading file ok" $str $loadimg]
                        }
                            if {$loadfileok > 0} {
                                set ::moni::M(ImageLoaded) 1
                                ::moni::send_write_img
                            }
                        } elseif {$::moni::M(ImageLoaded) == 1} {
                          #savelog "in handlestr ImageLoaded\n"
                          #savelog "in handlestr OverWrite = $::moni::M(OverWrite)\n"
                            if {$::moni::M(OverWrite) == 0} {
                                if {[string first "overwrite" $str 0] > 0} {
                                  #savelog "in handlestr get OverWrite\n"
                                    set ::moni::M(OverWrite) 1
                                    ::moni::send $::moni::Cfg(name) "y\n"
                                    #savelog "in handlestr sent y\n"
                                }
                            }
                            if {$::moni::M(ImageWrited) == 0} {
                                if {[string first "Write nos.img OK" $str 0] > 0} {
                                    set ::moni::M(ImageWrited) 1
                                    catch {.testInfoDlg.labf2.t fastinsert end "nos.img has been written!\n"}
                                    catch {.testInfoDlg.labf2.t yview 10000}        ;#ctext��ʾ��10000��
                                    #::moni::get_result
                                }
                            }
                        }
                     } elseif {$::moni::M(VendorCfgWrited) == 0} {
                          if {$::moni::M(VendorCfgLoaded) == 0} {
                            set loadcfg [string first "load vendor.cfg" $str 0]
                            set loadfileok 0
                            if {$loadcfg > 0} {
                                set loadfileok [string first "Loading file ok" $str $loadcfg]
                            }
                                if {$loadfileok > 0} {
                                    set ::moni::M(VendorCfgLoaded) 1
                                    ::moni::send_write_vendor_cfg
                                }
                            } elseif {$::moni::M(VendorCfgLoaded) == 1} {
                              #savelog "in handlestr ImageLoaded\n"
                              #savelog "in handlestr OverWrite = $::moni::M(OverWrite)\n"
                                if {$::moni::M(OverWrite) == 0} {
                                    set loadcfg [string first "load vendor.cfg" $str 0]
                                    set overwrite [string first "overwrite" $str [expr {$loadcfg + 10}]]
                                    if {$overwrite > 0} {
                                      #savelog "in handlestr get OverWrite\n"
                                        set ::moni::M(OverWrite) 1
                                        ::moni::send $::moni::Cfg(name) "y\r"
                                        #savelog "in handlestr sent y\n"
                                    }
                                }
                                if {$::moni::M(VendorCfgWrited) == 0} {
                                    if {[string first "Write vendor.cfg OK" $str 0] > 0} {
                                        set ::moni::M(VendorCfgWrited) 1
                                        catch {.testInfoDlg.labf2.t fastinsert end "vendor.cfg has been written!\n"}
                                        catch {.testInfoDlg.labf2.t yview 10000}        ;#ctext��ʾ��10000��
                                        #::moni::get_result
                                    }
                                }
                          }
                     }
                  }

                } elseif {$::moni::M(Dir) == 1} {
                    set boot_rom_index [string first "boot.rom" $str 0]
                    set ent_after_boot_rom_index 0
                    set boot_rom_info_str0 "boot.rom                                   2,023,468"
                    set boot_rom_info_str1 ""

                    set nos_img_index [string first "nos.img" $str 0]
                    set ent_after_nos_img_index 0
                    set nos_img_info_str0 "nos.img                                    2,217,366"
                    set nos_img_info_str1 ""

                    if {$::moni::M(BoardTypeNum) == 0 || $::moni::M(BoardTypeNum) == 0 \
                        || $::moni::M(BoardTypeNum) == 0} {

                        if {$boot_rom_index > 0} {
                            set ent_after_boot_rom_index [string first $enter $str $boot_rom_index]
                            if {$ent_after_boot_rom_index > 0} {
                                set boot_rom_info_str1 [string range $str $boot_rom_index $ent_after_boot_rom_index]
                                # Zome boot.rom����flash��boot.rom�ļ���С��ͬ����д
                                if {([string first $boot_rom_info_str0 $boot_rom_info_str1 0] >= 0) \
                                    && ($::moni::M(BOOTROMSame) == 0)} {
                                    set ::moni::M(BOOTROMSame) 1
                                    catch {.testInfoDlg.labf2.t fastinsert end "boot.rom being written is the same as it in Flash!\n"}
                                    catch {.testInfoDlg.labf2.t yview 10000}        ;#ctext��ʾ��10000��
                                } else {
                                    if {$::moni::M(BootLoaded) == 0} {
                                        set loadboot [string first "load boot.rom" $str 0]
                                        set loadfileok 0
                                    if {$loadboot > 0} {
                                        set loadfileok [string first "Loading file ok" $str $loadboot]
                                    }
                                        if {$loadfileok > 0} {
                                            set ::moni::M(BootLoaded) 1
                                            ::moni::send_write_boot
                                        }
                                    } elseif {$::moni::M(BootLoaded) == 1} {
                                        if {$::moni::M(OverWrite) == 0} {
                                            if {[string first "overwrite" $str 0] > 0} {
                                                set ::moni::M(OverWrite) 1
                                                ::moni::send $::moni::Cfg(name) "y\r"
                                            }
                                        }
                                        if {$::moni::M(BootWrited) == 0} {
                                            if {([string first "Write boot.rom OK." $str 0] > 0) || ([string first "Write file OK." $str 0] > 0)} {
                                                set ::moni::M(BootWrited) 1
                                                catch {.testInfoDlg.labf2.t fastinsert end "\nboot.rom has been written!\n"}
                                                catch {.testInfoDlg.labf2.t yview 10000}        ;#ctext��ʾ��10000��
                                            }
                                        }
                                    }
                                }
                            }
                        } elseif {$boot_rom_index < 0} {
                            if {$::moni::M(BootLoaded) == 0} {
                                set loadboot [string first "load boot.rom" $str 0]
                                set loadfileok 0
                            if {$loadboot > 0} {
                                set loadfileok [string first "Loading file ok" $str $loadboot]
                            }
                                if {$loadfileok > 0} {
                                    set ::moni::M(BootLoaded) 1
                                    ::moni::send_write_boot
                                }
                            } elseif {$::moni::M(BootLoaded) == 1} {
                                if {$::moni::M(OverWrite) == 0} {
                                    if {[string first "overwrite" $str 0] > 0} {
                                        set ::moni::M(OverWrite) 1
                                        ::moni::send $::moni::Cfg(name) "y\r"
                                    }
                                }
                                if {$::moni::M(BootWrited) == 0} {
                                    if {([string first "Write boot.rom OK." $str 0] > 0) || ([string first "Write file OK." $str 0] > 0)} {
                                        set ::moni::M(BootWrited) 1
                                        catch {.testInfoDlg.labf2.t fastinsert end "\nboot.rom has been written!\n"}
                                        catch {.testInfoDlg.labf2.t yview 10000}        ;#ctext��ʾ��10000��
                                    }
                                }
                            }
                        }
                    }

                    if {$nos_img_index > 0} {
                        set ent_after_nos_img_index [string first $enter $str $nos_img_index]
                        if {$ent_after_nos_img_index > 0} {
                            set nos_img_info_str1 [string range $str $nos_img_index $ent_after_nos_img_index]
                            #moni::savelog "nos_img_info_str0 = $nos_img_info_str0\n"
                            #moni::savelog "nos_img_info_str1 = $nos_img_info_str1\n"
                            #��flash��nos.img�ļ���С��ͬ����д
                            if {([string first $nos_img_info_str0 $nos_img_info_str1 0] >= 0) \
                                && ($::moni::M(NOSIMGSame) == 0)} {
                                #moni::savelog "string first nos_img_info_str0 nos_img_info_str1 0] >= 0\n"
                                set ::moni::M(NOSIMGSame) 1
                                catch {.testInfoDlg.labf2.t fastinsert end "nos.img being written is the same as it in Flash!\n"}
                                catch {.testInfoDlg.labf2.t yview 10000}        ;#ctext��ʾ��10000��
                            } else {
                                if {$::moni::M(ImageLoaded) == 0} {
                                    if {$::moni::M(BoardTypeNum) == 0 || $::moni::M(BoardTypeNum) == 0 \
                                        || $::moni::M(BoardTypeNum) == 0} {
                                        set loadimg [string first "load nos.img" $str 0]
                                        set loadfileok 0
                                    if {$loadimg > 0} {
                                        set loadfileok [string first "Loading file ok" $str $loadimg]
                                    }
                                        if {$loadfileok > 0} {
                                            set ::moni::M(ImageLoaded) 1
                                            ::moni::send_write_img
                                        }
                                    } else {
                                        set loadimg [string first "load nos.img" $str 0]
                                        set loadfileok 0
                                    if {$loadimg > 0} {
                                        set loadfileok [string first "Loading file ok" $str $loadimg]
                                    }
                                        if {$loadfileok > 0} {
                                            set ::moni::M(ImageLoaded) 1
                                            ::moni::send_write_img
                                        }
                                    }
                                } elseif {$::moni::M(ImageLoaded) == 1} {
                                  #savelog "in handlestr ImageLoaded\n"
                                  if {$::moni::M(BoardTypeNum) == 0 || $::moni::M(BoardTypeNum) == 0 \
                                      || $::moni::M(BoardTypeNum) == 0} {
                                        if {$::moni::M(OverWrite) == 0} {
                                            set loadimg [string first "load nos.img" $str 0]
                                            set overwrite [string first "overwrite" $str [expr {$loadimg + 10}]]
                                            if {$overwrite > 0} {
                                                set ::moni::M(OverWrite) 1
                                                ::moni::send $::moni::Cfg(name) "y\r"
                                            }
                                        }
                                  } else {
                                        if {$::moni::M(OverWrite) == 0} {
                                            if {[string first "overwrite" $str 0] > 0} {
                                                set ::moni::M(OverWrite) 1
                                                ::moni::send $::moni::Cfg(name) "y\r"
                                            }
                                        }
                                    }
                                    if {$::moni::M(ImageWrited) == 0} {
                                        if {[string first "Write nos.img OK" $str 0] > 0} {
                                            set ::moni::M(ImageWrited) 1
                                            catch {.testInfoDlg.labf2.t fastinsert end "nos.img has been written!\n"}
                                            catch {.testInfoDlg.labf2.t yview 10000}        ;#ctext��ʾ��10000��
                                            #::moni::get_result
                                        }
                                    }
                                }
                            }
                        }
                    } elseif {$nos_img_index < 0} {
                        if {$::moni::M(ImageLoaded) == 0} {
                            set loadimg [string first "load nos.img" $str 0]
                            set loadfileok 0
                        if {$loadimg > 0} {
                            set loadfileok [string first "Loading file ok" $str $loadimg]
                        }
                            if {$loadfileok > 0} {
                                set ::moni::M(ImageLoaded) 1
                                ::moni::send_write_img
                            }
                        } elseif {$::moni::M(ImageLoaded) == 1} {
                            if {$::moni::M(OverWrite) == 0} {
                                if {[string first "overwrite" $str 0] > 0} {
                                    set ::moni::M(OverWrite) 1
                                    ::moni::send $::moni::Cfg(name) "y\r"
                                }
                            }
                            if {$::moni::M(ImageWrited) == 0} {
                                if {[string first "Write nos.img OK" $str 0] > 0} {
                                    set ::moni::M(ImageWrited) 1
                                    catch {.testInfoDlg.labf2.t fastinsert end "nos.img has been written!\n"}
                                    catch {.testInfoDlg.labf2.t yview 10000}        ;#ctext��ʾ��10000��
                                    #::moni::get_result
                                }
                            }
                        }
                    }
                    if {$::moni::M(VendorCfgWrited) == 0} {
                        if {$::moni::M(VendorCfgLoaded) == 0} {
                            set loadcfg [string first "load vendor.cfg" $str 0]
                            set loadfileok 0
                            if {$loadcfg > 0} {
                                set loadfileok [string first "Loading file ok" $str $loadcfg]
                            }
                                if {$loadfileok > 0} {
                                    set ::moni::M(VendorCfgLoaded) 1
                                    ::moni::send_write_vendor_cfg
                                }
                            } elseif {$::moni::M(VendorCfgLoaded) == 1} {
                              #savelog "in handlestr ImageLoaded\n"
                              #savelog "in handlestr OverWrite = $::moni::M(OverWrite)\n"
                                if {$::moni::M(OverWrite) == 0} {
                                    set loadcfg [string first "load vendor.cfg" $str 0]
                                    set overwrite [string first "overwrite" $str [expr {$loadcfg + 10}]]
                                    if {$overwrite > 0} {
                                      #savelog "in handlestr get OverWrite\n"
                                        set ::moni::M(OverWrite) 1
                                        ::moni::send $::moni::Cfg(name) "y\r"
                                        #savelog "in handlestr sent y\n"
                                    }
                                }
                                if {$::moni::M(VendorCfgWrited) == 0} {
                                    if {[string first "Write vendor.cfg OK" $str 0] > 0} {
                                        set ::moni::M(VendorCfgWrited) 1
                                        catch {.testInfoDlg.labf2.t fastinsert end "vendor.cfg has been written!\n"}
                                        catch {.testInfoDlg.labf2.t yview 10000}        ;#ctext��ʾ��10000��
                                        #::moni::get_result
                                    }
                                }
                          }
                      }
                }
            }
        }
        #��ÿһ���ַ��в���
        while {[string first $enter $str [expr {$::moni::M(symenter)+1}]] > 0} {

            set symenter0 $::moni::M(symenter)
            set ::moni::M(symenter) [string first $enter $str [expr {$symenter0+1}]]


            if {$::moni::M(symenter) > 0} {
                #set ::moni::M(symenter2) [string first $enter $str $::moni::M(symenter1)]
                set curlinestr [string range $str [expr {$symenter0+1}] [expr {$::moni::M(symenter)-1}]]
                #set beforebraket [string range $str [expr {$::moni::M(symenter1)-1}] [expr {$::moni::M(symenter1)-1}]]
                set fileerrstr [string first "Loading file error" $curlinestr 0]

                if {$fileerrstr >= 0} {
                    set ::moni::M(FileError) 1
                    #tk_messageBox -message "No such file."
                }

            } else {
                set ::moni::M(symenter) $symenter0
                break
            }
        }
    }

    while {[string first $braket $str $::moni::M(sym2)] > $::moni::M(sym1)} {

        set sym01 $::moni::M(sym1)
        set ::moni::M(sym1) [string first $braket $str $::moni::M(sym2)]
        #savelog sym1=$::moni::M(sym1),sym2=$::moni::M(sym2)

        if {[string first $enter $str $::moni::M(sym1)] > $::moni::M(sym2)} {
            set ::moni::M(sym2) [string first $enter $str $::moni::M(sym1)]
            set strtoprint [string range $str $::moni::M(sym1) $::moni::M(sym2)]
            set beforebraket [string range $str [expr {$::moni::M(sym1)-1}] [expr {$::moni::M(sym1)-1}]]
            set ok [string first "\[OK\]" $strtoprint 0]
            set err [string first "\[ERROR\]" $strtoprint 0]
            set ec0 [string last "{" $strtoprint $err]
            set ec1 [string last "}" $strtoprint $err]
            set moni::M(ERROR_CODE) [string range $strtoprint [expr {$ec0+1}] [expr {$ec1-1}]]
            #set linkdownstr [string first "link is down" $strtoprint 0]
            set linkdownstr [string first "Please check port" $strtoprint 0]


            if {$beforebraket == "\x0D" || $beforebraket == "\x0A" || $beforebraket == "\x09"} {      ;#ֻ��ʾ������Ϣ
                #catch {.testInfoDlg.labf2.t fastinsert end $strtoprint}  
                #catch {.testInfoDlg.labf2.t yview 10000}        ;#ctext��ʾ��10000��
                ::moni::fastinsertend "handle" $strtoprint   ;#yueql
               #tk_messageBox -message $strtoprint         ;#yueql test
            }
            if {$linkdownstr >= 0} {
                ::moni::linkcheck $strtoprint
            }
            if {$ok<0 && $err<0} {
                for {set i 1} {$i < 30} {incr i} {
                    set index(i) [string first \[$i\] $strtoprint 0]
                    if {$index(i) == 0} {
                        set ::moni::M(bigindex) $i
                    }
                }
            } else {
            
                set ::moni::M(tested) [expr {$::moni::M(tested)+1}]
                set len [string length $strtoprint]
                set strrange [string range $strtoprint 1 $len]
                set strtoprint $braket$::moni::M(bigindex)$strrange

                if {$::moni::M(BoardTypeNum) == 6 || $::moni::M(BoardTypeNum) == 9 \
                    || $::moni::M(BoardTypeNum) == 70 || $::moni::M(BoardTypeNum) == 73 \
                    || $::moni::M(BoardTypeNum) == 199 || $::moni::M(BoardTypeNum) == 200} {
                    if {$::moni::M(BpFirstTested) == 0} {
                        ::moni::savelog 1��$strtoprint
                    } elseif {$::moni::M(BpFirstTested) == 1} {
                        ::moni::savelog 2��$strtoprint
                    }
                } else {
                    ::moni::savelog $strtoprint
                }

                catch {.testInfoDlg.labf3.label2 configure -text $::moni::M(tested)}
                update

                if {$ok>0} {
                    set ::moni::M(passed) [expr {$::moni::M(passed)+1}]
                    catch {.testInfoDlg.labf3.label4 configure -text $::moni::M(passed)}
                } elseif {$err>0} {
                    if {$::moni::M(FirstError) == 1} {
                        #saveerrlog "��ʼʱ�䣺$::moni::M(Time)\n"
#                        ::moni::saveerrlog $::moni::M(TestType)
                        set ::moni::M(FirstError) 0
                    }
                    set ::moni::M(failed) [expr {$::moni::M(failed)+1}]
                    catch {.testInfoDlg.labf3.label6 configure -text $::moni::M(failed)}
                    set ::moni::M(ErrorFound) 1

                    if {$::moni::M(BoardTypeNum) == 6 || $::moni::M(BoardTypeNum) == 9 \
                    || $::moni::M(BoardTypeNum) == 70 || $::moni::M(BoardTypeNum) == 73 \
                    || $::moni::M(BoardTypeNum) == 199 || $::moni::M(BoardTypeNum) == 200} {
                        if {$::moni::M(BpFirstTested) == 0} {
                            ::moni::saveerrlog 1��$strtoprint
                        } elseif {$::moni::M(BpFirstTested) == 1} {
                            ::moni::saveerrlog 2��$strtoprint
                        }
                    } else {
                        ::moni::saveerrlog $strtoprint
                    }

                    set bp_type [string first "Chassis type is" $strtoprint 0]
                    if {$bp_type>0} {
                        ::moni::bpTypeErrorExitDlg
                    }
                    if {$::moni::M(Manufactory) == "01"} {
                        set ::moni::M(HandleString) 0
                        moni::get_result
                    }
                }
            }
        } else {
            set ::moni::M(sym1) $sym01
            break
        }
    }
    set ::moni::M(GetSuccess) [string first "SUCCESS" $str 0]
    set ::moni::M(GetFail) [string first "FAILED" $str 0]

    if {$::moni::M(autoTestFinished) == 0} {
        if {$::moni::M(GetSuccess)>0 } {
            if {$::moni::M(BoardTypeNum) == 6 || $::moni::M(BoardTypeNum) == 9 \
                || $::moni::M(BoardTypeNum) == 70 || $::moni::M(BoardTypeNum) == 73 \
                || $::moni::M(BoardTypeNum) == 199 || $::moni::M(BoardTypeNum) == 200} {
                if {$::moni::M(BpFirstTested) == 0} {
                    catch {::moni::bpFirstTestPassed}
                } elseif {$::moni::M(BpFirstTested) == 1} {
                    set ::moni::M(autoTestFinished) 1
                    catch {::moni::bpSecondTestPassed}
                }
             } else {
                set ::moni::M(autoTestFinished) 1
                if {$::moni::M(BoardTypeNum) == 5 || $::moni::M(BoardTypeNum) == 69} {
                    catch {::moni::test_end}
                } else {
                    catch {::moni::testPassed}
                }
             }
        } elseif {$::moni::M(GetFail)>0 } {
            if {$::moni::M(BoardTypeNum) == 6 || $::moni::M(BoardTypeNum) == 9 \
                || $::moni::M(BoardTypeNum) == 70 || $::moni::M(BoardTypeNum) == 73 \
                || $::moni::M(BoardTypeNum) == 199 || $::moni::M(BoardTypeNum) == 200} {
                if {$::moni::M(BpFirstTested) == 0} {
                    catch {::moni::bpFirstTestFailed}
                } elseif {$::moni::M(BpFirstTested) == 1} {
                    set ::moni::M(autoTestFinished) 1
                    catch {::moni::bpSecondTestFailed}
                }
             } else {
                set ::moni::M(autoTestFinished) 1
                if {$::moni::M(BoardTypeNum) == 5 || $::moni::M(BoardTypeNum) == 69} {
                    catch {::moni::test_end}
                } else {
                    catch {::moni::testFailed}
                }
             }
        }
    }
}

proc moni::bpTypeErrorExitDlg {} {
    catch { destroy .testInfoDlg }
    toplevel .errorExitDlg

    wm withdraw .errorExitDlg

    update
    BWidget::place .errorExitDlg 400 160 at 300 100

    wm transient .errorExitDlg .
    wm title     .errorExitDlg "$moni::MSG(bpTypeErrorExitDlg_title)"
    wm deiconify .errorExitDlg
    wm resizable .errorExitDlg 0 0

    set win .errorExitDlg
    set f [frame $win.cfg]
    pack $f -side top

    Label $win.label -text "$moni::MSG(bpTypeErrorExitDlg_lab)" \
        -font { ���� 15 bold } -bg ForestGreen -fg white \
        -width 50 -anchor w -justify left -relief sunken -wraplength 280

    place $win.label \
        -in $win -x 50 -y 20 -width 300 -height 80 -anchor nw \
        -bordermode ignore

    pack $f -side top

    button $win.but -text "$moni::MSG(confirm_but_text)" -font { ���� 14 bold } -width 10 \
        -command {moni::bpTypeErrorExit} -fg brown -state normal \
        -highlightthickness 0 -takefocus 0 -borderwidth 2

    place $win.but \
        -in $win -x 160 -y 120 -anchor nw -bordermode ignore

    grab .errorExitDlg
    focus -force .errorExitDlg
}

proc moni::bpTypeErrorExit {} {
    catch {destroy .errorExitDlg}
    ::moni::get_result
}

proc moni::saveall {str} {
    set filename $::moni::M(SN).all.txt
    file mkdir ./log
    set f [open ./log/$filename "a+"]
    puts $f $str
    close $f
}

proc moni::savelog {str} {
	if {$::moni::M(TestType) == "Ԥ����"} {
		set filename $::moni::M(ATEMSN).txt
	} else {
		set filename $::moni::M(SN).txt
	}
    file mkdir ./log
    set f [open ./log/$filename "a+"]
    puts $f $str
    close $f
}

proc moni::saveerrlog {str} {
    set filename $::moni::M(SN).err.txt
    file mkdir ./log
    set f [open ./log/$filename "a+"]
    puts $f $str
    close $f
}

proc moni::linkcheckup {} {
    catch {destroy .butCommonDlg}

    ::moni::wait 3000
    ::moni::send $::moni::Cfg(name) "y\n"

    #moni::get_result
}

proc moni::linkcheckdown {str} {
    catch {destroy .butCommonDlg}
    set ::moni::M(ErrorFound) 1
    set ::moni::M(ERROR_CODE) "T453"
    moni::saveerrlog "$str\n"
    moni::savelog "$str\n"

    moni::addtesterr

    moni::get_result
}

proc moni::linkcheck {str} {
    variable M
    variable Cfg
    update

    set ::moni::M(LinkErrStr) $str

    set M(TestItem) "linkcheck"
    ::moni::butComDlgCreate $moni::MSG(linkcheck_title) $moni::MSG(linkcheck_lab)

}
proc moni::confirmfailedDlg {} {
    catch {destroy .testFailedDlg}
}

proc moni::testPassed {} {

    #labelframe .testInfoDlg.labf4 \
    #    -text "$moni::MSG(autotest_text)" -font { ���� 12 normal }
    #place .testInfoDlg.labf4 \
    #    -in .testInfoDlg -x [expr {[winfo screenwidth .]*1.95/3}] -y 450 -width [expr {[winfo screenwidth .]/4}] -height 160 -anchor nw \
    #    -bordermode ignore

    #set label11 [Label .testInfoDlg.labf4.label1 -image [bitmap OK] ]
    ##set label12 [Label .testInfoDlg.labf4.label2 -text "AutoTest PASSED!" -anchor w \
    ##    -font { ���� 15 normal } -fg blue ]

    #place $label11 \
    #    -in .testInfoDlg.labf4 -x 130 -y 35 -width 80 -height 80 -anchor nw \
    #    -bordermode ignore
    ##place $label12 \
    ##    -in .testInfoDlg.labf4 -x [expr {[winfo screenwidth .]*1/2}] -y 40 -width 170 -height 20 -anchor nw \
    ##    -bordermode ignore

    if {$::moni::M(BoardTypeNum) == 1 || $::moni::M(BoardTypeNum) == 2 \
        || $::moni::M(BoardTypeNum) == 17 || $::moni::M(BoardTypeNum) == 18 \
        || $::moni::M(BoardTypeNum) == 65 || $::moni::M(BoardTypeNum) == 66 \
        || $::moni::M(BoardTypeNum) == 81 || $::moni::M(BoardTypeNum) == 82} {
        button .testInfoDlg.but -pady 0 \
            -text "$moni::MSG(continue_but_text)" -font { ���� 14 bold } -width 30 \
            -command {moni::ledPortOnTest} \
            -highlightthickness 0 -takefocus 0 -borderwidth 2
    } elseif {$::moni::M(BoardTypeNum) == 3 || $::moni::M(BoardTypeNum) == 4 \
                || $::moni::M(BoardTypeNum) == 67 || $::moni::M(BoardTypeNum) == 68 } {
        button .testInfoDlg.but -pady 0 \
            -text "$moni::MSG(continue_but_text)" -font { ���� 14 bold } -width 30 \
            -command {moni::ledRunRedTest} \
            -highlightthickness 0 -takefocus 0 -borderwidth 2
    } elseif {$::moni::M(BoardTypeNum) == 5 || $::moni::M(BoardTypeNum) == 69} {
        button .testInfoDlg.but -pady 0 \
            -text "$moni::MSG(continue_but_text)" -font { ���� 14 bold } -width 30 \
            -command {moni::test_end} \
            -highlightthickness 0 -takefocus 0 -borderwidth 2
    } elseif {$::moni::M(BoardTypeNum) == 6 || $::moni::M(BoardTypeNum) == 9 \
          || $::moni::M(BoardTypeNum) == 70 || $::moni::M(BoardTypeNum) == 73 \
          || $::moni::M(BoardTypeNum) == 199 || $::moni::M(BoardTypeNum) == 200} {
        button .testInfoDlg.but -pady 0 \
            -text "$moni::MSG(continue_but_text)" -font { ���� 14 bold } -width 30 \
            -command {moni::test_end} \
            -highlightthickness 0 -takefocus 0 -borderwidth 2
    } elseif {$::moni::M(BoardTypeNum) == 128} {
        button .testInfoDlg.but -pady 0 \
            -text "$moni::MSG(continue_but_text)" -font { ���� 14 bold } -width 30 \
            -command {::moni::ledAllRedTest} \
            -highlightthickness 0 -takefocus 0 -borderwidth 2
    } elseif {$::moni::M(BoardTypeNum) == 129} {         	
    	if {$::moni::M(IsChassis) == 1} {
            button .testInfoDlg.but -pady 0 \
                -text "$moni::MSG(continue_but_text)" -font { ���� 14 bold } -width 30 \
                -command {::moni::ledAllRedTest} \
                -highlightthickness 0 -takefocus 0 -borderwidth 2    	
    	} else {
            button .testInfoDlg.but -pady 0 \
                -text "$moni::MSG(continue_but_text)" -font { ���� 14 bold } -width 30 \
                -command {::moni::ledPortOnTest} \
                -highlightthickness 0 -takefocus 0 -borderwidth 2     	
    	}            
    } elseif {$::moni::M(BoardTypeNum) == 131 \
        || $::moni::M(BoardTypeNum) == 132 || $::moni::M(BoardTypeNum) == 134\
        || $::moni::M(BoardTypeNum) == 136 || $::moni::M(BoardTypeNum) == 137\
        || $::moni::M(BoardTypeNum) == 138} {
        button .testInfoDlg.but -pady 0 \
            -text "$moni::MSG(continue_but_text)" -font { ���� 14 bold } -width 30 \
            -command {::moni::ledPortOnTest} \
            -highlightthickness 0 -takefocus 0 -borderwidth 2   	
    } elseif { $::moni::M(BoardTypeNum) == 170 || $::moni::M(BoardTypeNum) == 171 } {
        button .testInfoDlg.but -pady 0 \
            -text "$moni::MSG(continue_but_text)" -font { ���� 14 bold } -width 30 \
            -command {::moni::ledPortOnTest} \
            -highlightthickness 0 -takefocus 0 -borderwidth 2   
    } elseif { $::moni::M(BoardTypeNum) == 145} {
        button .testInfoDlg.but -pady 0 \
            -text "$moni::MSG(continue_but_text)" -font { ���� 14 bold } -width 30 \
            -command {::moni::ledAllOrangeTest} \
            -highlightthickness 0 -takefocus 0 -borderwidth 2 
	} else {
	    button .testInfoDlg.but -pady 0 \
            -text "$moni::MSG(continue_but_text)" -font { ���� 14 bold } -width 30 \
            -command {::moni::ledPortOnTest} \
            -highlightthickness 0 -takefocus 0 -borderwidth 2
    }

    place .testInfoDlg.but \
        -in .testInfoDlg -x 500 -y 20 -anchor nw -bordermode ignore
}

proc moni::testFailed {} {

    #labelframe .testInfoDlg.labf4 \
    #    -text "$moni::MSG(autotest_text)" -font { ���� 12 normal } 
    #place .testInfoDlg.labf4 \
    #    -in .testInfoDlg -x [expr {[winfo screenwidth .]*1.95/3}] -y 450 -width [expr {[winfo screenwidth .]/4}] -height 160 -anchor nw \
    #    -bordermode ignore

    #set label11 [Label .testInfoDlg.labf4.label2 -image [bitmap ERROR] ]
    #set label12 [Label .testInfoDlg.labf4.label1 -text "AutoTest FAILED! ERROR total:$::moni::M(failed)" -anchor w \
    #    -font { ���� 20 normal } -fg red ]

    #place $label11 \
    #    -in .testInfoDlg.labf4 -x 130 -y 35 -width 80 -height 80 -anchor nw \
    #    -bordermode ignore
    ##place $label12 \
    ##    -in .testInfoDlg.labf4 -x 300 -y 50 -width 700 -height 30 -anchor nw \
    ##    -bordermode ignore
    toplevel .testFailedDlg
    wm withdraw .testFailedDlg
    update
    BWidget::place .testFailedDlg 500 300 center

    wm transient .testFailedDlg .
    wm title     .testFailedDlg "$moni::MSG(testFailed_title)"
    wm deiconify .testFailedDlg
    wm resizable .testFailedDlg 0 0

	  set win .testFailedDlg
    set f [frame $win.cfg]
    pack $f -side top

    Label $win.label1 -text "$moni::MSG(testFailed_text)" \
	    -font { ���� 15 bold } -bg ForestGreen -fg white \
        -width 50 -anchor w	-justify left -relief sunken -wraplength 440

    place $win.label1 \
        -in $win -x 30 -y 30 -width 440 -height 80 -anchor nw \
        -bordermode ignore

    set label2 [Label $win.label2 -image [bitmap ERROR] ]
    set label3 [Label $win.label3 -text "ERROR!" -anchor w \
        -font { ���� 20 normal } -fg red ]

    place $label2 \
        -in $win -x 180 -y 150 -width 80 -height 80 -anchor nw \
        -bordermode ignore
    place $label3 \
        -in $win -x 280 -y 180 -width 250 -height 30 -anchor nw \
        -bordermode ignore

    pack $f -side top


    button $win.but1 -text "$moni::MSG(retest_but_text)" -font { ���� 14 bold } -width 10 \
        -command {::moni::next_test} -fg brown \
        -highlightthickness 0 -takefocus 0 -borderwidth 2
    button $win.but2 -text "$moni::MSG(close_but_text)" -font { ���� 14 bold } -width 10 \
        -command {::moni::finish_test_no_new_test} -fg brown \
        -highlightthickness 0 -takefocus 0 -borderwidth 2

    place $win.but1 \
        -in $win -x 100 -y 250 -anchor nw -bordermode ignore
    place $win.but2 \
        -in $win -x 300 -y 250 -anchor nw -bordermode ignore

    grab .testFailedDlg
    focus -force .testFailedDlg
    
    #��autotest����ֱ�ӷ��ز�����һ�������ٽ��н�������
    if {0} {

    button .testInfoDlg.but1 -pady 0 \
        -text "$moni::MSG(checklog_but_text)" -font { ���� 14 bold } -width 20 \
        -command {::moni::readLog} \
        -highlightthickness 0 -takefocus 0 -borderwidth 2

    if {$::moni::M(BoardTypeNum) == 1 || $::moni::M(BoardTypeNum) == 2 \
        || $::moni::M(BoardTypeNum) == 17 || $::moni::M(BoardTypeNum) == 18 \
        || $::moni::M(BoardTypeNum) == 65 || $::moni::M(BoardTypeNum) == 66 \
        || $::moni::M(BoardTypeNum) == 81 || $::moni::M(BoardTypeNum) == 82} {
        button .testInfoDlg.but2 -pady 0 \
            -text "$moni::MSG(continue_but_text)" -font { ���� 14 bold } -width 30 \
            -command {moni::ledPortOnTest} \
            -highlightthickness 0 -takefocus 0 -borderwidth 2
    } elseif {$::moni::M(BoardTypeNum) == 3 || $::moni::M(BoardTypeNum) == 4 \
                || $::moni::M(BoardTypeNum) == 67 || $::moni::M(BoardTypeNum) == 68} {
        button .testInfoDlg.but2 -pady 0 \
            -text "$moni::MSG(continue_but_text)" -font { ���� 14 bold } -width 30 \
            -command {moni::ledRunRedTest} \
            -highlightthickness 0 -takefocus 0 -borderwidth 2
    } elseif {$::moni::M(BoardTypeNum) == 5 || $::moni::M(BoardTypeNum) == 69} {
        button .testInfoDlg.but2 -pady 0 \
            -text "$moni::MSG(continue_but_text)" -font { ���� 14 bold } -width 30 \
            -command {moni::test_end} \
            -highlightthickness 0 -takefocus 0 -borderwidth 2
    } elseif {$::moni::M(BoardTypeNum) == 6 || $::moni::M(BoardTypeNum) == 9 \
          || $::moni::M(BoardTypeNum) == 70 || $::moni::M(BoardTypeNum) == 73 \
          || $::moni::M(BoardTypeNum) == 199 || $::moni::M(BoardTypeNum) == 200} {
        button .testInfoDlg.but2 -pady 0 \
            -text "$moni::MSG(continue_but_text)" -font { ���� 14 bold } -width 30 \
            -command {moni::test_end} \
            -highlightthickness 0 -takefocus 0 -borderwidth 2
    } elseif {$::moni::M(BoardTypeNum) == 128} {
        button .testInfoDlg.but2 -pady 0 \
            -text "$moni::MSG(continue_but_text)" -font { ���� 14 bold } -width 30 \
            -command {::moni::ledAllRedTest} \
            -highlightthickness 0 -takefocus 0 -borderwidth 2
    } elseif {$::moni::M(BoardTypeNum) == 129} {         	
    	if {$::moni::M(IsChassis) == 1} {
            button .testInfoDlg.but2 -pady 0 \
                -text "$moni::MSG(continue_but_text)" -font { ���� 14 bold } -width 30 \
                -command {::moni::ledAllRedTest} \
                -highlightthickness 0 -takefocus 0 -borderwidth 2    	
    	} else {
            button .testInfoDlg.but2 -pady 0 \
                -text "$moni::MSG(continue_but_text)" -font { ���� 14 bold } -width 30 \
                -command {::moni::ledPortOnTest} \
                -highlightthickness 0 -takefocus 0 -borderwidth 2     	
    	}
    } elseif {$::moni::M(BoardTypeNum) == 131 \
        || $::moni::M(BoardTypeNum) == 132 || $::moni::M(BoardTypeNum) == 134\
        || $::moni::M(BoardTypeNum) == 136 || $::moni::M(BoardTypeNum) == 137\
        || $::moni::M(BoardTypeNum) == 138} {
        button .testInfoDlg.but2 -pady 0 \
            -text "$moni::MSG(continue_but_text)" -font { ���� 14 bold } -width 30 \
            -command {::moni::ledPortOnTest} \
            -highlightthickness 0 -takefocus 0 -borderwidth 2     
    } else {
        button .testInfoDlg.but2 -pady 0 \
            -text "$moni::MSG(continue_but_text)" -font { ���� 14 bold } -width 30 \
            -command {::moni::ledPortOnTest} \
            -highlightthickness 0 -takefocus 0 -borderwidth 2
    }

    place .testInfoDlg.but1 \
        -in .testInfoDlg -x 300 -y 20 -anchor nw -bordermode ignore
    place .testInfoDlg.but2 \
        -in .testInfoDlg -x 600 -y 20 -anchor nw -bordermode ignore
    }

    set ::moni::M(ErrorFound) 1

    ::moni::sendlogfile
}
#/* BEGIN: Modified by jianghtc, 2010/01/26 ����[40676] */
proc moni::bpFirstTestPassed {} {
    #tk_messageBox -message "1���Զ�����ͨ��"

    #labelframe .testInfoDlg.labf4 \
    #    -text "$moni::MSG(autotest_text)" -font { ���� 12 normal }
    #place .testInfoDlg.labf4 \
    #    -in .testInfoDlg -x [expr {[winfo screenwidth .]*1.95/3}] -y 450 -width [expr {[winfo screenwidth .]/4}] -height 160 -anchor nw \
    #    -bordermode ignore

    #set label11 [Label .testInfoDlg.labf4.label1 -image [bitmap OK] ]
    #set label12 [Label .testInfoDlg.labf4.label2 -text "$moni::MSG(bpFirstTestPassed_text)" -anchor w \
    #    -font { ���� 15 normal } -fg blue ]

    #place $label11 \
    #    -in .testInfoDlg.labf4 -x 130 -y 35 -width 80 -height 80 -anchor nw \
    #    -bordermode ignore
    #place $label12 \
    #    -in .testInfoDlg.labf4 -x 50 -y 110 -width 250 -height 20 -anchor nw \
    #    -bordermode ignore

    button .testInfoDlg.but -pady 0 \
        -text "$moni::MSG(continue_but_text)" -font { ���� 12 normal } -width 30 \
        -command {moni::differ98and7608} \
        -highlightthickness 0 -takefocus 0 -borderwidth 2

    place .testInfoDlg.but \
        -in .testInfoDlg -x 500 -y 20 -anchor nw -bordermode ignore

}

proc moni::bpFirstTestFailed {} {
    #tk_messageBox -message "1���Զ�����δͨ��"

    #labelframe .testInfoDlg.labf4 \
    #    -text "$moni::MSG(autotest_text)" -font { ���� 12 normal } -fg blue
    #place .testInfoDlg.labf4 \
    #    -in .testInfoDlg -x [expr {[winfo screenwidth .]*1.95/3}] -y 450 -width [expr {[winfo screenwidth .]/4}] -height 160 -anchor nw \
    #    -bordermode ignore

    #set label11 [Label .testInfoDlg.labf4.label1 -image [bitmap ERROR] ]
    #set label12 [Label .testInfoDlg.labf4.label2 -text "$moni::MSG(bpFirstTestFailed_text)" -anchor w \
    #    -font { ���� 15 normal } -fg blue ]

    #place $label11 \
    #    -in .testInfoDlg.labf4 -x 130 -y 35 -width 80 -height 80 -anchor nw \
    #    -bordermode ignore
    #place $label12 \
    #    -in .testInfoDlg.labf4 -x 50 -y 110 -width 250 -height 20 -anchor nw \
    #    -bordermode ignore

    button .testInfoDlg.but1 -pady 0 \
        -text "$moni::MSG(checklog_but_text)" -font { ���� 14 bold } -width 20 \
        -command {::moni::readLog} \
        -highlightthickness 0 -takefocus 0 -borderwidth 2

    button .testInfoDlg.but2 -pady 0 \
        -text "$moni::MSG(continue_but_text)" -font { ���� 14 bold } -width 30 \
        -command {moni::differ98and7608} \
        -highlightthickness 0 -takefocus 0 -borderwidth 2

#    place .testInfoDlg.but \
#        -in .testInfoDlg -x [expr {[winfo screenwidth .]*2.2/5}] -y 20 -anchor nw -bordermode ignore

    place .testInfoDlg.but1 \
        -in .testInfoDlg -x 300 -y 20 -anchor nw -bordermode ignore
    place .testInfoDlg.but2 \
        -in .testInfoDlg -x 500 -y 20 -anchor nw -bordermode ignore

    set ::moni::M(ErrorFound) 1
}
#/* END:   Modified by jianghtc, 2010/01/26 ����[40676] */

#/* BEGIN: Added by jianghtc, 2010/01/26 ����[40676] */
proc moni::differ98and7608 {} {
    if {$::moni::M(BoardTypeNum) == 9 || $::moni::M(BoardTypeNum) == 73} {
        moni::bpSecondTest
    } else {
        moni::power1Test
    }
}
#/* END:   Added by jianghtc, 2010/01/26 ����[40676] */

#ÿ����λ�Զ��������֮����Ҫ�����Դ�Ľ�������
proc moni::power1Test {} {
    #catch {destroy .testInfoDlg.labf4}
    
    variable M
    set M(TestItem) "power1Test"
    ::moni::butComDlgCreate [string replace $moni::MSG(powerTest_title) 5 7 "SYS-PS1"]\
    [string replace $moni::MSG(powerTest_text1) 14 16 "SYS-PS1"]
}

proc moni::power2Test {} {
    variable M
    set M(TestItem) "power2Test"
    ::moni::butComDlgCreate [string replace $moni::MSG(powerTest_title) 5 7 "SYS-PS2"]\
    [string replace $moni::MSG(powerTest_text2) 11 13 "SYS-PS2"]

}

proc moni::power3Test {} {
    variable M
    set M(TestItem) "power3Test"
    ::moni::butComDlgCreate [string replace $moni::MSG(powerTest_title) 5 7 "SYS-PS3"]\
    [string replace $moni::MSG(powerTest_text2) 11 13 "SYS-PS3"]
}

proc moni::power4Test {} {
    variable M
    set M(TestItem) "power4Test"

    if {$::moni::M(BoardTypeNum) == 200} {
        ::moni::butComDlgCreate [string replace $moni::MSG(powerTest_title) 5 7 "SYS-PS4"]\
            [string replace $moni::MSG(powerTest_text2) 11 13 "SYS-PS4"]
    } elseif {$::moni::M(BoardTypeNum) == 199} {
        ::moni::butComDlgCreate [string replace $moni::MSG(powerTest_title) 5 7 "POE-PS1"]\
            [string replace $moni::MSG(powerTest_text2) 11 13 "POE-PS1"]
    }
}

proc moni::power5Test {} {
    variable M
    set M(TestItem) "power5Test"

    if {$::moni::M(BoardTypeNum) == 200} {
        ::moni::butComDlgCreate [string replace $moni::MSG(powerTest_title) 5 7 "POE-PS1"]\
            [string replace $moni::MSG(powerTest_text2) 11 13 "POE-PS1"]
    } elseif {$::moni::M(BoardTypeNum) == 199} {
        ::moni::butComDlgCreate [string replace $moni::MSG(powerTest_title) 5 7 "POE-PS2"]\
            [string replace $moni::MSG(powerTest_text2) 11 13 "POE-PS2"]
    }
}

proc moni::power6Test {} {
    catch {destroy .butCommonDlg}

    toplevel .power6TestDlg

    wm withdraw .power6TestDlg
    update
    BWidget::place .power6TestDlg 500 160 center

    if {$::moni::M(BoardTypeNum) == 200} {
        wm transient .power6TestDlg .
        wm title     .power6TestDlg [string replace $moni::MSG(powerTest_title) 5 7 "POE-PS2"]
        wm deiconify .power6TestDlg
        wm resizable .power6TestDlg 0 0
    } elseif {$::moni::M(BoardTypeNum) == 199} {
        wm transient .power6TestDlg .
        wm title     .power6TestDlg [string replace $moni::MSG(powerTest_title) 5 7 "POE-PS3"]
        wm deiconify .power6TestDlg
        wm resizable .power6TestDlg 0 0
    }

    set win .power6TestDlg
    set f [frame $win.cfg]
    pack $f -side top

    if {$::moni::M(BoardTypeNum) == 200} {
        Label $win.label -text [string replace $moni::MSG(powerTest_text2) 11 13 "POE-PS2"] \
            -font { ���� 15 bold } -bg ForestGreen -fg white \
            -width 20 -anchor w -justify left -relief sunken -wraplength 460
    } elseif {$::moni::M(BoardTypeNum) == 199} {
        Label $win.label -text [string replace $moni::MSG(powerTest_text2) 11 13 "POE-PS3"] \
            -font { ���� 15 bold } -bg ForestGreen -fg white \
            -width 20 -anchor w -justify left -relief sunken -wraplength 460
    }

    place $win.label \
        -in $win -x 20 -y 20 -width 460 -height 80 -anchor nw \
        -bordermode ignore

    pack $f -side top

    button $win.but1 -text "$moni::MSG(confirm_but_text)" -font { ���� 14 bold } -width 10 \
        -command {::moni::sendPower6Test} -fg brown \
        -highlightthickness 0 -takefocus 0 -borderwidth 2

    if { $::moni::M(BoardTypeNum) == 199 } {
        if {$::moni::M(BpFirstTested) == 1} {
		    button $win.but2 -text "$moni::MSG(close_but_text)" -font { ���� 14 bold } -width 10 \
		        -command {moni::test_end} -fg brown -state disabled \
		        -highlightthickness 0 -takefocus 0 -borderwidth 2
        } else {
	        button $win.but2 -text "$moni::MSG(continue_but_text)" -font { ���� 12 bold } -width 10 \
			    -command {::moni::bpSecondTest} -fg brown -state disabled \
			    -highlightthickness 0 -takefocus 0 -borderwidth 2
		}
	} else {
        button $win.but2 -text "$moni::MSG(continue_but_text)" -font { ���� 14 bold } -width 10 \
            -command {::moni::power7Test} -fg brown -state disabled \
            -highlightthickness 0 -takefocus 0 -borderwidth 2
    }

    place $win.but1 \
        -in $win -x 80 -y 120 -anchor nw -bordermode ignore
    place $win.but2 \
        -in $win -x 300 -y 120 -anchor nw -bordermode ignore

    grab .power6TestDlg
    focus -force .power6TestDlg
}

proc moni::power7Test {} {
    catch {destroy .power6TestDlg}
    set M(TestItem) "power7Test"
    ::moni::butComDlgCreate [string replace $moni::MSG(powerTest_title) 5 7 "POE-PS3"]\
    [string replace $moni::MSG(powerTest_text2) 11 13 "POE-PS3"]
}

proc moni::power8Test {} {
    catch {destroy .butCommonDlg}

    toplevel .power8TestDlg

    wm withdraw .power8TestDlg
    update
    BWidget::place .power8TestDlg 500 160 center

    wm transient .power8TestDlg .
    wm title     .power8TestDlg [string replace $moni::MSG(powerTest_title) 5 7 "POE-PS4"]
    wm deiconify .power8TestDlg
    wm resizable .power8TestDlg 0 0

    set win .power8TestDlg
    set f [frame $win.cfg]
    pack $f -side top

    Label $win.label -text [string replace $moni::MSG(powerTest_text2) 11 13 "POE-PS4"] \
        -font { ���� 15 bold } -bg ForestGreen -fg white \
        -width 20 -anchor w -justify left -relief sunken -wraplength 460

    place $win.label \
        -in $win -x 20 -y 20 -width 460 -height 80 -anchor nw \
        -bordermode ignore

    pack $f -side top

    button $win.but1 -text "$moni::MSG(confirm_but_text)" -font { ���� 14 bold } -width 10 \
        -command {::moni::sendPower8Test} -fg brown \
        -highlightthickness 0 -takefocus 0 -borderwidth 2

    if {$::moni::M(BpFirstTested) == 1} {
	    button $win.but2 -text "$moni::MSG(close_but_text)" -font { ���� 14 bold } -width 10 \
	        -command {moni::test_end} -fg brown -state disabled \
	        -highlightthickness 0 -takefocus 0 -borderwidth 2
    } else {
        button $win.but2 -text "$moni::MSG(continue_but_text)" -font { ���� 14 bold } -width 10 \
            -command {::moni::bpSecondTest} -fg brown -state disabled \
            -highlightthickness 0 -takefocus 0 -borderwidth 2
    }

    place $win.but1 \
        -in $win -x 80 -y 120 -anchor nw -bordermode ignore
    place $win.but2 \
        -in $win -x 300 -y 120 -anchor nw -bordermode ignore

    grab .power8TestDlg
    focus -force .power8TestDlg
}

proc moni::bpSecondTest {} {
    catch {destroy .power6TestDlg}
    catch {destroy .power8TestDlg}
    #catch {destroy .testInfoDlg.labf4}
    set ::moni::M(BpFirstTested) 1
    toplevel .changeSlotDlg

    wm withdraw .changeSlotDlg
    update
    BWidget::place .changeSlotDlg 400 120 at 300 100

    wm transient .changeSlotDlg .
    wm title     .changeSlotDlg "$moni::MSG(bpSecondTest_title)"
    wm deiconify .changeSlotDlg
    wm resizable .changeSlotDlg 0 0

    set win .changeSlotDlg
    set f [frame $win.cfg]
    pack $f -side top

    if {$::moni::M(BoardTypeNum) == 6 || $::moni::M(BoardTypeNum) == 70} {
        Label $win.label -text "$moni::MSG(bpSecondTest_text1)" \
            -font { ���� 12 normal } -bg ForestGreen -fg white \
            -width 50 -anchor w -justify left -relief sunken -wraplength 280
    } elseif {$::moni::M(BoardTypeNum) == 9 || $::moni::M(BoardTypeNum) == 73} {
        Label $win.label -text "$moni::MSG(bpSecondTest_text2)" \
            -font { ���� 12 normal } -bg ForestGreen -fg white \
            -width 50 -anchor w -justify left -relief sunken -wraplength 280
    } elseif {$::moni::M(BoardTypeNum) == 199 || $::moni::M(BoardTypeNum) == 200} {
        Label $win.label -text "$moni::MSG(bpSecondTest_text3)" \
            -font { ���� 12 normal } -bg ForestGreen -fg white \
            -width 50 -anchor w -justify left -relief sunken -wraplength 280
    }

    place $win.label \
        -in $win -x 50 -y 20 -width 300 -height 80 -anchor nw \
        -bordermode ignore

    pack $f -side top

    grab .changeSlotDlg
    focus -force .changeSlotDlg

    ::moni::reinit

    ::moni::wait_ram      ;#���"Testing RAM..."
    #/* BEGIN: Modified by jianghtc, 2010/01/26 ����[40676] */
    if {$::moni::M(GetRam) == 1} {
        if {$::moni::M(BoardTypeNum) == 199 || $::moni::M(BoardTypeNum) == 200
            ||$::moni::M(BoardTypeNum) == 9 || $::moni::M(BoardTypeNum) == 73} {
	        ::moni::send $::moni::Cfg(name) "\x14"  ;#Ctrl+T ����img����������
	        ::moni::wait 3000
	        ::moni::send $::moni::Cfg(name) "\x14"
	        ::moni::wait 3000
	        ::moni::send $::moni::Cfg(name) "\x14"
	        ::moni::wait 3000
	        ::moni::send $::moni::Cfg(name) "\x14"
	        set ::moni::M(GetMantest) 0
	        ::moni::wait_mantest   ;#���"[manTest]:"
      	} else {
	        set ::moni::M(GetRam) 0
	        ::moni::send $::moni::Cfg(name) "\x02"  ;#Ctrl+B ����boot.rom
	        ::moni::send $::moni::Cfg(name) "\x02"
	        ::moni::send $::moni::Cfg(name) "\x02"
	        ::moni::send $::moni::Cfg(name) "\x0A"
	        set ::moni::M(GetBoot) 0
	        ::moni::wait_boot     ;#���"[Boot]:"
      	}
    } else {
        return
    }

    if {$::moni::M(BoardTypeNum) == 199 || $::moni::M(BoardTypeNum) == 200
     ||$::moni::M(BoardTypeNum) == 9 || $::moni::M(BoardTypeNum) == 73} {
	    if {$::moni::M(GetMantest) == 1} {
	        set ::moni::M(GetMantest) 0
	        destroy .changeSlotDlg
	        ::moni::send_run_testimg
	        ::moni::wait_run
	    }
  	} else {
	    if {$::moni::M(GetBoot) == 1} {
	        destroy .changeSlotDlg
	        ::moni::send_run_testimg
	        ::moni::wait_run
	    }
  	}
  	#/* END:   Modified by jianghtc, 2010/01/26 ����[40676] */
}

proc moni::bpSecondTestPassed {} {
    #tk_messageBox -message "2���Զ�����ͨ��"
    #BEGIN: Added by jianghtc, 2010/02/24 bug[41297]
    if {$::moni::M(BoardTypeNum) == 9 || $::moni::M(BoardTypeNum) == 73} {
    	::moni::get_result
    }
    #END:   Added by jianghtc, 2010/02/24 bug[41297]

    #labelframe .testInfoDlg.labf4 \
    #    -text "$moni::MSG(autotest_text)" -font { ���� 12 normal }
    #place .testInfoDlg.labf4 \
    #    -in .testInfoDlg -x [expr {[winfo screenwidth .]*1.95/3}] -y 450 -width [expr {[winfo screenwidth .]/4}] -height 160 -anchor nw \
    #    -bordermode ignore

    #set label11 [Label .testInfoDlg.labf4.label1 -image [bitmap OK] ]
    #set label12 [Label .testInfoDlg.labf4.label2 -text "$moni::MSG(bpSecondTestPassed_text)" -anchor w \
    #    -font { ���� 15 normal } -fg blue ]

    #place $label11 \
    #    -in .testInfoDlg.labf4 -x 130 -y 35 -width 80 -height 80 -anchor nw \
    #    -bordermode ignore
    #place $label12 \
    #    -in .testInfoDlg.labf4 -x 50 -y 110 -width 250 -height 20 -anchor nw \
    #    -bordermode ignore

    catch {destroy .testInfoDlg.but}
    button .testInfoDlg.but -pady 0 \
        -text "$moni::MSG(continue_but_text)" -font { ���� 12 normal } -width 30 \
        -command {moni::power1Test} \
        -highlightthickness 0 -takefocus 0 -borderwidth 2

    place .testInfoDlg.but \
        -in .testInfoDlg -x 500 -y 20 -anchor nw -bordermode ignore
}

proc moni::bpSecondTestFailed {} {
    #tk_messageBox -message "2���Զ�����δͨ��"
    #BEGIN: Added by jianghtc, 2010/02/24 bug[41297]
    if {$::moni::M(BoardTypeNum) == 9 || $::moni::M(BoardTypeNum) == 73} {
    ::moni::get_result
    }
    #END:   Added by jianghtc, 2010/02/24 bug[41297]

    #labelframe .testInfoDlg.labf4 \
    #    -text "$moni::MSG(autotest_text)" -font { ���� 12 normal }
    #place .testInfoDlg.labf4 \
    #    -in .testInfoDlg -x [expr {[winfo screenwidth .]*1.95/3}] -y 450 -width [expr {[winfo screenwidth .]/4}] -height 160 -anchor nw \
    #    -bordermode ignore

    #set label11 [Label .testInfoDlg.labf4.label1 -image [bitmap ERROR] ]
    #set label12 [Label .testInfoDlg.labf4.label2 -text "$moni::MSG(bpSecondTestFailed_text)" -anchor w \
    #    -font { ���� 15 normal } -fg blue ]

    #place $label11 \
    #    -in .testInfoDlg.labf4 -x 130 -y 35 -width 80 -height 80 -anchor nw \
    #    -bordermode ignore
    #place $label12 \
    #    -in .testInfoDlg.labf4 -x 50 -y 110 -width 250 -height 20 -anchor nw \
    #    -bordermode ignore

    catch {destroy .testInfoDlg.but}

    button .testInfoDlg.but1 -pady 0 \
        -text "$moni::MSG(checklog_but_text)" -font { ���� 14 bold } -width 20 \
        -command {::moni::readLog} \
        -highlightthickness 0 -takefocus 0 -borderwidth 2

    button .testInfoDlg.but2 -pady 0 \
        -text "$moni::MSG(continue_but_text)" -font { ���� 14 bold } -width 30 \
        -command {moni::power1Test} \
        -highlightthickness 0 -takefocus 0 -borderwidth 2

#    place .testInfoDlg.but \
#        -in .testInfoDlg -x [expr {[winfo screenwidth .]*2.2/5}] -y 20 -anchor nw -bordermode ignore

    place .testInfoDlg.but1 \
        -in .testInfoDlg -x 300 -y 20 -anchor nw -bordermode ignore
    place .testInfoDlg.but2 \
        -in .testInfoDlg -x 500 -y 20 -anchor nw -bordermode ignore

    set ::moni::M(ErrorFound) 1
}

proc moni::readLog {} {
    toplevel .logFileDlg
    wm withdraw .logFileDlg
    update
    BWidget::place .logFileDlg 700 500 center

    wm transient .logFileDlg .
    wm title     .logFileDlg "$moni::MSG(readLog_title)"
    wm deiconify .logFileDlg
    wm resizable .logFileDlg 1 1

  pack [frame .logFileDlg.f] -fill both -expand 1
    pack [scrollbar .logFileDlg.f.s -command {.logFileDlg.f.t yview}] -side right -fill y
    pack [ctext .logFileDlg.f.t -bg white -fg brown -insertbackground blue  -yscrollcommand {.logFileDlg.f.s set}] -fill both -expand 1

    set file [open ./log/$::moni::M(SN).err.txt r]

    while {[gets $file line] >= 0} {
      .logFileDlg.f.t fastinsert end $line\x0A
    }
    close $file


    pack [frame .logFileDlg.f1] -fill x
    .logFileDlg.f.t highlight 1.0 end
    .logFileDlg.f.t yview 100       ;#��ʾ��100��

    grab .logFileDlg
    focus -force .logFileDlg
}

proc moni::addtestok {} {
    incr ::moni::M(tested)
    catch { .testInfoDlg.labf3.label2 configure -text $::moni::M(tested) }
    incr ::moni::M(passed)
    catch { .testInfoDlg.labf3.label4 configure -text $::moni::M(passed) }
    update
}

proc moni::addtesterr {} {
	set ::moni::M(ErrorFound) 1
    incr ::moni::M(tested)
    catch { .testInfoDlg.labf3.label2 configure -text $::moni::M(tested) }
    incr ::moni::M(failed)
    catch { .testInfoDlg.labf3.label6 configure -text $::moni::M(failed) }
    update
}

proc moni::ledAllRedTest {} {

    variable M
    #catch {destroy .testInfoDlg.labf4}

    if {$::moni::M(BoardTypeNum) == 29 || $::moni::M(BoardTypeNum) == 93 \
        || $::moni::M(BoardTypeNum) == 30 || $::moni::M(BoardTypeNum) == 94} {

    } else {
        #tk_messageBox -message "Click ��Confirm�� to begin LED test!\n"
    }


    set M(TestItem) "ledAllRedTest"
    ::moni::butComDlgCreate $moni::MSG(ledAllRedTest_dlg_title) $moni::MSG(ledAllRedTest_dlg_lab)
      
    ::moni::sendledAllRedTest

}


proc moni::sendPower1Test {} {
    variable M

    ::moni::reinit

    ::moni::send $::moni::Cfg(name) "backtest powerindextunnel 1\r"

    ::moni::wait 400

    .butCommonDlg.but1 configure -state disable

    ::moni::wait 2000

    ::moni::wait_power

    if {$::moni::M(GetPower1) == 1 || $::moni::M(GetPower2) == 1} {
        if {$::moni::M(GetPower1) == 1} {
            set ::moni::M(GetPower1) 0
            moni::addtesterr
            moni::saveerrlog "{T491}\[ERROR\][string replace $moni::MSG(sendPowerTest_log) 11 13 "SYS-PS1"]\n"
            moni::savelog "[string replace $moni::MSG(sendPowerTest_log) 11 13 "SYS-PS1"]\n"
            .testInfoDlg.labf2.t fastinsert end "\n[string replace $moni::MSG(sendPowerTest_log) 11 13 "SYS-PS1"]\n"
            .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��

            if {$::moni::M(Manufactory) == "01"} {
                set ::moni::M(HandleString) 0
                set ::moni::M(ERROR_CODE) "T491"
                ::moni::get_result
                return
            }
        }

        if { $::moni::M(GetPower2) == 1 } {
            set ::moni::M(GetPower2) 0

            moni::addtesterr
            moni::saveerrlog "{T491}\[ERROR\][string replace $moni::MSG(sendPowerTest_errlog) 14 16 "SYS-PS1"]\n"
            moni::savelog "{T491}\[ERROR\][string replace $moni::MSG(sendPowerTest_errlog) 14 16 "SYS-PS1"]\n"
            .testInfoDlg.labf2.t fastinsert end "\n[string replace $moni::MSG(sendPowerTest_errlog) 14 16 "SYS-PS1"]\n"
            .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��

            if {$::moni::M(Manufactory) == "01"} {
                set ::moni::M(HandleString) 0
                set ::moni::M(ERROR_CODE) "T491"
                ::moni::get_result
                return
            }
        }
    } else {
        set ::moni::M(GetPower1) 0
        set ::moni::M(GetPower2) 0
        ::moni::addtestok
        ::moni::savelog "[string replace $moni::MSG(sendPowerTest_oklog) 1 3 "SYS-PS1"]\n"
        .testInfoDlg.labf2.t fastinsert end "\n[string replace $moni::MSG(sendPowerTest_oklog) 1 3 "SYS-PS1"]\n"
        .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    }

    .butCommonDlg.but2 configure -state normal

    ::moni::send $::moni::Cfg(name) "\x0A"
}

proc moni::sendPower2Test {} {
    variable M

    ::moni::reinit

    ::moni::send $::moni::Cfg(name) "backtest powerindextunnel 2\r"

    ::moni::wait 400

    .butCommonDlg.but1 configure -state disable

    ::moni::wait 2000

    ::moni::wait_power

    if {$::moni::M(GetPower1) == 1 || $::moni::M(GetPower2) == 1} {
        if {$::moni::M(GetPower1) == 1} {
            set ::moni::M(GetPower1) 0
            moni::addtesterr
            moni::saveerrlog "{T491}\[ERROR\][string replace $moni::MSG(sendPowerTest_log) 11 13 "SYS-PS2"]\n"
            moni::savelog "[string replace $moni::MSG(sendPowerTest_log) 11 13 "SYS-PS2"]\n"
            .testInfoDlg.labf2.t fastinsert end "\n[string replace $moni::MSG(sendPowerTest_log) 11 13 "SYS-PS2"]\n"
            .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��

            if {$::moni::M(Manufactory) == "01"} {
                set ::moni::M(HandleString) 0
                set ::moni::M(ERROR_CODE) "T491"
                ::moni::get_result
                return
            }
        }

        if { $::moni::M(GetPower2) == 1 } {
            set ::moni::M(GetPower2) 0

            moni::addtesterr
            moni::saveerrlog "{T491}\[ERROR\][string replace $moni::MSG(sendPowerTest_errlog) 14 16 "SYS-PS2"]\n"
            moni::savelog "{T491}\[ERROR\][string replace $moni::MSG(sendPowerTest_errlog) 14 16 "SYS-PS2"]\n"
            .testInfoDlg.labf2.t fastinsert end "\n[string replace $moni::MSG(sendPowerTest_errlog) 14 16 "SYS-PS2"]\n"
            .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��

            if {$::moni::M(Manufactory) == "01"} {
                set ::moni::M(HandleString) 0
                set ::moni::M(ERROR_CODE) "T491"
                ::moni::get_result
                return
            }
        }
    } else {
        set ::moni::M(GetPower1) 0
        set ::moni::M(GetPower2) 0
        ::moni::addtestok
        ::moni::savelog "[string replace $moni::MSG(sendPowerTest_oklog) 1 3 "SYS-PS2"]\n"
        .testInfoDlg.labf2.t fastinsert end "\n[string replace $moni::MSG(sendPowerTest_oklog) 1 3 "SYS-PS2"]\n"
        .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    }

    .butCommonDlg.but2 configure -state normal

    ::moni::send $::moni::Cfg(name) "\x0A"
}

proc moni::sendPower3Test {} {
    variable M

    ::moni::reinit

    ::moni::send $::moni::Cfg(name) "backtest powerindextunnel 3\r"

    ::moni::wait 400

    .butCommonDlg.but1 configure -state disable

    ::moni::wait 2000

    ::moni::wait_power

    if {$::moni::M(GetPower1) == 1 || $::moni::M(GetPower2) == 1} {
        if {$::moni::M(GetPower1) == 1} {
            set ::moni::M(GetPower1) 0
            moni::addtesterr
            moni::saveerrlog "{T491}\[ERROR\][string replace $moni::MSG(sendPowerTest_log) 11 13 "SYS-PS3"]\n"
            moni::savelog "[string replace $moni::MSG(sendPowerTest_log) 11 13 "SYS-PS3"]\n"
            .testInfoDlg.labf2.t fastinsert end "\n[string replace $moni::MSG(sendPowerTest_log) 11 13 "SYS-PS3"]\n"
            .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��

            if {$::moni::M(Manufactory) == "01"} {
                set ::moni::M(HandleString) 0
                set ::moni::M(ERROR_CODE) "T491"
                ::moni::get_result
                return
            }
        }

        if { $::moni::M(GetPower2) == 1 } {
            set ::moni::M(GetPower2) 0

            moni::addtesterr
            moni::saveerrlog "{T491}\[ERROR\][string replace $moni::MSG(sendPowerTest_errlog) 14 16 "SYS-PS3"]\n"
            moni::savelog "{T491}\[ERROR\][string replace $moni::MSG(sendPowerTest_errlog) 14 16 "SYS-PS3"]\n"
            .testInfoDlg.labf2.t fastinsert end "\n[string replace $moni::MSG(sendPowerTest_errlog) 14 16 "SYS-PS3"]\n"
            .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��

            if {$::moni::M(Manufactory) == "01"} {
                set ::moni::M(HandleString) 0
                set ::moni::M(ERROR_CODE) "T491"
                ::moni::get_result
                return
            }
        }
    } else {
        set ::moni::M(GetPower1) 0
        set ::moni::M(GetPower2) 0
        ::moni::addtestok
        ::moni::savelog "[string replace $moni::MSG(sendPowerTest_oklog) 1 3 "SYS-PS3"]\n"
        .testInfoDlg.labf2.t fastinsert end "\n[string replace $moni::MSG(sendPowerTest_oklog) 1 3 "SYS-PS3"]\n"
        .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    }

    .butCommonDlg.but2 configure -state normal

    ::moni::send $::moni::Cfg(name) "\x0A"
}

proc moni::sendPower4Test {} {
    variable M

    ::moni::reinit

    ::moni::send $::moni::Cfg(name) "backtest powerindextunnel 4\r"

    ::moni::wait 400

    .butCommonDlg.but1 configure -state disable

    ::moni::wait 2000

    ::moni::wait_power

    if {$::moni::M(GetPower1) == 1 || $::moni::M(GetPower2) == 1} {
        if {$::moni::M(GetPower1) == 1} {
            set ::moni::M(GetPower1) 0
            moni::addtesterr

            if {$::moni::M(BoardTypeNum) == 200} {
                moni::saveerrlog "{T491}\[ERROR\][string replace $moni::MSG(sendPowerTest_log) 11 13 "SYS-PS4"]\n"
                moni::savelog "[string replace $moni::MSG(sendPowerTest_log) 11 13 "SYS-PS4"]\n"
                .testInfoDlg.labf2.t fastinsert end "\n[string replace $moni::MSG(sendPowerTest_log) 11 13 "SYS-PS4"]\n"
                .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
            } elseif {$::moni::M(BoardTypeNum) == 199} {
                moni::saveerrlog "{T491}\[ERROR\][string replace $moni::MSG(sendPowerTest_log) 11 13 "POE-PS1"]\n"
                moni::savelog "[string replace $moni::MSG(sendPowerTest_log) 11 13 "POE-PS1"]\n"
                .testInfoDlg.labf2.t fastinsert end "\n[string replace $moni::MSG(sendPowerTest_log) 11 13 "POE-PS1"]\n"
                .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
            }

	    	if {$::moni::M(Manufactory) == "01"} {
	    	    set ::moni::M(HandleString) 0
	    	    set ::moni::M(ERROR_CODE) "T491"
	    	    ::moni::get_result
	    	    return
	    	}
        }

        if { $::moni::M(GetPower2) == 1 } {
            set ::moni::M(GetPower2) 0

	    	moni::addtesterr

	    	if {$::moni::M(BoardTypeNum) == 200} {
	    	    moni::saveerrlog "{T491}\[ERROR\][string replace $moni::MSG(sendPowerTest_errlog) 14 16 "SYS-PS4"]\n"
	    	    moni::savelog "{T491}\[ERROR\][string replace $moni::MSG(sendPowerTest_errlog) 14 16 "SYS-PS4"]\n"
                .testInfoDlg.labf2.t fastinsert end "\n[string replace $moni::MSG(sendPowerTest_errlog) 14 16 "SYS-PS4"]\n"
                .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
            } elseif {$::moni::M(BoardTypeNum) == 199} {
	    	    moni::saveerrlog "{T491}\[ERROR\][string replace $moni::MSG(sendPowerTest_errlog) 14 16 "POE-PS1"]\n"
	    	    moni::savelog "{T491}\[ERROR\][string replace $moni::MSG(sendPowerTest_errlog) 14 16 "POE-PS1"]\n"
                .testInfoDlg.labf2.t fastinsert end "\n[string replace $moni::MSG(sendPowerTest_errlog) 14 16 "POE-PS1"]\n"
                .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
            }

	    	if {$::moni::M(Manufactory) == "01"} {
	    	    set ::moni::M(HandleString) 0
	    	    set ::moni::M(ERROR_CODE) "T491"
	    	    ::moni::get_result
	    	    return
	    	}
        }
    } else {
        set ::moni::M(GetPower1) 0
        set ::moni::M(GetPower2) 0
        ::moni::addtestok

        if {$::moni::M(BoardTypeNum) == 200} {
            ::moni::savelog "[string replace $moni::MSG(sendPowerTest_oklog) 1 3 "SYS-PS4"]\n"
            .testInfoDlg.labf2.t fastinsert end "\n[string replace $moni::MSG(sendPowerTest_oklog) 1 3 "SYS-PS4"]\n"
            .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
        } elseif {$::moni::M(BoardTypeNum) == 199} {
            ::moni::savelog "[string replace $moni::MSG(sendPowerTest_oklog) 1 3 "POE-PS1"]\n"
            .testInfoDlg.labf2.t fastinsert end "\n[string replace $moni::MSG(sendPowerTest_oklog) 1 3 "POE-PS1"]\n"
            .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
        }
    }

    .butCommonDlg.but2 configure -state normal

    ::moni::send $::moni::Cfg(name) "\x0A"
}

proc moni::sendPower5Test {} {
    variable M

    ::moni::reinit

    ::moni::send $::moni::Cfg(name) "backtest powerindextunnel 5\r"

    ::moni::wait 400

    .butCommonDlg.but1 configure -state disable

    ::moni::wait 2000

    ::moni::wait_power

    if {$::moni::M(GetPower1) == 1 || $::moni::M(GetPower2) == 1} {
        if {$::moni::M(GetPower1) == 1} {
            set ::moni::M(GetPower1) 0
            moni::addtesterr

            if {$::moni::M(BoardTypeNum) == 200} {
                moni::saveerrlog "{T491}\[ERROR\][string replace $moni::MSG(sendPowerTest_log) 11 13 "POE-PS1"]\n"
                moni::savelog "[string replace $moni::MSG(sendPowerTest_log) 11 13 "POE-PS1"]\n"
                .testInfoDlg.labf2.t fastinsert end "\n[string replace $moni::MSG(sendPowerTest_log) 11 13 "POE-PS1"]\n"
                .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
            } elseif {$::moni::M(BoardTypeNum) == 199} {
                moni::saveerrlog "{T491}\[ERROR\][string replace $moni::MSG(sendPowerTest_log) 11 13 "POE-PS2"]\n"
                moni::savelog "[string replace $moni::MSG(sendPowerTest_log) 11 13 "POE-PS2"]\n"
                .testInfoDlg.labf2.t fastinsert end "\n[string replace $moni::MSG(sendPowerTest_log) 11 13 "POE-PS2"]\n"
                .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
            }

            if {$::moni::M(Manufactory) == "01"} {
                set ::moni::M(HandleString) 0
                set ::moni::M(ERROR_CODE) "T491"
                ::moni::get_result
                return
            }
        }

        if { $::moni::M(GetPower2) == 1 } {
            set ::moni::M(GetPower2) 0

            moni::addtesterr

            if {$::moni::M(BoardTypeNum) == 200} {
                moni::saveerrlog "{T491}\[ERROR\][string replace $moni::MSG(sendPowerTest_errlog) 14 16 "POE-PS1"]\n"
                moni::savelog "{T491}\[ERROR\][string replace $moni::MSG(sendPowerTest_errlog) 14 16 "POE-PS1"]\n"
                .testInfoDlg.labf2.t fastinsert end "\n[string replace $moni::MSG(sendPowerTest_errlog) 14 16 "POE-PS1"]\n"
                .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
            } elseif {$::moni::M(BoardTypeNum) == 199} {
                moni::saveerrlog "{T491}\[ERROR\][string replace $moni::MSG(sendPowerTest_errlog) 14 16 "POE-PS2"]\n"
                moni::savelog "{T491}\[ERROR\][string replace $moni::MSG(sendPowerTest_errlog) 14 16 "POE-PS2"]\n"
                .testInfoDlg.labf2.t fastinsert end "\n[string replace $moni::MSG(sendPowerTest_errlog) 14 16 "POE-PS2"]\n"
                .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
            }

            if {$::moni::M(Manufactory) == "01"} {
                set ::moni::M(HandleString) 0
                set ::moni::M(ERROR_CODE) "T491"
                ::moni::get_result
                return
            }
        }
    } else {
        set ::moni::M(GetPower1) 0
        set ::moni::M(GetPower2) 0
        ::moni::addtestok

        if {$::moni::M(BoardTypeNum) == 200} {
            ::moni::savelog "[string replace $moni::MSG(sendPowerTest_oklog) 1 3 "POE-PS1"]\n"
            .testInfoDlg.labf2.t fastinsert end "\n[string replace $moni::MSG(sendPowerTest_oklog) 1 3 "POE-PS1"]\n"
            .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
        } elseif {$::moni::M(BoardTypeNum) == 199} {
            ::moni::savelog "[string replace $moni::MSG(sendPowerTest_oklog) 1 3 "POE-PS2"]\n"
            .testInfoDlg.labf2.t fastinsert end "\n[string replace $moni::MSG(sendPowerTest_oklog) 1 3 "POE-PS2"]\n"
            .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
        }
    }

    .butCommonDlg.but2 configure -state normal

    ::moni::send $::moni::Cfg(name) "\x0A"
}

proc moni::sendPower6Test {} {
    variable M

    ::moni::reinit

    ::moni::send $::moni::Cfg(name) "backtest powerindextunnel 6\r"

    ::moni::wait 400

    .power6TestDlg.but1 configure -state disable

    ::moni::wait 2000

    ::moni::wait_power

    if {$::moni::M(GetPower1) == 1 || $::moni::M(GetPower2) == 1} {
        if {$::moni::M(GetPower1) == 1} {
            set ::moni::M(GetPower1) 0
            moni::addtesterr

            if {$::moni::M(BoardTypeNum) == 200} {
                moni::saveerrlog "{T491}\[ERROR\][string replace $moni::MSG(sendPowerTest_log) 11 13 "POE-PS2"]\n"
                moni::savelog "[string replace $moni::MSG(sendPowerTest_log) 11 13 "POE-PS2"]\n"
                .testInfoDlg.labf2.t fastinsert end "\n[string replace $moni::MSG(sendPowerTest_log) 11 13 "POE-PS2"]\n"
                .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
            } elseif {$::moni::M(BoardTypeNum) == 199} {
                moni::saveerrlog "{T491}\[ERROR\][string replace $moni::MSG(sendPowerTest_log) 11 13 "POE-PS3"]\n"
                moni::savelog "[string replace $moni::MSG(sendPowerTest_log) 11 13 "POE-PS3"]\n"
                .testInfoDlg.labf2.t fastinsert end "\n[string replace $moni::MSG(sendPowerTest_log) 11 13 "POE-PS3"]\n"
                .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
            }

            if {$::moni::M(Manufactory) == "01"} {
                set ::moni::M(HandleString) 0
                set ::moni::M(ERROR_CODE) "T491"
                ::moni::get_result
                return
            }
        }

        if { $::moni::M(GetPower2) == 1 } {
            set ::moni::M(GetPower2) 0

            moni::addtesterr

            if {$::moni::M(BoardTypeNum) == 200} {
                moni::saveerrlog "{T491}\[ERROR\][string replace $moni::MSG(sendPowerTest_errlog) 14 16 "POE-PS2"]\n"
                moni::savelog "{T491}\[ERROR\][string replace $moni::MSG(sendPowerTest_errlog) 14 16 "POE-PS2"]\n"
                .testInfoDlg.labf2.t fastinsert end "\n[string replace $moni::MSG(sendPowerTest_errlog) 14 16 "POE-PS2"]\n"
                .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
            } elseif {$::moni::M(BoardTypeNum) == 199} {
                moni::saveerrlog "{T491}\[ERROR\]The status of POE-PS3 power is ERROR!\n"
                moni::savelog "{T491}\[ERROR\]The status of POE-PS3 power is ERROR!\n"
                .testInfoDlg.labf2.t fastinsert end "\nThe status of POE-PS3 power is ERROR!\n"
                .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
            }

            if {$::moni::M(Manufactory) == "01"} {
                set ::moni::M(HandleString) 0
                set ::moni::M(ERROR_CODE) "T491"
                ::moni::get_result
                return
            }
        }
    } else {
        set ::moni::M(GetPower1) 0
        set ::moni::M(GetPower2) 0
        ::moni::addtestok

        if {$::moni::M(BoardTypeNum) == 200} {
            ::moni::savelog "[string replace $moni::MSG(sendPowerTest_oklog) 1 3 "POE-PS2"]\n"
            .testInfoDlg.labf2.t fastinsert end "\n[string replace $moni::MSG(sendPowerTest_oklog) 1 3 "POE-PS2"]\n"
            .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
        } elseif {$::moni::M(BoardTypeNum) == 199} {
            ::moni::savelog "[string replace $moni::MSG(sendPowerTest_oklog) 1 3 "POE-PS3"]\n"
            .testInfoDlg.labf2.t fastinsert end "\n[string replace $moni::MSG(sendPowerTest_oklog) 1 3 "POE-PS3"]\n"
            .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
        }
    }

    .power6TestDlg.but2 configure -state normal

    ::moni::send $::moni::Cfg(name) "\x0A"
}

proc moni::sendPower7Test {} {
    variable M

    ::moni::reinit

    ::moni::send $::moni::Cfg(name) "backtest powerindextunnel 7\r"

    ::moni::wait 400

    .butCommonDlg.but1 configure -state disable

    ::moni::wait 2000

    ::moni::wait_power

    if {$::moni::M(GetPower1) == 1 || $::moni::M(GetPower2) == 1} {
        if {$::moni::M(GetPower1) == 1} {
            set ::moni::M(GetPower1) 0
            moni::addtesterr
            moni::saveerrlog "{T491}\[ERROR\][string replace $moni::MSG(sendPowerTest_log) 11 13 "POE-PS3"]\n"
            moni::savelog "[string replace $moni::MSG(sendPowerTest_log) 11 13 "POE-PS3"]\n"
            .testInfoDlg.labf2.t fastinsert end "\n[string replace $moni::MSG(sendPowerTest_log) 11 13 "POE-PS3"]\n"
            .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��

            if {$::moni::M(Manufactory) == "01"} {
                set ::moni::M(HandleString) 0
                set ::moni::M(ERROR_CODE) "T491"
                ::moni::get_result
                return
            }
        }

        if { $::moni::M(GetPower2) == 1 } {
            set ::moni::M(GetPower2) 0

            moni::addtesterr
            moni::saveerrlog "{T491}\[ERROR\]The status of POE-PS3 power is ERROR!\n"
            moni::savelog "{T491}\[ERROR\]The status of POE-PS3 power is ERROR!\n"
            .testInfoDlg.labf2.t fastinsert end "\nThe status of POE-PS3 power is ERROR!\n"
            .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��

            if {$::moni::M(Manufactory) == "01"} {
                set ::moni::M(HandleString) 0
                set ::moni::M(ERROR_CODE) "T491"
                ::moni::get_result
                return
            }
        }
    } else {
        set ::moni::M(GetPower1) 0
        set ::moni::M(GetPower2) 0
        ::moni::addtestok
        ::moni::savelog "[string replace $moni::MSG(sendPowerTest_oklog) 1 3 "POE-PS3"]\n"
        .testInfoDlg.labf2.t fastinsert end "\n[string replace $moni::MSG(sendPowerTest_oklog) 1 3 "POE-PS3"]\n"
        .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    }

    .butCommonDlg.but2 configure -state normal

    ::moni::send $::moni::Cfg(name) "\x0A"
}

proc moni::sendPower8Test {} {
    variable M

    ::moni::reinit

    ::moni::send $::moni::Cfg(name) "backtest powerindextunnel 8\r"

    ::moni::wait 400

    .power8TestDlg.but1 configure -state disable

    ::moni::wait 2000

    ::moni::wait_power

    if {$::moni::M(GetPower1) == 1 || $::moni::M(GetPower2) == 1} {
        if {$::moni::M(GetPower1) == 1} {
            set ::moni::M(GetPower1) 0
            moni::addtesterr
            moni::saveerrlog "{T491}\[ERROR\][string replace $moni::MSG(sendPowerTest_log) 11 13 "POE-PS4"]\n"
            moni::savelog "[string replace $moni::MSG(sendPowerTest_log) 11 13 "POE-PS4"]\n"
            .testInfoDlg.labf2.t fastinsert end "\n[string replace $moni::MSG(sendPowerTest_log) 11 13 "POE-PS4"]\n"
            .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��

            if {$::moni::M(Manufactory) == "01"} {
                set ::moni::M(HandleString) 0
                set ::moni::M(ERROR_CODE) "T491"
                ::moni::get_result
                return
            }
        }

        if { $::moni::M(GetPower2) == 1 } {
            set ::moni::M(GetPower2) 0

            moni::addtesterr
            moni::saveerrlog "{T491}\[ERROR\]The status of POE-PS4 power is ERROR!\n"
            moni::savelog "{T491}\[ERROR\]The status of POE-PS4 power is ERROR!\n"
            .testInfoDlg.labf2.t fastinsert end "\nThe status of POE-PS4 power is ERROR!\n"
            .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��

            if {$::moni::M(Manufactory) == "01"} {
                set ::moni::M(HandleString) 0
                set ::moni::M(ERROR_CODE) "T491"
                ::moni::get_result
                return
            }
        }
    } else {
        set ::moni::M(GetPower1) 0
        set ::moni::M(GetPower2) 0
        ::moni::addtestok
        ::moni::savelog "[string replace $moni::MSG(sendPowerTest_oklog) 1 3 "POE-PS4"]\n"
        .testInfoDlg.labf2.t fastinsert end "\n[string replace $moni::MSG(sendPowerTest_oklog) 1 3 "POE-PS4"]\n"
        .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    }

    .power8TestDlg.but2 configure -state normal

    ::moni::send $::moni::Cfg(name) "\x0A"
}




#BEGIN: Added by gujunqi, 2009/1/4
proc moni::sendledAllRedTest {} {
    variable M

    ::moni::send $::moni::Cfg(name) "singletest ledallred\r"
    ::moni::wait $::moni::M(waitLEDtime)
    .butCommonDlg.but1 configure -state normal
    .butCommonDlg.but2 configure -state normal
}

proc moni::ledAllRedTestPassed {} {

    .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledAllRedTestPassed_lab)\n"
    ::moni::savelog "$moni::MSG(ledAllRedTestPassed_lab)\n"

    .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    moni::addtestok
    moni::ledAllGreenTest
}

proc moni::ledAllRedTestNotPassed {} {
    set ::moni::M(ErrorFound) 1

    .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledAllRedTestNotPassed_lab)\n"
    moni::saveerrlog "{T508}\[ERROR\]$moni::MSG(ledAllRedTestNotPassed_lab)\n"
    moni::savelog "{T508}\[ERROR\]$moni::MSG(ledAllRedTestNotPassed_lab)\n"

    .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    moni::addtesterr
    #tk_messageBox -message "���ؿ�����ָʾ�Ƶ�첻����!"
    if {$::moni::M(Manufactory) == "01"} {
        set ::moni::M(HandleString) 0
        set ::moni::M(ERROR_CODE) "T508"
        ::moni::get_result
        return
    }
    moni::ledAllGreenTest
}

proc moni::ledAllGreenTest {} {
    variable M
    set M(TestItem) "ledAllGreenTest"
    ::moni::butComDlgCreate $moni::MSG(ledAllGreenTest_title) $moni::MSG(ledAllGreenTest_lab)
    
    ::moni::sendledAllGreenTest 
}

proc moni::sendledAllGreenTest {} {
    variable M

    if { $::moni::M(BoardTypeNum) == 170 || $::moni::M(BoardTypeNum) == 171 } {
        ::moni::send $::moni::Cfg(name) "portledgreen\r"
    } elseif { $::moni::M(BoardTypeNum) == 145} {
        ::moni::send $::moni::Cfg(name) "ledbcmgreen \r"
    } else {
        ::moni::send $::moni::Cfg(name) "singletest ledallgreen\r"
    }
    ::moni::wait $::moni::M(waitLEDtime)
    .butCommonDlg.but1 configure -state normal
    .butCommonDlg.but2 configure -state normal
}

proc moni::ledAllGreenTestPassed {} {

    .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledAllGreenTestPassed_lab)\n"
    ::moni::savelog "$moni::MSG(ledAllGreenTestPassed_lab)\n"

    .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    moni::addtestok
    if { $::moni::M(BoardTypeNum) == 145} {
        moni::ledPortOffTest
    } else {
        moni::ledAllOffTest
    }	
 
}

proc moni::ledAllGreenTestNotPassed {} {
    set ::moni::M(ErrorFound) 1

    .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledAllGreenTestNotPassed_lab)\n"
    moni::saveerrlog "{T508}\[ERROR\]$moni::MSG(ledAllGreenTestNotPassed_lab)\n"
    moni::savelog "{T508}\[ERROR\]$moni::MSG(ledAllGreenTestNotPassed_lab)\n"

    .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    moni::addtesterr
    #tk_messageBox -message "���ؿ�����ָʾ�Ƶ��̲�����!"
    if {$::moni::M(Manufactory) == "01"} {
        set ::moni::M(HandleString) 0
        set ::moni::M(ERROR_CODE) "T508"
        ::moni::get_result
        return
    }
    if { $::moni::M(BoardTypeNum) == 145} {
        moni::ledPortOffTest
    } else {
        moni::ledAllOffTest
    }	
}

proc moni::ledAllOrangeTest {} {
    variable M
    set M(TestItem) "ledAllOrangeTest"
    ::moni::butComDlgCreate $moni::MSG(ledAllORANGETest_title) $moni::MSG(ledAllORANGETest_lab)
    
    ::moni::sendledAllOrangeTest 
}

proc moni::sendledAllOrangeTest {} {
    variable M

    if { $::moni::M(BoardTypeNum) == 145} {
        ::moni::send $::moni::Cfg(name) "ledbcmorange \r"
    } else {
        ::moni::send $::moni::Cfg(name) "singletest ledallgreen\r"
    }
    ::moni::wait $::moni::M(waitLEDtime)
    .butCommonDlg.but1 configure -state normal
    .butCommonDlg.but2 configure -state normal
}

proc moni::ledAllOrangeTestPassed {} {

    .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledAllORANGETestPassed_lab)\n"
    ::moni::savelog "$moni::MSG(ledAllORANGETestPassed_lab)\n"

    .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    moni::addtestok

    if { $::moni::M(BoardTypeNum) == 145} {
        moni::ledAllGreenTest
    } else {
        moni::ledAllOffTest
    }		
}

proc moni::ledAllOrangeTestNotPassed {} {
    set ::moni::M(ErrorFound) 1

    .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledAllORANGETestNotPassed_lab)\n"
    moni::saveerrlog "{T508}\[ERROR\]$moni::MSG(ledAllORANGETestNotPassed_lab)\n"
    moni::savelog "{T508}\[ERROR\]$moni::MSG(ledAllORANGETestNotPassed_lab)\n"

    .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    moni::addtesterr
    #tk_messageBox -message "���ؿ�����ָʾ�Ƶ��̲�����!"
    if {$::moni::M(Manufactory) == "01"} {
        set ::moni::M(HandleString) 0
        set ::moni::M(ERROR_CODE) "T508"
        ::moni::get_result
        return
    }

    if { $::moni::M(BoardTypeNum) == 145} {
        moni::ledAllGreenTest
    } else {
        moni::ledAllOffTest
    }	
}

proc moni::ledAllOffTest {} {
    variable M
    set M(TestItem) "ledAllOffTest"
    ::moni::butComDlgCreate $moni::MSG(ledAllOffTest_title) $moni::MSG(ledAllOffTest_lab)
    ::moni::sendledAllOffTest
}

proc moni::sendledAllOffTest {} {
    variable M
    if { $::moni::M(BoardTypeNum) == 170 || $::moni::M(BoardTypeNum) == 171 } {
        ::moni::send $::moni::Cfg(name) "portledoff\r"
    } else {
        ::moni::send $::moni::Cfg(name) "singletest ledalloff\r"
    }
    ::moni::wait $::moni::M(waitLEDtime)
    .butCommonDlg.but1 configure -state normal
    .butCommonDlg.but2 configure -state normal
}

proc moni::ledAllOffTestPassed {} {

    .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledAllOffTestPassed_lab)\n"
    ::moni::savelog "$moni::MSG(ledAllOffTestPassed_lab)\n"

    .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    moni::addtestok
    moni::ledFanIndexTest
}

proc moni::ledAllOffTestNotPassed {} {
    set ::moni::M(ErrorFound) 1

    .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledAllOffTestNotPassed)\n"
    moni::saveerrlog "{T508}\[ERROR\]$moni::MSG(ledAllOffTestNotPassed)\n"
    moni::savelog "{T508}\[ERROR\]$moni::MSG(ledAllOffTestNotPassed)\n"

    .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    moni::addtesterr
    #tk_messageBox -message "���ؿ�����ָʾ�Ƶ�������!"
    if {$::moni::M(Manufactory) == "01"} {
        set ::moni::M(HandleString) 0
        set ::moni::M(ERROR_CODE) "T508"
        ::moni::get_result
        return
    }
    moni::ledFanIndexTest
}

proc moni::ledFanIndexTest {} {
    variable M
    set M(TestItem) "ledFanIndexTest"
    ::moni::butComDlgCreate $moni::MSG(ledFanIndexTest_title) $moni::MSG(ledFanIndexTest_lab)
    ::moni::sendledAllOffTest

    ::moni::sendledFanIndexTest

}

proc moni::sendledFanIndexTest {} {
    variable M

    ::moni::send $::moni::Cfg(name) "singletest ledfanindex\r"
    ::moni::wait $::moni::M(waitLEDtime)
    .butCommonDlg.but1 configure -state normal
    .butCommonDlg.but2 configure -state normal
}

proc moni::ledFanIndexTestPassed {} {
    .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledFanIndexTestPassed_lab)\n"
    ::moni::savelog "$moni::MSG(ledFanIndexTestPassed_lab)\n"

    .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    moni::addtestok
    moni::ledFanNoIndexTest
}

proc moni::ledFanIndexTestNotPassed {} {
    set ::moni::M(ErrorFound) 1

    .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledFanIndexTestNotPassed_lab)\n"
    moni::saveerrlog "{T506}\[ERROR\]$moni::MSG(ledFanIndexTestNotPassed_lab)\n"
    moni::savelog "{T506}\[ERROR\]$moni::MSG(ledFanIndexTestNotPassed_lab)\n"

    .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    moni::addtesterr
    #tk_messageBox -message "���ؿ�FAN��Ӧ��OKָʾ�Ƶ���������!"
    if {$::moni::M(Manufactory) == "01"} {
        set ::moni::M(HandleString) 0
        set ::moni::M(ERROR_CODE) "T506"
        ::moni::get_result
        return
    }
    moni::ledFanNoIndexTest
}

proc moni::ledFanNoIndexTest {} {
    variable M
    set M(TestItem) "ledFanNoIndexTest"
    ::moni::butComDlgCreate $moni::MSG(ledFanNoIndexTest_title) $moni::MSG(ledFanNoIndexTest_lab)
    ::moni::sendledFanNoIndexTest

}

proc moni::sendledFanNoIndexTest {} {
    variable M

    ::moni::send $::moni::Cfg(name) "singletest ledfannoindex\r"
    ::moni::wait $::moni::M(waitLEDtime)
    .butCommonDlg.but1 configure -state normal
    .butCommonDlg.but2 configure -state normal
}

proc moni::ledFanNoIndexTestPassed {} {
    .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledFanNoIndexTestPassed_lab)\n"
    ::moni::savelog "$moni::MSG(ledFanNoIndexTestPassed_lab)\n"

    .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    moni::addtestok
    moni::ledRunFastFlashTest
}

proc moni::ledFanNoIndexTestNotPassed {} {
    set ::moni::M(ErrorFound) 1

    .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledFanNoIndexTestNotPassed_lab)\n"
    moni::saveerrlog "{T506}\[ERROR\]$moni::MSG(ledFanNoIndexTestNotPassed_lab)\n"
    moni::savelog "{T506}\[ERROR\]$moni::MSG(ledFanNoIndexTestNotPassed_lab)\n"

    .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    moni::addtesterr
    #tk_messageBox -message "���ؿ�FAN��Ӧ��FAILָʾ�Ƶ���������!"
    if {$::moni::M(Manufactory) == "01"} {
        set ::moni::M(HandleString) 0
        set ::moni::M(ERROR_CODE) "T506"
        ::moni::get_result
        return
    }
    moni::ledRunFastFlashTest
}

proc moni::ledRunFastFlashTest {} {
    variable M
    set M(TestItem) "ledRunFastFlashTest"
    ::moni::butComDlgCreate $moni::MSG(ledRunFastFlashTest_title) $moni::MSG(ledRunFastFlashTest_lab)

    ::moni::sendledRunFastFlashTest

}

proc moni::sendledRunFastFlashTest {} {
    variable M

    ::moni::send $::moni::Cfg(name) "singletest ledrungreenfastflash\r"
    ::moni::wait $::moni::M(waitLEDtime)
    .butCommonDlg.but1 configure -state normal
    .butCommonDlg.but2 configure -state normal
}

proc moni::ledRunFastFlashTestPassed {} {
    .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledRunFastFlashTestPassed_lab)\n"
    ::moni::savelog "$moni::MSG(ledRunFastFlashTestPassed_lab)\n"

    .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    moni::addtestok
    moni::ledRunSlowFlashTest
}

proc moni::ledRunFastFlashTestNotPassed {} {
    set ::moni::M(ErrorFound) 1

    .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledRunFastFlashTestNotPassed_lab)\n"
    moni::saveerrlog "{T472}\[ERROR\]$moni::MSG(ledRunFastFlashTestNotPassed_lab)\n"
    moni::savelog "{T472}\[ERROR\]$moni::MSG(ledRunFastFlashTestNotPassed_lab)\n"

    .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    moni::addtesterr
    #tk_messageBox -message "���ؿ��ϵ�RUNָʾ�ƿ���������!"
    if {$::moni::M(Manufactory) == "01"} {
        set ::moni::M(HandleString) 0
        set ::moni::M(ERROR_CODE) "T472"
        ::moni::get_result
        return
    }
    moni::ledRunSlowFlashTest
}

proc moni::ledRunSlowFlashTest {} {
    variable M
    set M(TestItem) "ledRunSlowFlashTest"
    ::moni::butComDlgCreate $moni::MSG(ledRunSlowFlashTest_title) $moni::MSG(ledRunSlowFlashTest_lab)
    
    ::moni::sendledRunSlowFlashTest

}

proc moni::sendledRunSlowFlashTest {} {
    variable M

    ::moni::send $::moni::Cfg(name) "singletest ledrungreenslowflash\r"
    ::moni::wait $::moni::M(waitLEDtime)
    .butCommonDlg.but1 configure -state normal
    .butCommonDlg.but2 configure -state normal
}

proc moni::ledRunSlowFlashTestPassed {} {
    .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledRunSlowFlashTestPassed_lab)\n"
    ::moni::savelog "$moni::MSG(ledRunSlowFlashTestPassed_lab)\n"

    .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    moni::addtestok
    moni::ledCFIndexTest
}

proc moni::ledRunSlowFlashTestNotPassed {} {
    set ::moni::M(ErrorFound) 1

    .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledRunSlowFlashTestNotPassed_lab)\n"
    moni::saveerrlog "{T472}\[ERROR\]$moni::MSG(ledRunSlowFlashTestNotPassed_lab)\n"
    moni::savelog "{T472}\[ERROR\]$moni::MSG(ledRunSlowFlashTestNotPassed_lab)\n"

    .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    moni::addtesterr
    #tk_messageBox -message "���ؿ��ϵ�RUNָʾ������������!"
    if {$::moni::M(Manufactory) == "01"} {
        set ::moni::M(HandleString) 0
        set ::moni::M(ERROR_CODE) "T472"
        ::moni::get_result
        return
    }
    moni::ledCFIndexTest
}

proc moni::ledCFIndexTest {} {
    variable M
    set M(TestItem) "ledCFIndexTest"
    ::moni::butComDlgCreate $moni::MSG(ledCFIndexTest_title) $moni::MSG(ledCFIndexTest_lab)

    ::moni::sendledCFIndexTest

}

proc moni::sendledCFIndexTest {} {
    variable M

    ::moni::wait $::moni::M(waitLEDtime)
    .butCommonDlg.but1 configure -state normal
    .butCommonDlg.but2 configure -state normal
}

proc moni::ledCFIndexTestPassed {} {
    .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledCFIndexTestPassed_lab)\n"
    ::moni::savelog "$moni::MSG(ledCFIndexTestPassed_lab)\n"

    .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    moni::addtestok
    moni::ledCFNoIndexTest
}

proc moni::ledCFIndexTestNotPassed {} {
    set ::moni::M(ErrorFound) 1

    .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledCFIndexTestNotPassed_lab)\n"
    moni::saveerrlog "{T507}\[ERROR\]$moni::MSG(ledCFIndexTestNotPassed_lab)\n"
    moni::savelog "{T507}\[ERROR\]$moni::MSG(ledCFIndexTestNotPassed_lab)\n"

    .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    moni::addtesterr
    #tk_messageBox -message "CF��ָʾ�Ƶ���������!"
    if {$::moni::M(Manufactory) == "01"} {
        set ::moni::M(HandleString) 0
        set ::moni::M(ERROR_CODE) "T507"
        ::moni::get_result
        return
    }
    moni::ledCFNoIndexTest
}

proc moni::ledCFNoIndexTest {} {
    variable M
    set M(TestItem) "ledCFNoIndexTest"
    ::moni::butComDlgCreate $moni::MSG(ledCFNoIndexTest_title) $moni::MSG(ledCFNoIndexTest_lab) 

    ::moni::sendledCFNoIndexTest
}

proc moni::sendledCFNoIndexTest {} {
    variable M

    ::moni::wait $::moni::M(waitLEDtime)
    .butCommonDlg.but1 configure -state normal
    .butCommonDlg.but2 configure -state normal
}

proc moni::ledCFNoIndexTestPassed {} {
    .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledCFNoIndexTestPassed_lab)\n"
    ::moni::savelog "$moni::MSG(ledCFNoIndexTestPassed_lab)\n"

    .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    moni::addtestok

    #��������ؿ���Ҫ��M/Sָʾ��
    if {$::moni::M(BoardTypeNum) == 1 || $::moni::M(BoardTypeNum) == 13 \
        || $::moni::M(BoardTypeNum) == 15 || $::moni::M(BoardTypeNum) == 16 \
        || $::moni::M(BoardTypeNum) == 18 || $::moni::M(BoardTypeNum) == 28 \
        || $::moni::M(BoardTypeNum) == 31 || $::moni::M(BoardTypeNum) == 32 \
        || $::moni::M(BoardTypeNum) == 65 || $::moni::M(BoardTypeNum) == 77 \
        || $::moni::M(BoardTypeNum) == 79 || $::moni::M(BoardTypeNum) == 80 \
        || $::moni::M(BoardTypeNum) == 82 || $::moni::M(BoardTypeNum) == 86 \
        || $::moni::M(BoardTypeNum) == 92 || $::moni::M(BoardTypeNum) == 96 \
        || $::moni::M(BoardTypeNum) == 103 || $::moni::M(BoardTypeNum) == 39} {
        moni::ledMSOnTest
    } elseif {$::moni::M(BoardTypeNum) == 0 || $::moni::M(BoardTypeNum) == 0 \
        || $::moni::M(BoardTypeNum) == 0} {
        moni::test_end
    } elseif {$::moni::M(BoardTypeNum) == 28 || $::moni::M(BoardTypeNum) == 92 \
           || $::moni::M(BoardTypeNum) == 33 || $::moni::M(BoardTypeNum) == 97 \
           || $::moni::M(BoardTypeNum) == 34 || $::moni::M(BoardTypeNum) == 98 \
           || $::moni::M(BoardTypeNum) == 128 || $::moni::M(BoardTypeNum) == 129} {
        moni::mCardReset1Test
    } else {
        if {$::moni::M(BoardTypeNum) != 24 && $::moni::M(BoardTypeNum) != 25 \
            && $::moni::M(BoardTypeNum) != 26 && $::moni::M(BoardTypeNum) != 27 \
            && $::moni::M(BoardTypeNum) != 29 && $::moni::M(BoardTypeNum) != 30 \
            && $::moni::M(BoardTypeNum) != 88 && $::moni::M(BoardTypeNum) != 89 \
            && $::moni::M(BoardTypeNum) != 90 && $::moni::M(BoardTypeNum) != 91 \
            && $::moni::M(BoardTypeNum) != 93 && $::moni::M(BoardTypeNum) != 94} {
            moni::keySwapTest
        } else {
            moni::mCardReset1Test
        }
    }
}

proc moni::ledCFNoIndexTestNotPassed {} {
    set ::moni::M(ErrorFound) 1

    .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledCFNoIndexTestNotPassed_lab)\n"
    moni::saveerrlog "{T507}\[ERROR\]$moni::MSG(ledCFNoIndexTestNotPassed_lab)\n"
    moni::savelog "{T507}\[ERROR\]$moni::MSG(ledCFNoIndexTestNotPassed_lab)"

    .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    moni::addtesterr
    #tk_messageBox -message "CF��ָʾ�Ƶ�������!"
    if {$::moni::M(Manufactory) == "01"} {
        set ::moni::M(HandleString) 0
        set ::moni::M(ERROR_CODE) "T507"
        ::moni::get_result
        return
    }

    #��������ؿ���Ҫ��M/Sָʾ��
    if {$::moni::M(BoardTypeNum) == 1 || $::moni::M(BoardTypeNum) == 13 \
        || $::moni::M(BoardTypeNum) == 15 || $::moni::M(BoardTypeNum) == 16 \
        || $::moni::M(BoardTypeNum) == 18 || $::moni::M(BoardTypeNum) == 28 \
        || $::moni::M(BoardTypeNum) == 31 || $::moni::M(BoardTypeNum) == 32 \
        || $::moni::M(BoardTypeNum) == 38 \
        || $::moni::M(BoardTypeNum) == 65 || $::moni::M(BoardTypeNum) == 77 \
        || $::moni::M(BoardTypeNum) == 79 || $::moni::M(BoardTypeNum) == 80 \
        || $::moni::M(BoardTypeNum) == 82 || $::moni::M(BoardTypeNum) == 86 \
        || $::moni::M(BoardTypeNum) == 92 || $::moni::M(BoardTypeNum) == 96 \
        || $::moni::M(BoardTypeNum) == 103 || $::moni::M(BoardTypeNum) == 39} {
        moni::ledMSOnTest
    } elseif {$::moni::M(BoardTypeNum) == 0 || $::moni::M(BoardTypeNum) == 0 \
        || $::moni::M(BoardTypeNum) == 0} {
        moni::test_end
    } elseif {$::moni::M(BoardTypeNum) == 28 || $::moni::M(BoardTypeNum) == 92 \
           || $::moni::M(BoardTypeNum) == 33 || $::moni::M(BoardTypeNum) == 97 \
           || $::moni::M(BoardTypeNum) == 34 || $::moni::M(BoardTypeNum) == 98 \
           || $::moni::M(BoardTypeNum) == 128 || $::moni::M(BoardTypeNum) == 129} {
        moni::sCardResetTest
    } else {
        if {$::moni::M(BoardTypeNum) != 24 && $::moni::M(BoardTypeNum) != 25 \
            && $::moni::M(BoardTypeNum) != 26 && $::moni::M(BoardTypeNum) != 27 \
            && $::moni::M(BoardTypeNum) != 29 && $::moni::M(BoardTypeNum) != 30 \
            && $::moni::M(BoardTypeNum) != 88 && $::moni::M(BoardTypeNum) != 89 \
            && $::moni::M(BoardTypeNum) != 90 && $::moni::M(BoardTypeNum) != 91 \
            && $::moni::M(BoardTypeNum) != 93 && $::moni::M(BoardTypeNum) != 94} {
            moni::keySwapTest
        } else {
            moni::mCardReset1Test
        }
    }
}
#END:   Added by gujunqi, 2009/1/4







proc moni::ledPortOnTest {} {
    variable M
    #catch {destroy .testInfoDlg.labf4}
    if {$::moni::M(BoardTypeNum) == 15 || $::moni::M(BoardTypeNum) == 16 \
    		|| $::moni::M(BoardTypeNum) == 38 \
        || $::moni::M(BoardTypeNum) == 79 || $::moni::M(BoardTypeNum) == 80} {
        ::moni::ledRunRedTest
        return
    }
   #/*Begin:by yueql,2011/03/25,Ŀǰ����������LED�Ʋ���Ҫ���ߣ����Խ���ʾ����ȥ��*/
   # if {$::moni::M(Ispullcables) == "y"} {
   #     if {$::moni::M(BoardTypeNum) == 29 || $::moni::M(BoardTypeNum) == 93 \
   #         || $::moni::M(BoardTypeNum) == 30 || $::moni::M(BoardTypeNum) == 94 \
   #         || $::moni::M(BoardTypeNum) == 134 || $::moni::M(BoardTypeNum) == 136 \
   #         || $::moni::M(BoardTypeNum) == 132 || $::moni::M(BoardTypeNum) == 137\
   #        || $::moni::M(BoardTypeNum) == 138\
   #     	|| $::moni::M(BoardTypeNum) == 32 || $::moni::M(BoardTypeNum) == 33 \
   #         || $::moni::M(BoardTypeNum) == 34 || $::moni::M(BoardTypeNum) == 96 \
   #         || $::moni::M(BoardTypeNum) == 97 || $::moni::M(BoardTypeNum) == 98 \
   #         || $::moni::M(BoardTypeNum) == 103 || $::moni::M(BoardTypeNum) == 39 \
   #         } {

   #     } elseif {$::moni::M(BoardTypeNum) == 129 && $::moni::M(IsChassis) == 0} {
   #         #tk_messageBox -message "Please click ��Confirm�� to begin LED test!"    
   #     } elseif {$::moni::M(BoardTypeNum) == 131} {
   #         if {$::moni::M(IsChassis) == 0} {
   #             #tk_messageBox -message "Please click ��Confirm�� to begin LED test!" 
   #         } else {
   #             tk_messageBox -message "$moni::MSG(ledPortOnTest_pair_msg)"
   #         }        
   #     } elseif {$::moni::M(BoardTypeNum) == 36 || $::moni::M(BoardTypeNum) == 37 \
   #         || $::moni::M(BoardTypeNum) == 42 || $::moni::M(BoardTypeNum) == 43 \
   #         || $::moni::M(BoardTypeNum) == 100 || $::moni::M(BoardTypeNum) == 101 \
   #         || $::moni::M(BoardTypeNum) == 106 || $::moni::M(BoardTypeNum) == 107} {
   #         tk_messageBox -message "$moni::MSG(ledPortOnTest_pair_msg)"
   #     } else {
   #         tk_messageBox -message "$moni::MSG(ledPortOnTest_pair_msg)"
   #     }
   # }
   #/*End:by yueql,2011/03/25,Ŀǰ����������LED�Ʋ���Ҫ���ߣ����Խ���ʾ����ȥ��*/

    set M(TestItem) "ledPortOnTest"
    ::moni::butComDlgCreate $moni::MSG(ledPortOnTest_title) $moni::MSG(ledPortOnTest_linecard_lab) 

    ::moni::sendledPortOnTest

}

proc moni::ledPortOnTestPassed {} {

    .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledPortOnTestPassed_lab)\n"
    ::moni::savelog "$moni::MSG(ledPortOnTestPassed_lab)\n"

    .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    moni::addtestok
    moni::ledPortOffTest
}

proc moni::ledPortOnTestNotPassed {} {
    set ::moni::M(ErrorFound) 1

    .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledPortOnTestNotPassed_lab)\n"
    moni::saveerrlog "{T471}\[ERROR\]$moni::MSG(ledPortOnTestNotPassed_lab)\n"
    moni::savelog "{T471}\[ERROR\]$moni::MSG(ledPortOnTestNotPassed_lab)\n"

    .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    moni::addtesterr
    if {$::moni::M(Manufactory) == "01"} {
        set ::moni::M(HandleString) 0
        set ::moni::M(ERROR_CODE) "T471"
        ::moni::get_result
        return
    }
    moni::ledPortOffTest
}

proc moni::sendledPortOnTest {} {
    variable M
    if { $::moni::M(BoardTypeNum) == 170 || $::moni::M(BoardTypeNum) == 171 } {
        ::moni::send $::moni::Cfg(name) "portledgreen\r"
    } else {    
        ::moni::send $::moni::Cfg(name) "ledbcmon\r"
    }
    ::moni::wait $::moni::M(waitLEDtime)
    .butCommonDlg.but1 configure -state normal
    .butCommonDlg.but2 configure -state normal
}

proc moni::ledPortOffTest {} {
    catch {destroy .butCommonDlg}
    variable M
    set M(TestItem) "ledPortOffTest"
    ::moni::butComDlgCreate $moni::MSG(ledPortOffTest_title) $moni::MSG(ledPortOffTest_linecard_lab) 

    ::moni::sendledPortOffTest
}

proc moni::ledPortOffTestPassed {} {
    .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledPortOffTestPassed_lab)\n"
    ::moni::savelog "$moni::MSG(ledPortOffTestPassed_lab)\n"

    .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    moni::addtestok
    if {$::moni::M(BoardTypeNum) == 170 || $::moni::M(BoardTypeNum) == 171} {
        #moni::powerSwitch   
        moni::mutualTest
    } elseif {$::moni::M(BoardTypeNum) == 27 || $::moni::M(BoardTypeNum) == 30 \
        || $::moni::M(BoardTypeNum) == 91 || $::moni::M(BoardTypeNum) == 94 \
        || $::moni::M(BoardTypeNum) == 132 || $::moni::M(BoardTypeNum) == 134\
        || $::moni::M(BoardTypeNum) == 136 || $::moni::M(BoardTypeNum) == 137
        || $::moni::M(BoardTypeNum) == 138 || $::moni::M(BoardTypeNum) == 145} {
        moni::mCardReset1Test
    } elseif {$::moni::M(BoardTypeNum) == 131} {    
        if {$::moni::M(IsChassis) == 0} {  		
            ::moni::get_result    	
        } else {
            moni::mCardReset1Test
        }    	
    } elseif {$::moni::M(BoardTypeNum) == 31} {
        moni::ledRunGreenTest
    } elseif {$::moni::M(BoardTypeNum) == 32 || $::moni::M(BoardTypeNum) == 96 \
        || $::moni::M(BoardTypeNum) == 33 || $::moni::M(BoardTypeNum) == 97 \
        || $::moni::M(BoardTypeNum) == 34 || $::moni::M(BoardTypeNum) == 98 \
        || $::moni::M(BoardTypeNum) == 36 || $::moni::M(BoardTypeNum) == 100 \
        || $::moni::M(BoardTypeNum) == 37 || $::moni::M(BoardTypeNum) == 101 \
        || $::moni::M(BoardTypeNum) == 42 || $::moni::M(BoardTypeNum) == 106 \
        || $::moni::M(BoardTypeNum) == 43 || $::moni::M(BoardTypeNum) == 107 \
        || $::moni::M(BoardTypeNum) == 39 || $::moni::M(BoardTypeNum) == 103} {
        moni::ledRunGFTest
    } elseif {$::moni::M(IsChassis) == 0 || $::moni::M(BoardTypeNum) == 129} {
        ::moni::get_result
    } else {
        moni::ledRunRedTest
    }
}

proc moni::ledPortOffTestNotPassed {} {
    set ::moni::M(ErrorFound) 1

    .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledPortOffTestNotPassed_lab)\n"
    moni::saveerrlog "{T471}\[ERROR\]$moni::MSG(ledPortOffTestNotPassed_lab)\n"
    moni::savelog "{T471}\[ERROR\]$moni::MSG(ledPortOffTestNotPassed_lab)\n"

    .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    moni::addtesterr
    if {$::moni::M(Manufactory) == "01"} {
        set ::moni::M(HandleString) 0
        set ::moni::M(ERROR_CODE) "T471"
        ::moni::get_result
        return
    }
    if {$::moni::M(BoardTypeNum) == 170 || $::moni::M(BoardTypeNum) == 171} {
        #moni::powerSwitch    
        moni::mutualTest
    } elseif {$::moni::M(BoardTypeNum) == 27 || $::moni::M(BoardTypeNum) == 30 \
        || $::moni::M(BoardTypeNum) == 91 || $::moni::M(BoardTypeNum) == 94 \
        || $::moni::M(BoardTypeNum) == 132 || $::moni::M(BoardTypeNum) == 134\
        || $::moni::M(BoardTypeNum) == 136 || $::moni::M(BoardTypeNum) == 137
        || $::moni::M(BoardTypeNum) == 138 || $::moni::M(BoardTypeNum) == 145} {
        moni::mCardReset1Test
    } elseif {$::moni::M(BoardTypeNum) == 131} {    
    	if {$::moni::M(IsChassis) == 0} {
    	    ::moni::get_result    	
    	} else {
    	    moni::mCardReset1Test
    	}          
    } elseif {$::moni::M(BoardTypeNum) == 31} {
        moni::ledRunGreenTest
    } elseif {$::moni::M(BoardTypeNum) == 32 || $::moni::M(BoardTypeNum) == 96 \
        || $::moni::M(BoardTypeNum) == 33 || $::moni::M(BoardTypeNum) == 97 \
        || $::moni::M(BoardTypeNum) == 34 || $::moni::M(BoardTypeNum) == 98 \
        || $::moni::M(BoardTypeNum) == 36 || $::moni::M(BoardTypeNum) == 100 \
        || $::moni::M(BoardTypeNum) == 37 || $::moni::M(BoardTypeNum) == 101 \
        || $::moni::M(BoardTypeNum) == 42 || $::moni::M(BoardTypeNum) == 106 \
        || $::moni::M(BoardTypeNum) == 43 || $::moni::M(BoardTypeNum) == 107 \
        || $::moni::M(BoardTypeNum) == 39 || $::moni::M(BoardTypeNum) == 103} {
        moni::ledRunGFTest
    } elseif {$::moni::M(IsChassis) == 0 || $::moni::M(BoardTypeNum) == 129} {
        ::moni::get_result        
    } else {
        moni::ledRunRedTest
    }
}

proc moni::sendledPortOffTest {} {
    variable M
    if { $::moni::M(BoardTypeNum) == 170 || $::moni::M(BoardTypeNum) == 171 } {
        ::moni::send $::moni::Cfg(name) "portledoff\r"
    } elseif {$::moni::M(BoardTypeNum) == 156 || $::moni::M(BoardTypeNum) == 157 \
        || $::moni::M(BoardTypeNum) == 158 || $::moni::M(BoardTypeNum) == 159} {
        ::moni::send $::moni::Cfg(name) "portledoff\r"
    } else {
        ::moni::send $::moni::Cfg(name) "ledbcmoff\r"
    }

    ::moni::wait $::moni::M(waitLEDtime)
    .butCommonDlg.but1 configure -state normal
    .butCommonDlg.but2 configure -state normal
}

proc moni::ledRunRedTest {} {
    variable M
    #catch {destroy .testInfoDlg.labf4}
    #BEGIN: Added by liuyce, 2010/3/18   PN:41760 NEW MI�����Ժ��,��ת����һ�����    
    if {$::moni::M(BoardTypeNum) == 38 || $::moni::M(BoardTypeNum) == 40 \
    	|| $::moni::M(BoardTypeNum) == 41 || $::moni::M(BoardTypeNum) == 104 \
	|| $::moni::M(BoardTypeNum) == 105} {
        ::moni::ledRunGFTest
        return
    }    
    #END:   Added by liuyce, 2010/3/18 

    set M(TestItem) "ledRunRedTest"

    if {$::moni::M(BoardTypeNum) == 28 || $::moni::M(BoardTypeNum) == 31 \
        || $::moni::M(BoardTypeNum) == 92} {
            ::moni::butComDlgCreate $moni::MSG(ledRunRedTest_title) $moni::MSG(ledRunRedTest_lab1) 
    } else {
        ::moni::butComDlgCreate $moni::MSG(ledRunRedTest_title) $moni::MSG(ledRunRedTest_lab2) 
    }

    moni::sendledRunRedTest
}

proc moni::ledRunRedTestPassed {} {
    if {$::moni::M(BoardTypeNum) == 28 || $::moni::M(BoardTypeNum) == 31 \
        || $::moni::M(BoardTypeNum) == 92} {
        .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledRunRedTestPassed_lab1)\n"
        .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
        moni::savelog "$moni::MSG(ledRunRedTestPassed_lab1)\n"
        moni::addtestok
        moni::ledRunGreenTest
    } else {
        .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledRunRedTestPassed_lab2)\n"
        .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
        moni::savelog "$moni::MSG(ledRunRedTestPassed_lab2)\n"
        moni::addtestok
        moni::ledRunGFTest
    }
}

proc moni::ledRunRedTestNotPassed {} {
    set ::moni::M(ErrorFound) 1
    if {$::moni::M(BoardTypeNum) == 28 || $::moni::M(BoardTypeNum) == 31 \
        || $::moni::M(BoardTypeNum) == 92} {
        .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledRunRedTestNotPassed_lab1)\n"
        .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
        moni::saveerrlog "$moni::MSG(ledRunRedTestNotPassed_lab1)\n"
        moni::savelog "$moni::MSG(ledRunRedTestNotPassed_lab1)\n"
        moni::addtesterr
        if {$::moni::M(Manufactory) == "01"} {
            set ::moni::M(HandleString) 0
            set ::moni::M(ERROR_CODE) "T472"
            ::moni::get_result
            return
        }
        moni::ledRunGreenTest
    } else {
        .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledRunRedTestNotPassed_lab2)\n"
        .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
        moni::saveerrlog "$moni::MSG(ledRunRedTestNotPassed_lab2)\n"
        moni::savelog "$moni::MSG(ledRunRedTestNotPassed_lab2)\n"
        moni::addtesterr
        if {$::moni::M(Manufactory) == "01"} {
            set ::moni::M(HandleString) 0
            set ::moni::M(ERROR_CODE) "T472"
            ::moni::get_result
            return
        }
        moni::ledRunGFTest
    }
}

proc moni::sendledRunRedTest {} {
    variable M

    if {$::moni::M(BoardTypeNum) == 28 || $::moni::M(BoardTypeNum) == 32 \
        || $::moni::M(BoardTypeNum) == 92 || $::moni::M(BoardTypeNum) == 96 \
        || $::moni::M(BoardTypeNum) == 39 || $::moni::M(BoardTypeNum) == 103} {
        ::moni::send $::moni::Cfg(name) "singletest ledrunredon\r"
    } else {
        ::moni::send $::moni::Cfg(name) "singletest ledrunredflash\r"
    }
    ::moni::wait $::moni::M(waitLEDtime)
    .butCommonDlg.but1 configure -state normal
    .butCommonDlg.but2 configure -state normal
}

proc moni::ledRunGreenTest {} {
    if {$::moni::M(BoardTypeNum) == 31} {
    #    catch {destroy .testInfoDlg.labf4}
    }

    variable M
    set M(TestItem) "ledRunGreenTest"
    ::moni::butComDlgCreate $moni::MSG(ledRunGreenTest_title) $moni::MSG(ledRunGreenTest_lab)

    moni::sendledRunGreenTest
}

proc moni::ledRunGreenTestPassed {} {
    .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledRunGreenTestPassed_lab)\n"
    .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    moni::savelog "$moni::MSG(ledRunGreenTestPassed_lab)\n"
    moni::addtestok
    if {$::moni::M(BoardTypeNum) == 31} {
        moni::ledRunOffTest
    } else {
        moni::ledRunOrangeOnTest
    }
}

proc moni::ledRunGreenTestNotPassed {} {
    set ::moni::M(ErrorFound) 1

    .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledRunGreenTestNotPassed_lab)\n"
    .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    moni::saveerrlog "$moni::MSG(ledRunGreenTestNotPassed_lab)\n"
    moni::savelog "$moni::MSG(ledRunGreenTestNotPassed_lab)\n"
    moni::addtesterr
    if {$::moni::M(Manufactory) == "01"} {
        set ::moni::M(HandleString) 0
        set ::moni::M(ERROR_CODE) "T472"
        ::moni::get_result
        return
    }
    if {$::moni::M(BoardTypeNum) == 31} {
        moni::ledRunOffTest
    } else {
        moni::ledRunOrangeOnTest
    }
}

proc moni::sendledRunGreenTest {} {
    variable M

    ::moni::send $::moni::Cfg(name) "singletest ledrungreenon\r"
    ::moni::wait $::moni::M(waitLEDtime)
    .butCommonDlg.but1 configure -state normal
    .butCommonDlg.but2 configure -state normal
}

proc moni::ledRunGFTest {} {
    variable M
    set M(TestItem) "ledRunGFTest"
    
    if {$::moni::M(BoardTypeNum) == 28 || $::moni::M(BoardTypeNum) == 31 \
        || $::moni::M(BoardTypeNum) == 92} {
       ::moni::butComDlgCreate $moni::MSG(ledRunGFTest_title1) $moni::MSG(ledRunGFTest_lab1)
    } else {
       ::moni::butComDlgCreate $moni::MSG(ledRunGFTest_title2) $moni::MSG(ledRunGFTest_lab2)
    }

    moni::sendledRunGFTest
}

proc moni::ledRunGFTestPassed {} {
    if {$::moni::M(BoardTypeNum) == 28 || $::moni::M(BoardTypeNum) == 31 \
        || $::moni::M(BoardTypeNum) == 92} {
        .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledRunGFTestPassed_lab1)\n"
        .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
        moni::savelog "$moni::MSG(ledRunGFTestPassed_lab1)\n"
        moni::addtestok
        moni::ledRunOrangeOnTest
    } else {
        .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledRunGFTestPassed_lab2)\n"
        .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
        moni::savelog "$moni::MSG(ledRunGFTestPassed_lab2)\n"
        moni::addtestok
        moni::ledRunGSTest
    }
}

proc moni::ledRunGFTestNotPassed {} {
    set ::moni::M(ErrorFound) 1
    if {$::moni::M(BoardTypeNum) == 28 || $::moni::M(BoardTypeNum) == 31 \
        || $::moni::M(BoardTypeNum) == 92} {
        .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledRunGFTestNotPassed_lab1)\n"
        .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
        moni::saveerrlog "$moni::MSG(ledRunGFTestNotPassed_lab1)\n"
        moni::savelog "$moni::MSG(ledRunGFTestNotPassed_lab1)\n"
        moni::addtesterr
        if {$::moni::M(Manufactory) == "01"} {
            set ::moni::M(HandleString) 0
            set ::moni::M(ERROR_CODE) "T472"
            ::moni::get_result
            return
        }
        moni::ledRunOrangeOnTest
    } else {
        .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledRunGFTestNotPassed_lab2)\n"
        .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
        moni::saveerrlog "$moni::MSG(ledRunGFTestNotPassed_lab2)\n"
        moni::savelog "$moni::MSG(ledRunGFTestNotPassed_lab2)\n"
        moni::addtesterr
        if {$::moni::M(Manufactory) == "01"} {
            set ::moni::M(HandleString) 0
            set ::moni::M(ERROR_CODE) "T472"
            ::moni::get_result
            return
        }
        moni::ledRunGSTest
    }
}

proc moni::sendledRunGFTest {} {
    variable M

    ::moni::send $::moni::Cfg(name) "singletest ledrungreenfastflash\r"
    ::moni::wait $::moni::M(waitLEDtime)
    .butCommonDlg.but1 configure -state normal
    .butCommonDlg.but2 configure -state normal
}

proc moni::ledRunGSTest {} {
    variable M
    set M(TestItem) "ledRunGSTest"
    ::moni::butComDlgCreate $moni::MSG(ledRunGSTest_title) $moni::MSG(ledRunGSTest_lab)
    
    moni::sendledRunGSTest

}

proc moni::ledRunGSTestPassed {} {
    .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledRunGSTestPassed_lab)\n"
    .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    moni::savelog "$moni::MSG(ledRunGSTestPassed_lab)\n"
    moni::addtestok
    if {$::moni::M(BoardTypeNum) == 32 || $::moni::M(BoardTypeNum) == 96 \
        || $::moni::M(BoardTypeNum) == 33 || $::moni::M(BoardTypeNum) == 97 \
        || $::moni::M(BoardTypeNum) == 34 || $::moni::M(BoardTypeNum) == 98 \
        || $::moni::M(BoardTypeNum) == 36 || $::moni::M(BoardTypeNum) == 100 \
        || $::moni::M(BoardTypeNum) == 37 || $::moni::M(BoardTypeNum) == 101 \
        || $::moni::M(BoardTypeNum) == 42 || $::moni::M(BoardTypeNum) == 106 \
        || $::moni::M(BoardTypeNum) == 43 || $::moni::M(BoardTypeNum) == 107 \
        || $::moni::M(BoardTypeNum) == 39 || $::moni::M(BoardTypeNum) == 103} {
        moni::ledRunOffTest
    } else {
        moni::ledRunOrangeOnTest
    }
}

proc moni::ledRunGSTestNotPassed {} {
    set ::moni::M(ErrorFound) 1
    .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledRunGSTestNotPassed_lab)\n"
    .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    moni::saveerrlog "$moni::MSG(ledRunGSTestNotPassed_lab)\n"
    moni::savelog "$moni::MSG(ledRunGSTestNotPassed_lab)\n"
    moni::addtesterr
    if {$::moni::M(BoardTypeNum) == 32 || $::moni::M(BoardTypeNum) == 96 \
        || $::moni::M(BoardTypeNum) == 33 || $::moni::M(BoardTypeNum) == 97 \
        || $::moni::M(BoardTypeNum) == 34 || $::moni::M(BoardTypeNum) == 98 \
        || $::moni::M(BoardTypeNum) == 36 || $::moni::M(BoardTypeNum) == 100 \
        || $::moni::M(BoardTypeNum) == 37 || $::moni::M(BoardTypeNum) == 101 \
        || $::moni::M(BoardTypeNum) == 42 || $::moni::M(BoardTypeNum) == 106 \
        || $::moni::M(BoardTypeNum) == 43 || $::moni::M(BoardTypeNum) == 107 \
        || $::moni::M(BoardTypeNum) == 39 || $::moni::M(BoardTypeNum) == 103} {
        moni::ledRunOffTest
    } else {
        moni::ledRunOrangeOnTest
    }
}

proc moni::sendledRunGSTest {} {
    variable M

    ::moni::send $::moni::Cfg(name) "singletest ledrungreenslowflash\r"
    ::moni::wait $::moni::M(waitLEDtime)
    .butCommonDlg.but1 configure -state normal
    .butCommonDlg.but2 configure -state normal
}

proc moni::ledRunOrangeOnTest {} {
    variable M
    set M(TestItem) "ledRunOrangeOnTest"

    #BEGIN: Added by liuyce, 2010/3/18   PN:41760 NEW MI�����Գȵ�,��ת����һ�����       
    if {$::moni::M(BoardTypeNum) == 38 || $::moni::M(BoardTypeNum) == 40 \
	|| $::moni::M(BoardTypeNum) == 41 || $::moni::M(BoardTypeNum) == 104 \
	|| $::moni::M(BoardTypeNum) == 105} {
        ::moni::ledRunOffTest
        return
    }       
    #END:   Added by liuyce, 2010/3/18   

    if {$::moni::M(BoardTypeNum) == 28 \
        || $::moni::M(BoardTypeNum) == 92} {
        ::moni::butComDlgCreate $moni::MSG(ledRunOrangeOnTest_title) $moni::MSG(ledRunOrangeOnTest_lab1)
    } else {
        ::moni::butComDlgCreate $moni::MSG(ledRunOrangeOnTest_title) $moni::MSG(ledRunOrangeOnTest_lab2)
    }

    moni::sendledRunOrangeOnTest
}

proc moni::ledRunOrangeOnTestPassed {} {
    .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledRunOrangeOnTestPassed_lab)\n"
  .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
  moni::savelog "$moni::MSG(ledRunOrangeOnTestPassed_lab)\n"
  moni::addtestok
  moni::ledRunOffTest
}

proc moni::ledRunOrangeOnTestNotPassed {} {
    set ::moni::M(ErrorFound) 1
  .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledRunOrangeOnTestNotPassed_lab)\n"
  .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
  moni::saveerrlog "$moni::MSG(ledRunOrangeOnTestNotPassed_lab)\n"
  moni::savelog "$moni::MSG(ledRunOrangeOnTestNotPassed_lab)\n"
  moni::addtesterr
	if {$::moni::M(Manufactory) == "01"} {
        set ::moni::M(HandleString) 0
        set ::moni::M(ERROR_CODE) "T472"
        ::moni::get_result
        return
    }
  moni::ledRunOffTest
}

proc moni::sendledRunOrangeOnTest {} {
    variable M
    if {$::moni::M(BoardTypeNum) == 28 \
        || $::moni::M(BoardTypeNum) == 92} {
        ::moni::send $::moni::Cfg(name) "singletest ledrunyellowon\r"
    } else {
        ::moni::send $::moni::Cfg(name) "singletest ledrunorangeflash\r"
    }
    ::moni::wait $::moni::M(waitLEDtime)
    .butCommonDlg.but1 configure -state normal
    .butCommonDlg.but2 configure -state normal
}

proc moni::ledRunOffTest {} {
    variable M
    set M(TestItem) "ledRunOffTest"
    ::moni::butComDlgCreate $moni::MSG(ledRunOffTest_title) $moni::MSG(ledRunOffTest_lab)
    
    ::moni::sendledRunOffTest
}

proc moni::ledRunOffTestPassed {} {
    catch {destroy .butCommonDlg }

    .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledRunOffTestPassed_lab)\n"
    .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    moni::savelog "$moni::MSG(ledRunOffTestPassed_lab)\n"

    moni::addtestok
    #��������ؿ���Ҫ��M/Sָʾ��
    if {$::moni::M(BoardTypeNum) == 1 || $::moni::M(BoardTypeNum) == 13 \
        || $::moni::M(BoardTypeNum) == 15 || $::moni::M(BoardTypeNum) == 16 \
        || $::moni::M(BoardTypeNum) == 18 || $::moni::M(BoardTypeNum) == 28 \
        || $::moni::M(BoardTypeNum) == 31 || $::moni::M(BoardTypeNum) == 32 \
        || $::moni::M(BoardTypeNum) == 38 \
        || $::moni::M(BoardTypeNum) == 65 || $::moni::M(BoardTypeNum) == 77 \
        || $::moni::M(BoardTypeNum) == 79 || $::moni::M(BoardTypeNum) == 80 \
        || $::moni::M(BoardTypeNum) == 82 || $::moni::M(BoardTypeNum) == 86 \
        || $::moni::M(BoardTypeNum) == 92 || $::moni::M(BoardTypeNum) == 96 \
        || $::moni::M(BoardTypeNum) == 39 || $::moni::M(BoardTypeNum) == 103} {

        moni::ledMSOnTest
    } elseif {$::moni::M(BoardTypeNum) == 0 || $::moni::M(BoardTypeNum) == 0 \
        || $::moni::M(BoardTypeNum) == 0} {
        moni::test_end
    } elseif {$::moni::M(BoardTypeNum) == 28 || $::moni::M(BoardTypeNum) == 92 \
           || $::moni::M(BoardTypeNum) == 33 || $::moni::M(BoardTypeNum) == 97 \
           || $::moni::M(BoardTypeNum) == 34 || $::moni::M(BoardTypeNum) == 98} {
        moni::mCardReset1Test
    } elseif {$::moni::M(BoardTypeNum) == 42 || $::moni::M(BoardTypeNum) == 43\
           || $::moni::M(BoardTypeNum) == 106 || $::moni::M(BoardTypeNum) == 107} {
        moni::sCardResetTest
    } else {
        if {$::moni::M(BoardTypeNum) != 24 && $::moni::M(BoardTypeNum) != 25 \
            && $::moni::M(BoardTypeNum) != 26 && $::moni::M(BoardTypeNum) != 27 \
            && $::moni::M(BoardTypeNum) != 29 && $::moni::M(BoardTypeNum) != 30 \
            && $::moni::M(BoardTypeNum) != 88 && $::moni::M(BoardTypeNum) != 89 \
            && $::moni::M(BoardTypeNum) != 90 && $::moni::M(BoardTypeNum) != 91 \
            && $::moni::M(BoardTypeNum) != 93 && $::moni::M(BoardTypeNum) != 94 \
            && $::moni::M(BoardTypeNum) != 36 && $::moni::M(BoardTypeNum) != 100 \
            && $::moni::M(BoardTypeNum) != 37 && $::moni::M(BoardTypeNum) != 101} {
            moni::keySwapTest
        } else {
            moni::mCardReset1Test
        }
    }
}

proc moni::ledRunOffTestNotPassed {} {
    catch {destroy .butCommonDlg }
    set ::moni::M(ErrorFound) 1
    .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledRunOffTestNotPassed_lab)\n"
    .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    moni::saveerrlog "$moni::MSG(ledRunOffTestNotPassed_lab)\n"
    moni::savelog "$moni::MSG(ledRunOffTestNotPassed_lab)\n"
    moni::addtesterr
    if {$::moni::M(Manufactory) == "01"} {
        set ::moni::M(HandleString) 0
        set ::moni::M(ERROR_CODE) "T472"
        ::moni::get_result
        return
    }
    #��������ؿ���Ҫ��M/Sָʾ��
    if {$::moni::M(BoardTypeNum) == 1 || $::moni::M(BoardTypeNum) == 13 \
        || $::moni::M(BoardTypeNum) == 15 || $::moni::M(BoardTypeNum) == 16 \
        || $::moni::M(BoardTypeNum) == 18 || $::moni::M(BoardTypeNum) == 28 \
        || $::moni::M(BoardTypeNum) == 31 || $::moni::M(BoardTypeNum) == 32 \
        || $::moni::M(BoardTypeNum) == 38 \
        || $::moni::M(BoardTypeNum) == 65 || $::moni::M(BoardTypeNum) == 77 \
        || $::moni::M(BoardTypeNum) == 79 || $::moni::M(BoardTypeNum) == 80 \
        || $::moni::M(BoardTypeNum) == 82 || $::moni::M(BoardTypeNum) == 86 \
        || $::moni::M(BoardTypeNum) == 92 || $::moni::M(BoardTypeNum) == 96 \
        || $::moni::M(BoardTypeNum) == 39 || $::moni::M(BoardTypeNum) == 103} {

        moni::ledMSOnTest
    } elseif {$::moni::M(BoardTypeNum) == 0 || $::moni::M(BoardTypeNum) == 0 \
        || $::moni::M(BoardTypeNum) == 0} {
        moni::test_end
    } elseif {$::moni::M(BoardTypeNum) == 28 || $::moni::M(BoardTypeNum) == 92 \
           || $::moni::M(BoardTypeNum) == 33 || $::moni::M(BoardTypeNum) == 97 \
           || $::moni::M(BoardTypeNum) == 34 || $::moni::M(BoardTypeNum) == 98} {
        moni::mCardReset1Test
    } elseif {$::moni::M(BoardTypeNum) == 42 || $::moni::M(BoardTypeNum) == 43\
           || $::moni::M(BoardTypeNum) == 106 || $::moni::M(BoardTypeNum) == 107} {
        moni::sCardResetTest
    } else {
        if {$::moni::M(BoardTypeNum) != 24 && $::moni::M(BoardTypeNum) != 25 \
            && $::moni::M(BoardTypeNum) != 26 && $::moni::M(BoardTypeNum) != 27 \
            && $::moni::M(BoardTypeNum) != 29 && $::moni::M(BoardTypeNum) != 30 \
            && $::moni::M(BoardTypeNum) != 88 && $::moni::M(BoardTypeNum) != 89 \
            && $::moni::M(BoardTypeNum) != 90 && $::moni::M(BoardTypeNum) != 91 \
            && $::moni::M(BoardTypeNum) != 93 && $::moni::M(BoardTypeNum) != 94 \
            && $::moni::M(BoardTypeNum) != 36 && $::moni::M(BoardTypeNum) != 100 \
            && $::moni::M(BoardTypeNum) != 37 && $::moni::M(BoardTypeNum) != 101} {
            moni::keySwapTest
        } else {
            moni::mCardReset1Test
        }
    }
}

proc moni::sendledRunOffTest {} {
    variable M

    ::moni::send $::moni::Cfg(name) "singletest ledrunoff\r"
    ::moni::wait $::moni::M(waitLEDtime)
    .butCommonDlg.but1 configure -state normal
    .butCommonDlg.but2 configure -state normal
}

proc moni::ledMSOnTest {} {

    variable M
    set M(TestItem) "ledMSOnTest"
    ::moni::butComDlgCreate $moni::MSG(ledMSOnTest_title) $moni::MSG(ledMSOnTest_lab)

    ::moni::sendLedMSOnTest
}

proc moni::ledMSOnTestPassed {} {
    .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledMSOnTestPassed_lab)\n"
    .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    moni::savelog "$moni::MSG(ledMSOnTestPassed_lab)\n"
    moni::addtestok
    moni::ledMSOffTest
}

proc moni::ledMSOnTestNotPassed {} {
    set ::moni::M(ErrorFound) 1
    .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledMSOnTestNotPassed_lab)\n"
    .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    moni::saveerrlog "$moni::MSG(ledMSOnTestNotPassed_lab)\n"
    moni::savelog "$moni::MSG(ledMSOnTestNotPassed_lab)\n"
    moni::addtesterr
    if {$::moni::M(Manufactory) == "01"} {
        set ::moni::M(HandleString) 0
        set ::moni::M(ERROR_CODE) "T473"
        ::moni::get_result
        return
    }
    moni::ledMSOffTest
}

proc moni::sendLedMSOnTest {} {
    variable M

    ::moni::send $::moni::Cfg(name) "singletest ledmson\r"
    ::moni::wait $::moni::M(waitLEDtime)
    .butCommonDlg.but1 configure -state normal
    .butCommonDlg.but2 configure -state normal
}

proc moni::ledMSOffTest {} {
    variable M
    set M(TestItem) "ledMSOffTest"
    ::moni::butComDlgCreate $moni::MSG(ledMSOffTest_title) $moni::MSG(ledMSOffTest_lab)

    ::moni::sendLedMSOffTest
}

proc moni::ledMSOffTestPassed {} {
    .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledMSOffTestPassed_lab)\n"
    .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    moni::savelog "$moni::MSG(ledMSOffTestPassed_lab)\n"
    moni::addtestok
    if {$::moni::M(BoardTypeNum) == 28 || $::moni::M(BoardTypeNum) == 31 \
        || $::moni::M(BoardTypeNum) == 92} {
        moni::mCardReset1Test
    } elseif {$::moni::M(BoardTypeNum) == 16 || $::moni::M(BoardTypeNum) == 80 \
               || $::moni::M(BoardTypeNum) == 32 || $::moni::M(BoardTypeNum) == 96 \
               || $::moni::M(BoardTypeNum) == 39 || $::moni::M(BoardTypeNum) == 103} {
       moni::mCardReset1Test
    } else {
       moni::keySwapTest
    }
}

proc moni::ledMSOffTestNotPassed {} {
    set ::moni::M(ErrorFound) 1
    .testInfoDlg.labf2.t fastinsert end "$moni::MSG(ledMSOffTestNotPassed_lab)\n"
    .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
    moni::saveerrlog "$moni::MSG(ledMSOffTestNotPassed_lab)\n"
    moni::savelog "$moni::MSG(ledMSOffTestNotPassed_lab)\n"
    moni::addtesterr
    if {$::moni::M(Manufactory) == "01"} {
        set ::moni::M(HandleString) 0
        set ::moni::M(ERROR_CODE) "T473"
        ::moni::get_result
        return
    }
    if {$::moni::M(BoardTypeNum) == 28 || $::moni::M(BoardTypeNum) == 31 \
        || $::moni::M(BoardTypeNum) == 92} {
        moni::mCardReset1Test
    } elseif {$::moni::M(BoardTypeNum) == 16 || $::moni::M(BoardTypeNum) == 80 \
               || $::moni::M(BoardTypeNum) == 32 || $::moni::M(BoardTypeNum) == 96 \
               || $::moni::M(BoardTypeNum) == 39 || $::moni::M(BoardTypeNum) == 103} {
       moni::mCardReset1Test
    } else {
       moni::keySwapTest
    }
}

proc moni::sendLedMSOffTest {} {
    variable M

    ::moni::send $::moni::Cfg(name) "singletest ledmsoff\r"
    ::moni::wait $::moni::M(waitLEDtime)
    .butCommonDlg.but1 configure -state normal
    .butCommonDlg.but2 configure -state normal
}

proc moni::keySwapTest {} {
    catch {destroy .butCommonDlg}
    #BEGIN: Added by liuyce, 2010/3/18   PN:41760 NEW MI������swap��ť,��ת����һ�����
    if {$::moni::M(BoardTypeNum) == 38 || $::moni::M(BoardTypeNum) == 40 \
    	|| $::moni::M(BoardTypeNum) == 41 || $::moni::M(BoardTypeNum) == 104 \
	|| $::moni::M(BoardTypeNum) == 105} {
        ::moni::mCardReset1Test
        return
    }
    #END:   Added by liuyce, 2010/3/18      
    
    #BEGIN: Added by gujunqi, 2009/1/4
    catch {destroy .butCommonDlg}
    #END:   Added by gujunqi, 2009/1/4

    ::moni::comDlgCreate $moni::MSG(keySwapTest_title) $moni::MSG(keySwapTest_lab)

    ::moni::wait 5000
    #.keySwapTestDlg.but configure -state normal
    ::moni::afterswap
}

proc moni::afterswap {} {
    catch {destroy .commonDlg}
    moni::sCardResetTest
}

proc moni::sCardResetTest {} {
    variable M

    if {$::moni::M(BoardTypeNum) != 28 && $::moni::M(BoardTypeNum) != 31 \
        && $::moni::M(BoardTypeNum) != 92 \
        && $::moni::M(BoardTypeNum) != 16 && $::moni::M(BoardTypeNum) != 80 \
        && $::moni::M(BoardTypeNum) != 32 && $::moni::M(BoardTypeNum) != 96 \
        && $::moni::M(BoardTypeNum) != 33 && $::moni::M(BoardTypeNum) != 97 \
        && $::moni::M(BoardTypeNum) != 34 && $::moni::M(BoardTypeNum) != 98 \
        && $::moni::M(BoardTypeNum) != 36 && $::moni::M(BoardTypeNum) != 100 \
        && $::moni::M(BoardTypeNum) != 42 && $::moni::M(BoardTypeNum) != 43 \
        && $::moni::M(BoardTypeNum) != 37 && $::moni::M(BoardTypeNum) != 101 \
        && $::moni::M(BoardTypeNum) != 106 && $::moni::M(BoardTypeNum) != 107 \
        && $::moni::M(BoardTypeNum) != 128 && $::moni::M(BoardTypeNum) != 129 \
        && $::moni::M(BoardTypeNum) != 39 && $::moni::M(BoardTypeNum) != 103} {
        if {$::moni::M(KeySwapOK) == 1} {
            moni::addtestok
            ::moni::savelog "$moni::MSG(sCardResetTest_log1)\n"
            .testInfoDlg.labf2.t fastinsert end "$moni::MSG(sCardResetTest_log1)\n"
            .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
        } else {
            moni::addtesterr
            set ::moni::M(ErrorFound) 1
            ::moni::saveerrlog "$moni::MSG(sCardResetTest_log2)\n"
            ::moni::savelog "$moni::MSG(sCardResetTest_log2)\n"
            .testInfoDlg.labf2.t fastinsert end "$moni::MSG(sCardResetTest_log2)\n"
            .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
            if {$::moni::M(Manufactory) == "01"} {
                set ::moni::M(HandleString) 0
                set ::moni::M(ERROR_CODE) "T474"
                ::moni::get_result
                return
            }
        }
    }

    ::moni::reinit

    set ::moni::M(Reset1) 1

    catch {destroy .butCommonDlg}
    catch {destroy .commonDlg}

    ::moni::comDlgCreate $moni::MSG(sCardResetTest_title) $moni::MSG(sCardResetTest_lab)

    ::moni::wait_ram

    ::moni::wait 3000
    if {$::moni::M(GetRam) == 1} {
        ::moni::send $::moni::Cfg(name) "\x02"  ;#Ctrl+B ����boot.rom
        ::moni::send $::moni::Cfg(name) "\x02"
        ::moni::send $::moni::Cfg(name) "\x02"
        ::moni::send $::moni::Cfg(name) "\x0A"
    } else {
        return
    }

    #catch {$win.but1 configure -state normal}

#    ::moni::wait_boot   ;#ɾ�� intest.img
    ::moni::startSCardReset
    ::moni::mCardReset1Test
}

proc moni::startSCardReset {} {
    variable M

    #.sCardResetTestDlg.but1 configure -state disabled

    ::moni::wait 3000
    if {$::moni::M(ExitWaitRam) == 0} {
        if {$::moni::M(GetRam) == 1} {
            set ::moni::M(GetRam) 0
            ::moni::send $::moni::Cfg(name) "\x02"
            ::moni::wait 5000

            if {$::moni::M(Reset1) == 1} {
                set ::moni::M(Reset1) 2
                ::moni::addtestok
                ::moni::savelog "\n$moni::MSG(startSCardReset_lab)\n"
                .testInfoDlg.labf2.t fastinsert end "\n$moni::MSG(startSCardReset_lab)\n"
                .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
            }

            if {$::moni::M(TestType) == "P/T"} {
                if {$::moni::M(BoardTypeNum) == 5 || $::moni::M(BoardTypeNum) == 15 \
                    || $::moni::M(BoardTypeNum) == 16 || $::moni::M(BoardTypeNum) == 19 \
                    || $::moni::M(BoardTypeNum) == 20 || $::moni::M(BoardTypeNum) == 23 \
                    || $::moni::M(BoardTypeNum) == 24 || $::moni::M(BoardTypeNum) == 25 \
                    || $::moni::M(BoardTypeNum) == 26 || $::moni::M(BoardTypeNum) == 27 \
                    || $::moni::M(BoardTypeNum) == 28 || $::moni::M(BoardTypeNum) == 29 \
                    || $::moni::M(BoardTypeNum) == 30 || $::moni::M(BoardTypeNum) == 31 \
                    || $::moni::M(BoardTypeNum) == 38 || $::moni::M(BoardTypeNum) == 79 \
                    || $::moni::M(BoardTypeNum) == 80 || $::moni::M(BoardTypeNum) == 88 \
                    || $::moni::M(BoardTypeNum) == 89 || $::moni::M(BoardTypeNum) == 90 \
                    || $::moni::M(BoardTypeNum) == 91 || $::moni::M(BoardTypeNum) == 92 \
                    || $::moni::M(BoardTypeNum) == 93 || $::moni::M(BoardTypeNum) == 94 \
                    || $::moni::M(BoardTypeNum) == 0 || $::moni::M(BoardTypeNum) == 0 \
                    || $::moni::M(BoardTypeNum) == 0} {

                    #.testInfoDlg.labf2.t fastinsert end "���ڸ�ʽ��flash��������Ҫ��������ң���ȴ�......\n"
                    #.testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��

                    #::moni::wait 240000
                }
            }
            ::moni::send $::moni::Cfg(name) "\x0A"
        } else {
            set ::moni::M(ExitWaitRam) 1
        }
    }

    #.sCardResetTestDlg.but2 configure -state normal
}

proc moni::mCardReset1Test {} {
    variable M

    catch {destroy .butCommonDlg}
    catch {destroy .commonDlg}

	::moni::wait 5000

    if {$::moni::M(BoardTypeNum) != 24 && $::moni::M(BoardTypeNum) != 25 \
        && $::moni::M(BoardTypeNum) != 26 && $::moni::M(BoardTypeNum) != 27 \
        && $::moni::M(BoardTypeNum) != 29 && $::moni::M(BoardTypeNum) != 30 \
        && $::moni::M(BoardTypeNum) != 32 && $::moni::M(BoardTypeNum) != 33 \
        && $::moni::M(BoardTypeNum) != 34 && $::moni::M(BoardTypeNum) != 38 \
        && $::moni::M(BoardTypeNum) != 40 && $::moni::M(BoardTypeNum) != 41 \
        && $::moni::M(BoardTypeNum) != 104 && $::moni::M(BoardTypeNum) != 105 \
        && $::moni::M(BoardTypeNum) != 36 && $::moni::M(BoardTypeNum) != 37 \
        && $::moni::M(BoardTypeNum) != 42 && $::moni::M(BoardTypeNum) != 43 \
        && $::moni::M(BoardTypeNum) != 88 && $::moni::M(BoardTypeNum) != 89 \
        && $::moni::M(BoardTypeNum) != 90 && $::moni::M(BoardTypeNum) != 91 \
        && $::moni::M(BoardTypeNum) != 93 && $::moni::M(BoardTypeNum) != 94 \
        && $::moni::M(BoardTypeNum) != 96 && $::moni::M(BoardTypeNum) != 97 \
        && $::moni::M(BoardTypeNum) != 98 \
        && $::moni::M(BoardTypeNum) != 100 && $::moni::M(BoardTypeNum) != 101 \
        && $::moni::M(BoardTypeNum) != 106 && $::moni::M(BoardTypeNum) != 107 \
        && $::moni::M(BoardTypeNum) != 131 && $::moni::M(BoardTypeNum) != 132 \
        && $::moni::M(BoardTypeNum) != 134 && $::moni::M(BoardTypeNum) != 136 \
        && $::moni::M(BoardTypeNum) != 137 && $::moni::M(BoardTypeNum) != 138 \
		&& $::moni::M(BoardTypeNum) != 145 \
        && $::moni::M(BoardTypeNum) != 39 && $::moni::M(BoardTypeNum) != 103} {

        if {$::moni::M(BoardTypeNum) == 16 || $::moni::M(BoardTypeNum) == 80 \
            || $::moni::M(BoardTypeNum) == 28 || $::moni::M(BoardTypeNum) == 31 \
            || $::moni::M(BoardTypeNum) == 92 || $::moni::M(BoardTypeNum) == 128 || $::moni::M(BoardTypeNum) == 129} {

        } else {
						#����Ĵ������﷨���⣬����Ҳ������ΪʲôҪִ����δ��룬Ŀ����ʲô
            if {$::moni::M(Reset1) != 2} {
                ::moni::wait 2000
                set ::moni::M(ErrorFound) 1
                moni::addtesterr
                ::moni::savelog "{T475}\[ERROR\]$moni::MSG(mCardReset1Test_log)\n"
                ::moni::saveerrlog "{T475}\[ERROR\]$moni::MSG(mCardReset1Test_log)\n"
                .testInfoDlg.labf2.t fastinsert end "$moni::MSG(mCardReset1Test_log)\n"
                .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
                if {$::moni::M(Manufactory) == "01"} {
                    set ::moni::M(HandleString) 0
                    set ::moni::M(ERROR_CODE) "T475"
                    ::moni::get_result
                    return
                }
            }
        }
    }


    ::moni::reinit
    set ::moni::M(Reset2) 1
    ::moni::comDlgCreate $moni::MSG(mCardReset1Test_title) $moni::MSG(mCardReset1Test_lab)

    ::moni::wait_ram

    if {$::moni::M(BoardTypeNum) == 16 || $::moni::M(BoardTypeNum) == 80} {
        ::moni::wait 1000
    } else {
        ::moni::wait 3000
    }
    if {$::moni::M(GetRam) == 1} {
        ::moni::send $::moni::Cfg(name) "\x02"  ;#Ctrl+B ����boot.rom
        ::moni::send $::moni::Cfg(name) "\x02"
        ::moni::send $::moni::Cfg(name) "\x02"
        ::moni::send $::moni::Cfg(name) "\x0A"
    } else {
        return
    }
    # ֻ���߿���Ҫ��RSTIN2��
    if {$::moni::M(BoardTypeNum) == 2 || $::moni::M(BoardTypeNum) == 3 \
        || $::moni::M(BoardTypeNum) == 4 || $::moni::M(BoardTypeNum) == 17 \
        || $::moni::M(BoardTypeNum) == 19 || $::moni::M(BoardTypeNum) == 20 \
        || $::moni::M(BoardTypeNum) == 21 || $::moni::M(BoardTypeNum) == 23 \
        || $::moni::M(BoardTypeNum) == 24 || $::moni::M(BoardTypeNum) == 25 \
        || $::moni::M(BoardTypeNum) == 26 || $::moni::M(BoardTypeNum) == 27 \
        || $::moni::M(BoardTypeNum) == 29 || $::moni::M(BoardTypeNum) == 30 \
        || $::moni::M(BoardTypeNum) == 33 || $::moni::M(BoardTypeNum) == 34 \
        || $::moni::M(BoardTypeNum) == 36 || $::moni::M(BoardTypeNum) == 37 \
        || $::moni::M(BoardTypeNum) == 40 || $::moni::M(BoardTypeNum) == 41 \
        || $::moni::M(BoardTypeNum) == 42 || $::moni::M(BoardTypeNum) == 43 \
        || $::moni::M(BoardTypeNum) == 66 \
        || $::moni::M(BoardTypeNum) == 67 || $::moni::M(BoardTypeNum) == 68 \
        || $::moni::M(BoardTypeNum) == 81 || $::moni::M(BoardTypeNum) == 83 \
        || $::moni::M(BoardTypeNum) == 84 || $::moni::M(BoardTypeNum) == 85 \
        || $::moni::M(BoardTypeNum) == 87 || $::moni::M(BoardTypeNum) == 88 \
        || $::moni::M(BoardTypeNum) == 89 || $::moni::M(BoardTypeNum) == 90 \
        || $::moni::M(BoardTypeNum) == 91 || $::moni::M(BoardTypeNum) == 93 \
        || $::moni::M(BoardTypeNum) == 94 || $::moni::M(BoardTypeNum) == 97 \
        || $::moni::M(BoardTypeNum) == 98 \
        || $::moni::M(BoardTypeNum) == 100 || $::moni::M(BoardTypeNum) == 101 \
        || $::moni::M(BoardTypeNum) == 104 || $::moni::M(BoardTypeNum) == 105 \
        || $::moni::M(BoardTypeNum) == 106 || $::moni::M(BoardTypeNum) == 107 \
        || $::moni::M(BoardTypeNum) == 131 || $::moni::M(BoardTypeNum) == 132 \
        || $::moni::M(BoardTypeNum) == 134|| $::moni::M(BoardTypeNum) == 136 \
        || $::moni::M(BoardTypeNum) == 137|| $::moni::M(BoardTypeNum) == 138 \
		|| $::moni::M(BoardTypeNum) == 145} {

       # button $win.but1 -text "TEST" -font { ���� 12 normal } -width 10 \
       #     -command {moni::startMCardReset1} -fg brown -state disabled \
       #     -highlightthickness 0 -takefocus 0 -borderwidth 2
       # button $win.but2 -text "NEXT" -font { ���� 12 normal } -width 10 \
       #     -command {moni::mCardReset2Test} -fg brown -state disabled \
       #     -highlightthickness 0 -takefocus 0 -borderwidth 2
       ::moni::startMCardReset1
       ::moni::mCardReset2Test
    } else {
       # button $win.but1 -text "TEST" -font { ���� 12 normal } -width 10 \
       #     -command {moni::startMCardReset1} -fg brown -state disabled \
       #     -highlightthickness 0 -takefocus 0 -borderwidth 2
       # button $win.but2 -text "CLOSE" -font { ���� 12 normal } -width 10 \
       #     -command {moni::test_end} -fg brown -state disabled \
       #     -highlightthickness 0 -takefocus 0 -borderwidth 2
       ::moni::startMCardReset1
       ::moni::test_end
    }

   # catch {$win.but1 configure -state normal}
}

proc moni::startMCardReset1 {} {
    variable M
    #.mCardReset1TestDlg.but1 configure -state disabled

    if {$::moni::M(BoardTypeNum) == 16 || $::moni::M(BoardTypeNum) == 80} {

    } else {
        ::moni::wait 3000
    }
    if {$::moni::M(ExitWaitRam) == 0} {
        if {$::moni::M(GetRam) == 1} {
            set ::moni::M(GetRam) 0
            ::moni::send $::moni::Cfg(name) "\x02"

            if {$::moni::M(Reset2) == 1} {
                set ::moni::M(Reset1) 0
                set ::moni::M(Reset2) 2
                ::moni::addtestok
                ::moni::savelog "$moni::MSG(startMCardReset1_log)\n"
                .testInfoDlg.labf2.t fastinsert end "\n$moni::MSG(startMCardReset1_log)\n"
                .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
            }
            ::moni::send $::moni::Cfg(name) "\x0A"
        } else {
            set ::moni::M(ExitWaitRam) 1
        }
    }
    ::moni::wait 5000
    #.mCardReset1TestDlg.but2 configure -state normal
}

proc moni::mCardReset2Test {} {
    variable M
    catch {destroy .commonDlg}

    if {$::moni::M(Reset2) != 2} {
        ::moni::wait 2000
        set ::moni::M(ErrorFound) 1
        moni::addtesterr
        ::moni::savelog "{T476}\[ERROR\]$moni::MSG(mCardReset2Test_log)\n"
        ::moni::saveerrlog "{T476}\[ERROR\]$moni::MSG(mCardReset2Test_log)\n"
        .testInfoDlg.labf2.t fastinsert end "$moni::MSG(mCardReset2Test_log)\n"
        .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
        if {$::moni::M(Manufactory) == "01"} {
            set ::moni::M(HandleString) 0
            set ::moni::M(ERROR_CODE) "T476"
            ::moni::get_result
            return
        }
    }

    ::moni::reinit
    set ::moni::M(Reset3) 1
    
    ::moni::comDlgCreate $moni::MSG(mCardReset2Test_title) $moni::MSG(mCardReset2Test_lab)

#    ::moni::savelog "wait_ram in mCardReset2TestDlg\n"

    ::moni::wait_ram

    if {$::moni::M(GetRam) == 1} {
        ::moni::send $::moni::Cfg(name) "\x02"  ;#Ctrl+B ����boot.rom
        ::moni::send $::moni::Cfg(name) "\x02"
        ::moni::send $::moni::Cfg(name) "\x02"
        ::moni::send $::moni::Cfg(name) "\x0A"
    } else {
        return
    }
    ::moni::wait 3000
    #catch {$win.but1 configure -state normal}
    ::moni::startMCardReset2
    ::moni::test_end
}

proc moni::startMCardReset2 {} {
    variable M
    #.mCardReset2TestDlg.but1 configure -state disabled

    ::moni::wait 3000
    if {$::moni::M(ExitWaitRam) == 0} {
        if {$::moni::M(GetRam) == 1} {
            set ::moni::M(GetRam) 0
            #if {$::moni::M(BoardTypeNum) == 20 || $::moni::M(BoardTypeNum) == 19} {
            #    ::moni::send $::moni::Cfg(name) "\x0D"
            #} else {
                ::moni::send $::moni::Cfg(name) "\x02"
            #}

            if {$::moni::M(Reset3) == 1} {
                set ::moni::M(Reset1) 0
                set ::moni::M(Reset2) 0
                set ::moni::M(Reset3) 2
                ::moni::addtestok
                ::moni::savelog "\n$moni::MSG(startMCardReset2_log)\n"
                .testInfoDlg.labf2.t fastinsert end "\n$moni::MSG(startMCardReset2_log)\n"
                .testInfoDlg.labf2.t yview 10000        ;#ctext��ʾ��10000��
            }
            ::moni::send $::moni::Cfg(name) "\x0A"
        } else {
            set ::moni::M(ExitWaitRam) 1
        }
    }
    ::moni::wait 5000
    #.mCardReset2TestDlg.but2 configure -state normal
}

proc moni::finish_test {} {
    catch {destroy .testEndDlg}
    catch {destroy .testInfoDlg}
    wm deiconify .      ;#����
    ::moni::savelog "Total tested:$::moni::M(tested), OK tested:$::moni::M(passed), ERROR tested:$::moni::M(failed)\n"
    ::moni::get_time
    ::moni::savelog "END TIME:$::moni::M(Time)\n"
    if {$::moni::M(ErrorFound) == 1} {
        ::moni::saveerrlog "END TIME:$::moni::M(Time)\n"
    } else {
        #set filename $::moni::M(SN).err.txt
        #file mkdir ./log
        #set f [open ./log/$filename "a+"]
        #puts $f $str
        #close $f
        #tk_messageBox -message "delete file $::moni::M(SN).err.txt"
        file delete -force ./log/$::moni::M(SN).err.txt
    }

    ::moni::new_test
    #exit
}

proc moni::finish_test_no_new_test {} {
    catch {destroy .testEndDlg}
    catch {destroy .testInfoDlg}
    wm deiconify .      ;#����
    ::moni::savelog "Total tested:$::moni::M(tested), OK tested:$::moni::M(passed), ERROR tested:$::moni::M(failed)\n"
    ::moni::get_time
    ::moni::savelog "END TIME:$::moni::M(Time)\n"
    if {$::moni::M(ErrorFound) == 1} {
        ::moni::saveerrlog "END TIME:$::moni::M(Time)\n"
    } else {
        file delete -force ./log/$::moni::M(SN).err.txt
    }

    exit
}

proc ::moni::rs232_put { name str } {
    variable M
    variable ConChan
    variable Cfg

    if { ! $M($name.Open) } {
        bell
        return
    }
    if { $M(Term.Echo) } {
        ::moni::tty_in $name $str
    }

    if {[info exist ConChan($name)]} {
      puts -nonewline $ConChan($name) $str
    } else {
        set Cfg(name) $name
      set Cfg(Port) $M($name.Port)
      set Cfg(Baud) $M($name.Baud)
      set Cfg(parity) $M($name.Parity)
      set Cfg(DataBits) $M($name.DataBits)
      set Cfg(StopBits) $M($name.StopBits)
      set Cfg(SysBuffer) $M($name.sysbuffer)
      set Cfg(Pollinterval) $M($name.pollinterval)
    ::moni::config_open
    }
}

proc ::moni::term_cutLines { txt maxLines } {
    if { ($maxLines > 0) } {
        set lines [lindex [split [$txt index end] . ] 0]
        if { $lines > $maxLines } {
            $txt delete 1.0 [expr {1 + $lines - $maxLines + $maxLines/10} ].0
        }
    }
}

proc ::moni::term_clear {} {
    variable M
    set name [$::moni::M(Win.Notebook) raise]

    if {[info exist M(Win.TTY.$name)]} { ;#add by ligc 2004-10-21 protected code
      $M(Win.TTY.$name) delete 1.0 end
    }

    set M(Term.Count) 0
    set M(Term.TotalCount) 0
}

proc ::moni::tty_out { title key } {
    ::moni::rs232_put $title $key
    return 1
}

proc ::moni::tty_key { win key sym } {

    regexp "nb.f(.*?).sw" $win match title
    if {![info exist title]} {
      puts "can not find the title in tty_key, win = $win"
      return
    }

    if {$sym == "Up"} {
      set key \x10
      set sym "p"
    }

    if {$sym == "Down"} {
      set key \x0E
      set sym "n"
    }

    if {$sym == "Prior"} {
      $::moni::M(Win.TTY.$title) yview scroll -1 page
      return -code break
    }

    if {$sym == "Next"} {
      $::moni::M(Win.TTY.$title) yview scroll 1 page
      return -code break
    }

    switch -regexp -- $key {
        [\x03] {
          if {($sym == "c") || ($sym == "C")} {
            if {[::moni::selection_copy]} {
          return -code break
        }
          }
        }
        [\x16] {
          if {($sym == "v") || ($sym == "V")} {
            ::moni::selection_paste
            return -code break
          }
        }

       [\x01] {
          if {($sym == "a") || ($sym == "A")} {
            ::moni::select_all
            return -code break
          }
       }

       [\x0D] {
          $::moni::M(Win.TTY.$title) tag remove sel 1.0 [expr [lindex [split [$::moni::M(Win.TTY.$title) index end] . ] 0] + 1].0
        }
    }

    if { [moni::tty_out $title $key] } {
        $win see end
        return -code break
    } else {
        return -code continue
    }
}

proc ::moni::tty_in {name str } {
    variable M
    set i 0
    while {1} {
        set pos [string first "\r\n" $str] 
        format "%#d" $pos
        if { $pos >= 0 } {
            set str [string replace $str $pos [expr {$pos+1}] "\n"] 
        } else {
            break
        }
    }


    if {$::moni::M(StartWaitRam) == 1} {
        foreach ch [split $str {}] {
            incr i 1
            switch -regexp -- $ch {

            [\x01-\x06\x0B\x0C\x0E-\x1F]
                    {
                    }
            \x07    {
                        bell
                    }
            \x08    {
                if { [$M(Win.TTY.$name) compare end != 1.0] } {
                  $M(Win.TTY.$name) delete [lindex [split [$::moni::M(Win.TTY.$name) index end] .] 0].[expr [lindex [split [$::moni::M(Win.TTY.$name) index end] . ] 1] - 1]
                }
                    }
            \x0D    {

                  ;#Houston�忨��Ҫ����һ������

                      ;#tk_messageBox -message "M(StartWaitRam) == 1"
                      $M(Win.TTY.$name) mark set insert end
                      $M(Win.TTY.$name) mark set end "insert linestart"

                    }
            \x0A    {
                $M(Win.TTY.$name) insert end $ch
                ::moni::term_cutLines $M(Win.TTY.$name) $M(Term.MaxLines)
                    }
            default {
                    if {[$M(Win.TTY.$name) get [$M(Win.TTY.$name) index end]] != "\n" } {
                  $M(Win.TTY.$name) delete end
                }
                $M(Win.TTY.$name) insert end $ch
                    }
            }
        }
    } else {

        foreach ch [split $str {}] {
            incr i 1
            switch -regexp -- $ch {

            [\x01-\x06\x0B\x0C\x0E-\x1F]
                    {
                    }
            \x07    {
                        bell
                    }
            \x08    {
                if { [$M(Win.TTY.$name) compare end != 1.0] } {
                  $M(Win.TTY.$name) delete [lindex [split [$::moni::M(Win.TTY.$name) index end] .] 0].[expr [lindex [split [$::moni::M(Win.TTY.$name) index end] . ] 1] - 1]
                }
                    }
            \x0D    {
                      $M(Win.TTY.$name) mark set insert end
                      $M(Win.TTY.$name) mark set end "insert linestart"
                    }
            \x0A    {
                $M(Win.TTY.$name) insert end $ch
                ::moni::term_cutLines $M(Win.TTY.$name) $M(Term.MaxLines)
                    }
            default {
                    if {[$M(Win.TTY.$name) get [$M(Win.TTY.$name) index end]] != "\n" } {
                  $M(Win.TTY.$name) delete end
                }
                $M(Win.TTY.$name) insert end $ch
                    }
            }
        }
    }

    if { ! $M(Term.Hold) } {
     $M(Win.TTY.$name) see end
     $M(Win.TTY.$name) mark set insert end
    }
}

proc ::moni::raw_key { win key sym } {
    variable M
    if { [regexp {[0-9A-Fa-f]} $key] } {
        if { [string length $M(Win.Raw.Input)] == 2 } {
            set M(Win.Raw.Input) {}
        }
        append M(Win.Raw.Input) $key
        if { [string length $M(Win.Raw.Input)] == 2 } {
            set ch [binary format H2 $M(Win.Raw.Input)]
            ::moni::rs232_put $ch
            $M(Win.Raw.Input.W) configure -bg white
        } else {
            $M(Win.Raw.Input.W) configure -bg yellow
        }
    } else {
        bell
    }
    return -code break
}

proc ::moni::raw_insert_count {} {
}

proc ::moni::raw_in { str } {
    variable M

    foreach ch [split $str {}] {
        binary scan $ch c1 value
        set value [expr ($value + 0x100) % 0x100]
        regsub -all "\[\x00-\x1F\\x7F-\xFF]" $ch "." ch

        if { [incr M(Term.Count)] % 16 == 0 } {
            ::moni::raw_insert_count
        }
    }
}

proc ::moni::selection_copy {} {

    set name [$::moni::M(Win.Notebook) raise]
    if {[$::moni::M(Win.TTY.$name) tag ranges sel] != ""} {
      set txt [$::moni::M(Win.TTY.$name) get sel.first sel.last]
    } else {
      set txt ""
    }
    if { [string length $txt] } {
        clipboard clear
        clipboard append $txt
        return 1
    } else {
      return 0
    }
}

proc ::moni::selection_paste {} {
    if { [catch {selection get -selection CLIPBOARD} txt] } {
        set txt ""
    }
    if { [string length $txt] } {
      set name [$::moni::M(Win.Notebook) raise] ;
      if {$name != ""} {
          ::moni::rs232_put $name $txt
        }
    }
}

proc ::moni::selection_copy_and_paste {} {
  ::moni::selection_copy
  ::moni::selection_paste
}

proc ::moni::select_all {} {
    set name [$::moni::M(Win.Notebook) raise]
    if {$name != ""} {
       $::moni::M(Win.TTY.$name) tag add sel 1.0 end
    }
}

proc ::moni::select_all_and_copy {} {
  ::moni::select_all
  ::moni::selection_copy
}

proc ::moni::tty_switch {} {
  set idx [$::moni::M(Win.Notebook) index [$::moni::M(Win.Notebook) raise]]
  set nxt [$::moni::M(Win.Notebook) page [expr $idx + 1]]
  if {$nxt == ""} {
    $::moni::M(Win.Notebook) raise [$::moni::M(Win.Notebook) page 0]
  } else {
    $::moni::M(Win.Notebook) raise $nxt
  }
}

proc ::moni::edit_buffer {} {
    set name [$::moni::M(Win.Notebook) raise]
    if {$name != ""} {
        set cbuffer [$::moni::M(Win.TTY.$name) get 1.0 end]
        set dir [file dirname [info script]]
        set tempfilename [file join $dir moni.buffer.temp.txt]
        set tempfile [open $tempfilename w]
        puts $tempfile $cbuffer
        close $tempfile

        exec notepad $tempfilename &
    }
}

proc moni::logAddCom { str } {
	set filename $::moni::M(SN).com.txt
    file mkdir ./log
    set f [open ./log/$filename "a+"]
    flush $f
    puts -nonewline $f "$str"
    close $f	
}