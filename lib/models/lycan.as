// Include our baseclass
#include "baseclass"

class CPlayerLycan : CPlayerModelBase
{
	CPlayerLycan()
	{
		AddToList( this );
	}
	
	void Init()
	{
		SetName( "Lycan" );
		SetModel( "afterlife_lycan" );
		SetAllowedState( state_community );
	}
}
