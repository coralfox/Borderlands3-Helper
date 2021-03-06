﻿screenWidth=1920
screenHeight=1080

/*
- Windows 10 with high DPI display mast get the value of 'Change the size of text, apps, and other items', you can find it in above:
    1. Right-click anywhere on the Desktop
    1. Select __Display Settings__ from the menu, You will see it
    1. Edit Initialization.ahk to change the value after TAOsize= to the corresponding number (without the % sign)
    
    拥有高 DPI 显示设备的 Windows 10 系统需要获得 “更改文本、应用和其他项目的大小” 的值，你可以在这里找到它：
    1. 在桌面空白地方点击桌面
    1. 从菜单中选择"显示设置“，你会在界面中看到这个选项
    1. 编辑 Initialization.ahk，将 TAOsize= 后面的值改为对应数字（不带 % 号）
    */
    TAOsize=120
    
    ; Do not change the following
    ; 不要改变以下内容
    ; Chat word limit 聊天字数限制
    chatboxMaxLength=100
    
    
    #NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
    SetBatchLines -1
    ListLines Off
    SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
    SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
    #SingleInstance, force
    
    Gosub, SetDefaultState
    
    
    ; #Include, Initialization.ahk
    ResolutionAdaptation("screenWidth","screenHeight")
    
    IniRead,ActiveChat,settings.ini,热键,聊天功能,1 
    IniRead,ActiveBackup,settings.ini,备份,备份功能,1  
    
    Menu, tray, NoStandard
    Menu, tray, add,重楼夜雨制作,About
    Menu, tray, add, 重置 | Reload, ReloadScrit
    Menu, tray, add, 暂停 | Pause, PauseScrit
    
    Menu, tray, add
    Menu, tray, add, 备份 | Backup, AutoBackup
    Menu, tray, add, 热键 | HotKey, SetHotKey
    Menu, tray, add
    
    Menu, tray, add, 帮助 | Help, Help
    Menu, tray, add, 更新 | Ver %ver%, UpdateScrit
    Menu, tray, add, 退出 | Exit, ExitScrit
    
    
    if(ActiveBackup=1)
        Menu, tray, Check, 备份 | Backup
    Else
        Menu, tray, UnCheck, 备份 | Backup
    
    if(ActiveChat=1)
        Menu, tray, Check, 热键 | HotKey
    Else
        Menu, tray, UnCheck, 热键 | HotKey
    
    Gui, +ToolWindow -Caption +AlwaysOnTop -DPIScale
    Gui, Color, %bGColor%
    gui, font, s12 cffffff q5, SimSun
    gui, font, s11 cffffff q5, Microsoft YaHei UI
    Gui, Color, ,000000
    Gui, Add, Edit, x0 y0 w%chatboxW% h25 vchatBox Limit140
    gui, font
    
    
    
    winwait,ahk_exe Borderlands3.exe
    gosub,readini  ;读取配置
    if (ActiveChat=1)
    {
        gosub,checkkey  
        SetTimer, battleModeCheck, 200  ;战斗模式检测
    }
    
    if (ActiveBackup=1)
    {
        GOSUB,backupInt
        ;gosub,backUPCheck
        timecheck:=% 60000 * TimeChoice
        SetTimer,backUPCheck,%timecheck%
    }
    
    
    WinWaitClose, ahk_exe Borderlands3.exe
    gosub,ReloadScrit  ;退出后重启脚本
    ;SetTimer,backUPCheck,TimeChoice*60*1000   ;备份检测
    
Return

