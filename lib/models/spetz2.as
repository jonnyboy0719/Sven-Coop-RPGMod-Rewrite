// Include our baseclass
#include "baseclass"

class CPlayerSpetz2 : CPlayerModelBase
{
	CPlayerSpetz2()
	{
		AddToList( this );
	}
	
	void Init()
	{
		SetName( "Spetz: Breeky" );
		SetModel( "afterlife_spetz2" );
		AddSounds();
	}
	
	void AddSounds()
	{
		// PainSound
		AddPainSound( "afterlife/player/spetz/pain1.wav" );
		AddPainSound( "afterlife/player/spetz/pain2.wav" );
		AddPainSound( "afterlife/player/spetz/pain3.wav" );
		AddPainSound( "afterlife/player/spetz/pain4.wav" );
		AddPainSound( "afterlife/player/spetz/pain5.wav" );
		
		// Death Sound
		AddDeathSound( "afterlife/player/spetz/death1.wav" );
		AddDeathSound( "afterlife/player/spetz/death2.wav" );
		AddDeathSound( "afterlife/player/spetz/death3.wav" );
		AddDeathSound( "afterlife/player/spetz/death4.wav" );
		
		// Spawn Sound
		AddSpawnSound( "afterlife/player/spetz/spawn1.wav" );
		AddSpawnSound( "afterlife/player/spetz/spawn2.wav" );
		AddSpawnSound( "afterlife/player/spetz/spawn3.wav" );
		
		// Medic Sound
		AddMedicSound( "afterlife/player/spetz/medic1.wav" );
		AddMedicSound( "afterlife/player/spetz/medic2.wav" );
		AddMedicSound( "afterlife/player/spetz/medic3.wav" );
		
		// Grenade Sound
		AddGrenadeSound( "afterlife/player/spetz/cover1.wav" );
		AddGrenadeSound( "afterlife/player/spetz/cover2.wav" );
		AddGrenadeSound( "afterlife/player/spetz/cover3.wav" );
		AddGrenadeSound( "afterlife/player/spetz/cover4.wav" );
		AddGrenadeSound( "afterlife/player/spetz/cover5.wav" );
		AddGrenadeSound( "afterlife/player/spetz/cover6.wav" );
	}
}
