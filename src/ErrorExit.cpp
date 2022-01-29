#include "ccon.h"
#include <windows.h>
#include <string>

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
    MessageBox(NULL, (LPCTSTR)lpDisplayBuf, TEXT("CCON"), MB_OK);

    LocalFree(lpMsgBuf);
    LocalFree(lpDisplayBuf);
    ExitProcess(dw);
    exit(dw);
}
