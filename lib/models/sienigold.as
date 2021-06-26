// Include our baseclass
#include "baseclass"

class CPlayerSieniGold : CPlayerModelBase
{
	CPlayerSieniGold()
	{
		AddToList( this );
	}
	
	void Init()
	{
		SetName( "Sieni" );
		SetModel( "afterlife_sieni" );
		SetAllowedState( state_community );
	}
}
