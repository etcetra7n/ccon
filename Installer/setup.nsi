;======================================================
; Include

  !include MUI2.nsh

;======================================================
; Macro definitions
  !ifndef VERSION
    !define VERSION "1.0.0"
  !endif
  !ifndef ARCH
    !define ARCH "x86"
  !endif
  !ifndef CCON_EXE_PATH
    !define CCON_EXE_PATH "..\_build\Release\ccon.exe"
  !endif
  !ifndef CPY_ICON_ICO_PATH
    !define CPY_ICO_PATH "cpy.ico"
  !endif
  !ifndef LICENSE_PATH
    !define LICENSE_PATH "..\LICENSE"
  !endif

;======================================================
; Installer Information

  Name "CCON"
  OutFile "ccon-v${VERSION}-win-${ARCH}-setup.exe"
  !if ${ARCH} == "x86"
    InstallDir $PROGRAMFILES\ccon
  !else if ${ARCH} == "x64"
    InstallDir $PROGRAMFILES64\ccon
  !endif

;======================================================
; Interface Configuration

  !define MUI_HEADERIMAGE
  !define MUI_ABORTWARNING
  !define MUI_COMPONENTSPAGE_SMALLDESC
  !define MUI_HEADERIMAGE_BITMAP_NOSTRETCH
  !define MUI_FINISHPAGE
  !define MUI_FINISHPAGE_TEXT "Thank you for installing ccon"

;======================================================
; Installer pages

  !insertmacro MUI_PAGE_WELCOME
  !insertmacro MUI_PAGE_LICENSE ${LICENSE_PATH}
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH

;======================================================
; Uninstaller pages

  !insertmacro MUI_UNPAGE_WELCOME
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_DIRECTORY
  !insertmacro MUI_UNPAGE_INSTFILES
  !insertmacro MUI_UNPAGE_FINISH

;======================================================
; Languages

  !insertmacro MUI_LANGUAGE "English"

;======================================================
; Installer Section

  Section "Installer"

    ; Write ccon.exe to $INSTDIR
    SetOutPath $INSTDIR
    File ${CCON_EXE_PATH}
    File ${CPY_ICO_PATH}

    ; Add $INSTDIR to the PATH user environment variable
    EnVar::SetHKCU
    EnVar::AddValue "PATH" "$INSTDIR"
    
    ; Register application
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\ccon.exe" "" "$INSTDIR\ccon.exe"
    WriteRegStr HKCR Applications\ccon.exe\DefaultIcon "" "$INSTDIR\cpy.ico"
    WriteRegStr HKCR Applications\ccon.exe\shell\open\command "" "$\"$INSTDIR\ccon.exe$\" $\"%1$\""
    WriteRegStr HKCR Applications\ccon.exe\SupportedTypes ".cpy" ""
    
    ; Configure .cpy file
    WriteRegStr HKCR .cpy "" "CCON.ClipboardStateFile.1"
    WriteRegStr HKCR .cpy "Content Type" "text/plain"
    WriteRegStr HKCR .cpy "PerceivedType" "text"
    WriteRegStr HKCR CCON.ClipboardStateFile.1 "" "Clipboard State File"
    WriteRegStr HKCR CCON.ClipboardStateFile.1\DefaultIcon "" "$INSTDIR\cpy.ico"
    WriteRegStr HKCR CCON.ClipboardStateFile.1\shell\open\command "" "$\"$INSTDIR\ccon.exe$\" $\"%1$\""
    WriteRegStr HKCR CCON.ClipboardStateFile.1\shell\edit\command "" "$\"%SystemRoot%\system32\NOTEPAD.EXE $\"%1$\""
    WriteRegStr HKCU Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.cpy\UserChoice "Progid" "CCON.ClipboardStateFile.1"
    
    ; Configure right click context menu
    WriteRegStr HKCR *\Shell\ccon "" "Copy content"
    WriteRegStr HKCR *\Shell\ccon "Extended" ""
    WriteRegStr HKCR *\Shell\ccon\command "" "$\"$INSTDIR\ccon.exe$\" $\"%1$\""
    
    ; Write uninstaller
    WriteUninstaller $INSTDIR\uninst-ccon.exe
    
    ; Send a WM_SETTINGCHANGE signal
    SendMessage ${HWND_BROADCAST} ${WM_SETTINGCHANGE} 0x002A 0 /TIMEOUT=5000

  SectionEnd

;======================================================
; Uninstaller Section

  Section "un.Uninstaller"
    
    ; Remove executables
    Delete $INSTDIR\ccon.exe
    Delete $INSTDIR\uninst-ccon.exe
    Delete $INSTDIR\cpy.ico
    RMDir $INSTDIR
    
    ; Remove $INSTDIR from PATH user environment variable
    EnVar::SetHKCU
    EnVar::DeleteValue "PATH" "$INSTDIR"
    
    ; Unregister application
    DeleteRegKey HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\ccon.exe"
    DeleteRegKey HKCR Applications\ccon.exe
    
    ; Deconfigure .cpy file
    DeleteRegKey HKCR CCON.ClipboardStateFile.1
    DeleteRegKey HKCU Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.cpy
    
    ; Deconfigure right click context menu
    DeleteRegKey HKCR *\Shell\ccon
    
    ; Send a WM_SETTINGCHANGE signal
    SendMessage ${HWND_BROADCAST} ${WM_SETTINGCHANGE} 0x002A 0 /TIMEOUT=5000
    
  SectionEnd

;======================================================