backUPCheck:
    FileList := ""
    check_array:= []
    Loop, Files,%SaveDir%\*.sav,F  
        FileList .= A_LoopFileTimeModified "`t"A_LoopFileName "`n"
    Loop, Parse, FileList,`n
    {
        if (A_LoopField = "")  ; 忽略列表末尾的空项.
            Continue
        
        check_array[A_Index] := StrSplit(A_LoopField ,A_TAB,A_Space|A_Tab|"")       
    }
    
    
    for i in save_array
    {
        If (IfDetect=1)  ;比对文件
        { 
            for k in check_array
            {
                If (check_Array[k,2]=save_array[i,2] && check_Array[k,1]!=save_array[i,1])  ;名字相同,时间不同
                {
                    save_array[i,3]:=1 
                    save_array[i,1]:=check_Array[k,1]  ;修改时间更新
                    
                    createFlag:=1
                }
            }
            
        }  ;如果检测
        Else
        {
            save_array[i,3]:=1   ;设置标标记,保存
            createFlag:=1
        }
    }
    
    dir:=getDIR()
    
    for i in save_array
    {
        if(save_array[i,3]=1 )
            setSave(save_array[i,2],dir)
        save_array[i,3]:=0
    }
    
    
Return

backupInt:
    FileList := ""
    save_array:= []
    Loop, Files,%SaveDir%\*.sav,F  
        FileList .= A_LoopFileTimeModified "`t"A_LoopFileName "`n"
    Loop, Parse, FileList,`n
    {
        if (A_LoopField = "")  ; 忽略列表末尾的空项.
            Continue
        
        save_array[A_Index] := StrSplit(A_LoopField ,A_TAB,A_Space|A_Tab|"") 
        save_array[A_Index,3]:=0
    }
return

setSave(sfile,sdir)
{
    Global savedir
    FileCopy,% SaveDir . "\" . sfile,% SaveDir . "\" . sdir
return  
}

