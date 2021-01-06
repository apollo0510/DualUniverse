#ifndef APPLICATION_HPP_DEFINED
#define APPLICATION_HPP_DEFINED

class Application: public JoyStickInterface
{
public:
	Application(HINSTANCE hinst,int argc,const char** argv);
	~Application();
	int Run();
	bool WaitNextFrame();
	bool LockWindow();

	virtual void OnAxisChanged(JOYSTICK_AXIS axis,int ivalue) override;
	virtual void OnButtonChanged(int nr,int value) override;

	int  m_return_code = 0;
	bool m_running = true;
	
	uint32_t m_t     = 0;
	uint32_t m_frame = 0;

	DirectInput m_DirectInput;

	HWND m_hwnd_game = nullptr;
	RECT m_rect_game;
};


#endif