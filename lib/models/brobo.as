// Include our baseclass
#include "baseclass"

class CPlayerBrobo : CPlayerModelBase
{
	CPlayerBrobo()
	{
		AddToList( this );
	}
	
	void Init()
	{
		SetName( "Brobo" );
		SetModel( "afterlife_brobo_fix" );
		SetAllowedState( state_community );
	}
}
