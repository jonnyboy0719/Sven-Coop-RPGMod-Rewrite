// Include our baseclass
#include "baseclass"

class CPlayerBigBoss : CPlayerModelBase
{
	CPlayerBigBoss()
	{
		AddToList( this );
	}
	
	void Init()
	{
		SetName( "Big Boss" );
		SetModel( "afterlife_bigboss" );
		SetAllowedState( state_community );
	}
}
