#include <windows.h>
#include <cstring>
#include <string>
#include <fstream>
#include <sstream>
#include "ErrorExit.h"

int main(int argc, char **argv){
    if (argc < 2){
        ErrorExit("Missing argument for a filename");
    }
    if (!OpenClipboard(0)){
        ErrorExit("Can't open clipboard");
    }
    if (!EmptyClipboard()){
        ErrorExit("Can't empty the clipboard");
    }
    std::ifstream file(argv[1], std::ios::in);
    std::stringstream buffer;
    if(!file.good())
    {
        ErrorExit("Can't open file");
    }
    buffer << file.rdbuf();
    std::string content = buffer.str();
    file.close();
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
