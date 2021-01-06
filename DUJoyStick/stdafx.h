#ifndef DU_JOYSTICK_STD_AFX_HPP_DEFINED
#define DU_JOYSTICK_STD_AFX_HPP_DEFINED

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <windows.h>

#define DIRECTINPUT_VERSION 0x0800
#include <dinput.h>
#include <dinputd.h>

#pragma comment(lib,"dinput8.lib")
#pragma comment(lib,"dxguid.lib")

#include "DirectInput.h"
#include "Application.h"

#endif
