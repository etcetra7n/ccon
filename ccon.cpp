#include <cstdio>
#include <string>
#include <fstream>
#include <windows.h>

void ErrorExit(const std::string &errMsg){ 
    LPVOID lpMsgBuf;
    LPVOID lpDisplayBuf;
    DWORD dw = GetLastError();
    
    FormatMessage(
        FORMAT_MESSAGE_ALLOCATE_BUFFER | 
        FORMAT_MESSAGE_FROM_SYSTEM |
        FORMAT_MESSAGE_IGNORE_INSERTS,
        NULL,
        dw,
        MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
        (LPTSTR) &lpMsgBuf,
        0, NULL );
    
    lpDisplayBuf = (LPVOID)LocalAlloc(LMEM_ZEROINIT, errMsg.size() * sizeof(TCHAR)); 
    sprintf((LPTSTR)lpDisplayBuf, TEXT(errMsg).c_str());
    MessageBox(NULL, (LPCTSTR)lpDisplayBuf, TEXT("ccon.exe"), MB_OK); 
    
    LocalFree(lpMsgBuf);
    LocalFree(lpDisplayBuf);
    ExitProcess(dw);
    exit(dw);
}

int main(int argc, char* argv[]){
    if (argc < 2){
        ErrorExit("Missing argument for a filename");
    }
    if (!OpenClipboard(0)){
        ErrorExit("Can't open clipboard");
    }
    if (!EmptyClipboard()){
        ErrorExit("Can't empty the clipboard");
    }
    
    std::ifstream file(argv[1]);
    if (!file.good()){
        ErrorExit("Can't open file");
    }
    std::string content((std::istreambuf_iterator<char>(file)), (std::istreambuf_iterator<char>()));
    const size_t sz = content.length()+1;
    
    HGLOBAL h = GlobalAlloc(GMEM_MOVEABLE, sz);
    memcpy(GlobalLock(h), content.c_str(), sz);
    GlobalUnlock(h);
    
    if (SetClipboardData(CF_TEXT, h) == NULL){
        ErrorExit("Can't set clipboard");
    }
    if (!CloseClipboard()){
        ErrorExit("Can's close clipboard");
    }

    return 0;
}
