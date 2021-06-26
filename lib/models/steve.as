// Include our baseclass
#include "baseclass"

class CPlayerSteve : CPlayerModelBase
{
	CPlayerSteve()
	{
		AddToList( this );
	}
	
	void Init()
	{
		SetName( "Steve" );
		SetModel( "MC_steve" );
		SetAllowedState( state_community );
		AddSounds();
	}
	
	void AddSounds()
	{
		// PainSound
		AddPainSound( "afterlife/player/steve/pain.wav" );
	}
}
