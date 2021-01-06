#ifndef DIRECT_INPUT_HPP_DEFINED
#define DIRECT_INPUT_HPP_DEFINED

enum JOYSTICK_AXIS
{
    JA_X_AXIS,
    JA_Y_AXIS,
    JA_Z_AXIS,

    JA_X_ROLL,
    JA_Y_ROLL,
    JA_Z_ROLL
};

class JoyStickInterface
{
public:
	virtual void OnAxisChanged(JOYSTICK_AXIS axis,int ivalue) = 0;
	virtual void OnButtonChanged(int nr,int value) = 0;
};

class DirectInput
{
public:
	DirectInput(HINSTANCE hinst,JoyStickInterface* pInterface);
	~DirectInput();

	bool ScanForJoysticks();
	bool PollJoystick();

	JoyStickInterface*       m_pJoyStickInterface=nullptr; 
	LPDIRECTINPUT8           m_pDirectInput = nullptr;
	IDirectInputJoyConfig8*  m_pJoyConfig   = nullptr;
	LPDIRECTINPUTDEVICE8     m_pJoyStick    = nullptr;
	GUID                     m_joystick_guid;
	DIJOYSTATE               m_js;


	void AxisChanged(JOYSTICK_AXIS axis,int ivalue);
    void ButtonChanged(int nr,int value);


private:

	struct DI_ENUM_CONTEXT
    {
		GUID   joystick_guid;
        DIJOYCONFIG* pPreferredJoyCfg;
        bool         bPreferredJoyCfgValid;
        DirectInput *pCDirectInput;
    };

	static BOOL CALLBACK EnumJoysticksCallback( const DIDEVICEINSTANCE* pdidInstance, VOID* pContext );
	static BOOL CALLBACK EnumObjectsCallback( const DIDEVICEOBJECTINSTANCE* pdidoi, VOID* pContext );
};

#endif
