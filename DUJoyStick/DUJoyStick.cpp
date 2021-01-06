#include "stdafx.h"

int main(int argc,const char** argv)
{
    HINSTANCE hinst=GetModuleHandle(NULL);
    Application app(hinst,argc,argv);
    return app.Run();;
}

