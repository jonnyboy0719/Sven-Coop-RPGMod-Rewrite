// Include our baseclass
#include "baseclass"

class CPlayerCaptainKork : CPlayerModelBase
{
	CPlayerCaptainKork()
	{
		AddToList( this );
	}
	
	void Init()
	{
		SetName( "Captain Kork" );
		SetModel( "afterlife_kork" );
		AddSounds();
	}
	
	void AddSounds()
	{
		// PainSound
		AddPainSound( "afterlife/player/korkv2/pain1.wav" );
		AddPainSound( "afterlife/player/korkv2/pain2.wav" );
		AddPainSound( "afterlife/player/korkv2/pain3.wav" );
		AddPainSound( "afterlife/player/korkv2/pain4.wav" );
		AddPainSound( "afterlife/player/korkv2/pain5.wav" );
		
		// Death Sound
		AddDeathSound( "afterlife/player/korkv2/death1.wav" );
		AddDeathSound( "afterlife/player/korkv2/death2.wav" );
		AddDeathSound( "afterlife/player/korkv2/death3.wav" );
		AddDeathSound( "afterlife/player/korkv2/death4.wav" );
		
		// Spawn Sound
		AddSpawnSound( "afterlife/player/korkv2/spawn1.wav" );
		AddSpawnSound( "afterlife/player/korkv2/spawn2.wav" );
		AddSpawnSound( "afterlife/player/korkv2/spawn3.wav" );
		
		// Medic Sound
		AddMedicSound( "afterlife/player/korkv2/medic1.wav" );
		AddMedicSound( "afterlife/player/korkv2/medic2.wav" );
		AddMedicSound( "afterlife/player/korkv2/medic3.wav" );
		AddMedicSound( "afterlife/player/korkv2/medic4.wav" );
		
		// Grenade Sound
		AddGrenadeSound( "afterlife/player/korkv2/aieu.wav" );
		AddGrenadeSound( "afterlife/player/korkv2/depression.wav" );
		AddGrenadeSound( "afterlife/player/korkv2/diarea.wav" );
		AddGrenadeSound( "afterlife/player/korkv2/earth.wav" );
		AddGrenadeSound( "afterlife/player/korkv2/gayshit.wav" );
		AddGrenadeSound( "afterlife/player/korkv2/madden.wav" );
		AddGrenadeSound( "afterlife/player/korkv2/madden2.wav" );
		AddGrenadeSound( "afterlife/player/korkv2/poopoo.wav" );
		AddGrenadeSound( "afterlife/player/korkv2/reetard.wav" );
		AddGrenadeSound( "afterlife/player/korkv2/shit.wav" );
		AddGrenadeSound( "afterlife/player/korkv2/tightass.wav" );
		AddGrenadeSound( "afterlife/player/korkv2/wipe.wav" );
	}
}