getDir()
{
    Global SaveDir
    Global PersChoice
    global createFlag
    
    FileList := ""
    dir_array:= []
    Loop, Files,%SaveDir%\*.*,D
        FileList .= A_LoopFileName "`n"
    Sort, FileList
    Loop, Parse, FileList,`n
    {
        if (A_LoopField = "")  ; 忽略列表末尾的空项.
            Continue
        
        dir_array[A_Index] := A_LoopField
        
    }
    
    if(dir_array.Length()>=%PersChoice%)  ;达到备份上限
    {
        for i in dir_array
        {
            if A_Index <= % dir_array.Length() - PersChoice + 1
                FileRemoveDir, % SaveDir . "\" . dir_array[A_Index],1
            Else
                break
            
        } 
    }
    if(createFlag=1)
   ; if(createFlag=1) and WinActive("ahk_exe  Borderlands3.exe")
    {    
        FormatTime, TimeString,,yyyy'年'MM'月'dd'日'HH'时'mm'分'
        FileCreateDir,% SaveDir . "\" . TimeString
        createFlag:=0
    }
     
return TimeString
}

battleModeCheck:
    If WinActive("ahk_exe Borderlands3.exe")
    {
        DllCall("SendMessage", "UInt", (WinActive("ahk_exe Borderlands3.exe")), "UInt", "80", "UInt", "1", "UInt", (DllCall("LoadKeyboardLayout", "Str", "00000804", "UInt", "257")))
    }
    
    If WinExist("ChatBoxTitle") && !WinActive("ChatBoxTitle")
    {
        WinActive("ChatBoxTitle")
        Gui Cancel
    }
    
    If !WinActive("ahk_exe Borderlands3.exe") && (rDown=1)
    {
        Send, {RButton Up}
        rDown=0
    }
Return

readini:
    ;读取热键配置
    IniRead,ActiveChat,settings.ini,热键,聊天功能,1   ;读取配置文件,启动聊天
    IniRead,startkey,settings.ini,热键,开启聊天,y   ;读取配置文件,启动聊天
    ;IniRead,sendkey,settings.ini,热键,发送信息,Up  ;读取配置文件,发送信息
    IniRead,gamechatkey,settings.ini,热键,游戏中开启聊天,y   ;读取配置文件,游戏中启动聊天
    
    IniRead,chooses1,settings.ini,热键,chooses1,1   ;读取配置文件
    IniRead,chooses2,settings.ini,热键,chooses2   ;读取配置文件
    IniRead,chooseg1,settings.ini,热键,chooseg1,1   ;读取配置文件
    IniRead,chooseg2,settings.ini,热键,chooseg2   ;读取配置文件
    ;读取备份配置
    IniRead,ActiveBackup,settings.ini,备份,备份功能,1  
    IniRead,TimeChoice,settings.ini,备份,备份间隔时间,10 
    IniRead,PersChoice,settings.ini,备份,备份上限,10
    IniRead,IfDetect,settings.ini,备份,是否检测变动,1
    IniRead,BackUpCode,settings.ini,备份,备份指令,备份
    ;IniRead,IfSaveOrder,settings.ini,备份,存档是否带序号,1
    ;IniRead,IfSaveTime,settings.ini,备份,存档是否带时间,1
    
Return

checkkey:
    hotkey,IfWinActive, ahk_exe Borderlands3.exe
        if (ActiveChat=1)  
        hotkey,%startkey%,startchat,On
    Else
        hotkey,%startkey%,startchat,Off
    Hotkey, IfWinActive
        return
    
    #IfWinActive, ahk_exe Borderlands3.exe
        startchat:
            inputState:=inputState=1?0:1
            inBattle:=0
            
            If (inputState=1) && (consoleMode=0)
            {
                Gui, Show, w%chatBoxW% h25 x%chatBoxX% y%chatBoxY%, %title%
                WinSet, TransColor, %bGColor% %transparency%, %title%
            }
        Return
        
        Esc::
            normalButton("Esc")
            inputState:=0
            consoleMode:=0
            gameUI:=0
            heroUI:=0
            mapsUI:=0
            itemUI:=0
            inBattle:=0
        Return
        
        #IfWinActive, ChatBoxTitle
            
        Enter::
            Gui Submit
            ;Gui, Show, Hide
            WinWaitActive, ahk_exe Borderlands3.exe
            
            If (chatBox!="")
            {
                ReplaceText("chatBox")
                chatBoxLength:= StrLen(chatBox)
                chatBoxCutOff:=chatBoxLength/chatboxMaxLength
                If (chatBoxCutOff>1)
                {
                    chatBoxCutOff:= Ceil(chatBoxCutOff)
                    
                    chatBoxStartPos=1
                    Loop, %chatBoxCutOff%
                    {
                        chatBox%A_Index%:= SubStr(chatBox, chatBoxStartPos, chatboxMaxLength)
                        chatBoxStartPos:=chatBoxStartPos+chatboxMaxLength
                        chatText=% chatBox%A_Index%
                        WinWaitActive, ahk_exe Borderlands3.exe
                        Send, %gamechatkey%
                        Sleep, 50
                        Send, {Text}%chatText%
                        Sleep, 50
                        Send, {Enter}
                        If (A_Index<chatBoxCutOff)
                        {
                            Sleep, 50
                            Send, %sendkey%
                        }
                    }
                }
                Else
                {   
                    Send,%gamechatkey%
                    Sleep, 50
                    Send, {Text}%chatBox%
                    Sleep, 50
                    Send, {Enter}
                }
                GuiControl, Text, chatBox,
            }
            Else
                
            GuiControl, Text, chatBox,
            inputState:=0
        Return
        
        Esc::
            Gui Cancel
            WinWaitActive, ahk_exe Borderlands3.exe
            
            ;Send, {Enter}
            ;GuiControl, Text, chatBox,
            inputState:=0
        Return
    #IfWinActive
    
    ReloadScrit:
        Reload
    Return
    
    PauseScrit:
        Pause, Toggle, 1
    Return
    
    UpdateScrit:
        Run, https://github.com/coralfox/Borderlands3-Helper/releases
    Return
    
    Help:
        Run, https://github.com/coralfox/Borderlands3-Helper
    Return
    
    AutoBackup:
        Gosub readini
        gui auto:+ToolWindow
        Gui auto:Add, CheckBox,vActiveBackup Checked%ActiveBackup% x10 y10 , 备份功能            ;可编辑
        Gui auto:Add, GroupBox, x10 y32 w220 h141, 定时备份
        Gui auto:Add, ComboBox,vTimeChoice x120 y50 w52 ,%TimeChoice%||1|5|10|15|30|60   ;可编辑,默认10
        Gui auto:Add, Text, x20 y50 w94 h23 +0x200, 备份间隔时间
        Gui auto:Add, Text, x180 y50 w35 h23 +0x200, 分钟
        Gui auto:Add, CheckBox,vIfDetect Checked%IfDetect% x22 y130 w159 h23, 存档有变动才备份    ;可编辑
        Gui auto:Add, Text, x21 y90 w98 h23 +0x200, 保留存档份数
        Gui auto:Add, ComboBox,vPersChoice x120 y90 w52,%PersChoice%||1|5|10|15|30|60    ;可编辑,默认10
        Gui auto:Add, Text, x180 y90 w35 h23 +0x200, 份数
        Gui auto:Add, GroupBox, x10 y175 w220 h71, 指令备份(未开发)
        Gui auto:Add, Text, x20 y190 w68 h23 +0x200, 备份指令
        Gui auto:Add, Edit, vBackUpCode x80 y190 w71 h21, %BackUpCode%                         ;可编辑
        Gui auto:Add, Text, x20 y220  h23 +0x200, 指令后带文字可以作为存档名
        
        ;GuiControl,auto:Disable,指令备份
        GuiControl,auto:Disable,备份指令
        GuiControl,auto:Disable,BackUpCode
        GuiControl,auto:Disable,指令后带文字可以作为存档名
        ;Gui auto:Add, CheckBox,vIfSaveOrder Checked%IfSaveOrder% x10 y230 h23, 备份名有序号             ;可编辑
        ; Gui auto:Add, CheckBox,vIfSaveTime Checked%IfSaveTime% x123 y230 w124 h23, 备份名有时间          ;可编辑
        Gui auto:Add, Button, x20 y265 w75 h23, 确定               ;可编辑
        Gui auto:Add, Button, x105 y265 w120 h23, 打开存档文件夹        ;可编辑
        
        Gui auto:Show, w250 h300, 自动备份
    return
    
    autobutton确定:
        Gui, auto:Submit  ; 保存用户的输入到每个控件的关联变量中.
        iniwrite,%ActiveBackup%,settings.ini,备份,备份功能   ;保存配置文件
        iniwrite,%TimeChoice%,settings.ini,备份,备份间隔时间   ;保存配置文件
        iniwrite,%PersChoice%,settings.ini,备份,备份上限   ;保存配置文件
        iniwrite,%IfDetect%,settings.ini,备份,是否检测变动   ;保存配置文件
        iniwrite,%BackUpCode%,settings.ini,备份,备份指令   ;保存配置文件
        ;iniwrite,%IfSaveOrder%,settings.ini,备份,存档是否带序号   ;保存配置文件
        ;iniwrite,%IfSaveTime%,settings.ini,备份,存档是否带时间   ;保存配置文件
        ;gosub,readini
        gui ,auto:Destroy
        gosub,ReloadScrit
    Return
    
    autobutton打开存档文件夹:
        run,% SaveDir
        
    Return
    
    SetHotKey:
        Gosub readini
        gui key:+ToolWindow
        Gui key:Add, CheckBox,vActiveChat Checked%ActiveChat% x10 y10 , 聊天功能            ;可编辑
        Gui key:Add, Text, x10 y30 w75 h23 +0x200, 开启聊天
        Gui key:Add, Text, x10 y70 w75 h23 +0x200, 游戏内聊天
        Gui,key:Add, Radio,x75 y45 Group vchooses1 gr1  checked%chooses1%   ;左边第一个
        Gui,key:Add, Radio,x170 y45 vchooses2 gr2 checked%chooses2%   ;右边第一个
        Gui,key:Add, Radio, x75 y75 Group vchooseg1 gr3 checked%chooseg1%
        Gui,key:Add, Radio, x170 y75 vchooseg2 gr4 checked%chooseg2%
        Gui key:Add, Hotkey, x100 y40 w65   vstartkey,%startkey%
        Gui key:Add, Hotkey, x100 y70 w65  vgamechatkey,%gamechatkey%
        Gui key:Add, DDL,x195 y40 w50 vskeychoice ,Enter|Space|LWin
        Gui key:Add, DDL,x195 y70 w50  vgkeychoice ,Enter|Space|LWin
        Gui key:Add, Button, x80 y110 w75 h23, 确定
        
        Gui,key:Show, w300 h140, 设置热键
        
        GuiControl,key:Enable%chooses1%,startkey
        GuiControl,key:Enable%chooses2%,skeychoice
        GuiControl,key:Enable%chooseg1%,gamechatkey
        GuiControl,key:Enable%chooseg2%,gkeychoice
        
        GuiControl, key:ChooseString, skeychoice, %startkey%
        GuiControl, key:ChooseString, gkeychoice, %gamechatkey%
        
    return
    
    r1:
        GuiControl,key:Enable,startkey
        GuiControl,key:Disable,skeychoice
    return
    
    r2:
        GuiControl,key:Disable,startkey
        GuiControl,key:Enable,skeychoice
    return
    
    r3:
        GuiControl,key:Enable,gamechatkey
        GuiControl,key:Disable,gkeychoice
    return
    
    r4:
        GuiControl,key:Disable,gamechatkey
        GuiControl,key:Enable,gkeychoice
    return
    
    keyButton确定:
        Gui, key:Submit  ; 保存用户的输入到每个控件的关联变量中.
        iniwrite,%ActiveChat%,settings.ini,热键,聊天功能   ;保存配置文件,单选配置
        iniwrite,%chooses1%,settings.ini,热键,chooses1   ;保存配置文件,单选配置
        iniwrite,%chooses2%,settings.ini,热键,chooses2   ;保存配置文件,单选配置
        iniwrite,%chooseg1%,settings.ini,热键,chooseg1   ;保存配置文件,单选配置
        iniwrite,%chooseg2%,settings.ini,热键,chooseg2   ;保存配置文件,单选配置
        
        if(chooses1)
            iniwrite,%startkey%,settings.ini,热键,开启聊天   ;保存配置文件,启动聊天
        
        if(chooses2)
            iniwrite,%skeychoice%,settings.ini,热键,开启聊天   ;保存配置文件,启动聊天
        
        if(chooseg1)
            iniwrite,%gamechatkey%,settings.ini,热键,游戏中开启聊天   ;保存配置文件,游戏中启动聊天
        
        if(chooseg2)
            iniwrite,%gkeychoice%,settings.ini,热键,游戏中开启聊天   ;保存配置文件,游戏中启动聊天
        gui ,key:Destroy
        ;gosub,ReloadScrit
        gosub,readini
        gosub,checkkey
        
        if (ActiveChat=1)
            Menu, tray, Check, 热键 | HotKey
        ELSE 
            Menu, tray, UnCheck, 热键 | HotKey
        
    Return
    
    ExitScrit:
        ExitApp
    Return
    
    normalButton(key)
    {
        global
        inBattle:=0
        If (item!=1)
            preWeapon:=weapon
        ;weapon:=0
        send, {RButton Up}
        rDown:=0
        Send, {%key% Down}
        KeyWait, %key%
        Send, {%key% Up}
    }
    
    ReplaceText(vName)
    {
        %vName%:=StrReplace(%vName%, "/time" , A_Hour  . "点" . A_Min . "分")
        ;%vName%:=StrReplace(%vName%, "备份" , "`,")
        
    }
    
    ResolutionAdaptation(width,height)
    {
        global
        
        dpiRatio:=A_ScreenDPI/96
        chatBoxX:=A_ScreenWidth*0.80
        chatBoxY:=A_ScreenHeight*0.805
        chatBoxW:=A_ScreenWidth/dpiRatio*0.2
        
        
        If (width=1920)
            chatBoxX:=70*dpiRatio*100/TAOsize
        
        If (height=1080)
        {
            chatBoxW:=480/TAOsize*100
            chatBoxY:=850*dpiRatio*100/TAOsize
        }
        
        If (width=1366) && (height=768)
        {
            chatBoxW=340
            chatBoxX=50
            chatBoxY=600
        }
        If (width=1360) && (height=768)
        {
            chatBoxW=340
            chatBoxX=50
            chatBoxY=600
        }
        ;ToolTip,%width% %height% %chatBoxW% %chatBoxX% %chatBoxY%
    }
    
    SetDefaultState:
        ver:=1.0.0
        createFlag:=0
        inBattle:=0
        item:=0
        inputState:=0
        gameUI:=0
        voteUI:=0
        consoleMode:=0
        bGColor:="FF00FF"
        transparency:=200
        title:="ChatBoxTitle"
        
        
        FileList := ""
        Loop, Files,%A_MyDocuments%\My Games\Borderlands 3\Saved\SaveGames\*.*,D  
            FileList .= A_LoopFileTimeModified "`t"A_LoopFileName "`n"
        Sort, FileList  ; 根据日期排序.
        Loop, Parse, FileList,`n
        {
            if (A_LoopField != "")  ; 忽略列表末尾的空项.
            {
                word_array := StrSplit(A_LoopField ,A_TAB,A_Space|A_Tab|"")
                SaveDir:= A_MyDocuments  .  "\My Games\Borderlands 3\Saved\SaveGames\"  .  word_array[2]
                Break
            }
        }
    Return

About:


return
