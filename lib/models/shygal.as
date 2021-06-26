// Include our baseclass
#include "baseclass"

class CPlayerShyGal : CPlayerModelBase
{
	CPlayerShyGal()
	{
		AddToList( this );
	}
	
	void Init()
	{
		SetName( "Shygal" );
		SetModel( "afterlife_shygal" );
		SetAllowedState( state_community );
	}
}
