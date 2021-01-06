#include "stdafx.h"

Application::Application(HINSTANCE hinst,int argc, const char** argv):
	m_DirectInput(hinst,this)
{
}

Application::~Application()
{
}

int Application::Run()
{
	while (WaitNextFrame())
	{
		if(!(m_frame%100))
			m_DirectInput.ScanForJoysticks();

		if(LockWindow())
		{
			m_DirectInput.PollJoystick();
		}
	}
	return m_return_code;
}


bool Application::WaitNextFrame()
{
	Sleep(10); // we go for 100 Hz scanning frequency
	m_t = GetTickCount();
	m_frame++;
	return m_running;
}

bool Application::LockWindow()
{
	if(!m_hwnd_game)  
	{
		m_hwnd_game=FindWindow(NULL,"Dual Universe");
		if(m_hwnd_game)
		{
			printf("Found game window\n");
		}
	}
	else 
	{
		if(!IsWindow(m_hwnd_game))
		{
			m_hwnd_game=0;
			printf("Lost game window\n");
		}
	}

	return (m_hwnd_game!=nullptr);
}

void Application::OnAxisChanged(JOYSTICK_AXIS axis,int ivalue)
{
}

void Application::OnButtonChanged(int nr,int value)
{
}
