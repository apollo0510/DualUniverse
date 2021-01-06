#include "stdafx.h"


DirectInput::DirectInput(HINSTANCE hinst,JoyStickInterface* pInterface):
	m_pJoyStickInterface(pInterface)
{
	memset(&m_joystick_guid, 0, sizeof(m_joystick_guid));
	memset(&m_js, 0, sizeof(m_js));

	DirectInput8Create(hinst,
		DIRECTINPUT_VERSION,
		IID_IDirectInput8W,
		(void**)&m_pDirectInput,
		NULL);

	if (m_pDirectInput)
	{
		m_pDirectInput->QueryInterface(IID_IDirectInputJoyConfig8, (void**)&m_pJoyConfig);
		if(m_pJoyConfig)
		{
			printf("Started joystick scanning\n");
		}
	}
}

DirectInput::~DirectInput()
{
	if (m_pJoyStick)
	{
		m_pJoyStick->Release();
		m_pJoyStick = nullptr;
	}

	if (m_pJoyConfig)
	{
		m_pJoyConfig->Release();
		m_pJoyConfig = nullptr;
	}

	if (m_pDirectInput)
	{
		m_pDirectInput->Release();
		m_pDirectInput = nullptr;
	}
}


bool DirectInput::ScanForJoysticks()
{
	if (m_pJoyConfig && !m_pJoyStick)
	{
		DIJOYCONFIG PreferredJoyCfg;
		memset(&PreferredJoyCfg, 0, sizeof(PreferredJoyCfg));

		DI_ENUM_CONTEXT enumContext;
		memset(&enumContext.joystick_guid, 0, sizeof(GUID));
		enumContext.pPreferredJoyCfg = &PreferredJoyCfg;
		enumContext.bPreferredJoyCfgValid = false;
		enumContext.pCDirectInput = this;

		if (SUCCEEDED(m_pJoyConfig->GetConfig(0, &PreferredJoyCfg, DIJC_GUIDINSTANCE))) // This function is expected to fail if no joystick is attached
		{
			enumContext.bPreferredJoyCfgValid = true;
		}

		m_pDirectInput->EnumDevices(DI8DEVCLASS_GAMECTRL, EnumJoysticksCallback, &enumContext, DIEDFL_ATTACHEDONLY);

		if (enumContext.joystick_guid != m_joystick_guid)
		{
			m_joystick_guid = enumContext.joystick_guid;
			m_pDirectInput->CreateDevice(m_joystick_guid, &m_pJoyStick, NULL);
			if (m_pJoyStick)
			{
				m_pJoyStick->SetDataFormat(&c_dfDIJoystick);
				m_pJoyStick->SetCooperativeLevel(NULL, DISCL_EXCLUSIVE);
				m_pJoyStick->EnumObjects(EnumObjectsCallback, this, DIDFT_ALL);
				m_pJoyStick->Acquire();
				memset(&m_js, 0, sizeof(m_js));
				printf("Found joystick\n");
			}
		}
	}

	return (m_pJoyStick != nullptr);
}

BOOL CALLBACK DirectInput::EnumJoysticksCallback(const DIDEVICEINSTANCE* pdidInstance, VOID* pContext)
{
	DI_ENUM_CONTEXT* pEnumContext = (DI_ENUM_CONTEXT*)pContext;

	if (pEnumContext->bPreferredJoyCfgValid &&
		!IsEqualGUID(pdidInstance->guidInstance, pEnumContext->pPreferredJoyCfg->guidInstance))
		return DIENUM_CONTINUE;

	pEnumContext->joystick_guid = pdidInstance->guidInstance;

	return DIENUM_STOP;
}

BOOL CALLBACK DirectInput::EnumObjectsCallback(const DIDEVICEOBJECTINSTANCE* pdidoi, VOID* pContext)
{
	DirectInput* pCDirectInput = (DirectInput*)pContext;

	// For axes that are returned, set the DIPROP_RANGE property for the
	// enumerated axis in order to scale min/max values.
	if (pdidoi->dwType & DIDFT_AXIS)
	{
		DIPROPRANGE diprg;
		diprg.diph.dwSize = sizeof(DIPROPRANGE);
		diprg.diph.dwHeaderSize = sizeof(DIPROPHEADER);
		diprg.diph.dwHow = DIPH_BYID;
		diprg.diph.dwObj = pdidoi->dwType; // Specify the enumerated axis
		diprg.lMin = -1000;
		diprg.lMax = +1000;

		// Set the range for the axis
		pCDirectInput->m_pJoyStick->SetProperty(DIPROP_RANGE, &diprg.diph);

	}

	return DIENUM_CONTINUE;
}


bool DirectInput::PollJoystick()
{
	if (m_pJoyStick)
	{
		DIJOYSTATE js;
		memset(&js, 0, sizeof(js));

		HRESULT hr = m_pJoyStick->Poll();
		if (FAILED(hr))
		{
			if (m_pJoyStick)
			{
				m_pJoyStick->Release();
				m_pJoyStick = nullptr;
				printf("Lost joystick\n");
			}
		}
		else
		{
			if (SUCCEEDED(m_pJoyStick->GetDeviceState(sizeof(DIJOYSTATE), &js)))
			{
				if (m_js.lX != js.lX)
				{
					m_js.lX = js.lX;
					AxisChanged(JA_X_AXIS, m_js.lX);
				}
				if (m_js.lY != js.lY)
				{
					m_js.lY = js.lY;
					AxisChanged(JA_Y_AXIS, m_js.lY);
				}
				if (m_js.lZ != js.lZ)
				{
					m_js.lZ = js.lZ;
					AxisChanged(JA_Z_AXIS, m_js.lZ);
				}
				if (m_js.lRx != js.lRx)
				{
					m_js.lRx = js.lRx;
					AxisChanged(JA_X_ROLL, m_js.lRx);
				}
				if (m_js.lRy != js.lRy)
				{
					m_js.lRy = js.lRy;
					AxisChanged(JA_Y_ROLL, m_js.lRy);
				}
				if (m_js.lRz != js.lRz)
				{
					m_js.lRz = js.lRz;
					AxisChanged(JA_Z_ROLL, m_js.lRz);
				}

				for (int i = 0; i < 32; i++)
				{
					if (m_js.rgbButtons[i] != js.rgbButtons[i])
					{
						m_js.rgbButtons[i] = js.rgbButtons[i];
						ButtonChanged(i, m_js.rgbButtons[i]);
					}
				}
				m_js = js;
			}
		}

	}
	return true;
}

void DirectInput::AxisChanged(JOYSTICK_AXIS axis, int ivalue)
{
	if(m_pJoyStickInterface)
		m_pJoyStickInterface->OnAxisChanged(axis,ivalue);
}

void DirectInput::ButtonChanged(int nr, int value)
{
	if(m_pJoyStickInterface)
		m_pJoyStickInterface->OnButtonChanged(nr,value);
}
