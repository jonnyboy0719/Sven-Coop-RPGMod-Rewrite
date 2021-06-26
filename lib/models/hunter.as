// Include our baseclass
#include "baseclass"

class CPlayerHunter : CPlayerModelBase
{
	CPlayerHunter()
	{
		AddToList( this );
	}
	
	void Init()
	{
		SetName( "Hunter" );
		SetModel( "afterlife_hunter" );
		SetAllowedState( state_community );
	}
}
