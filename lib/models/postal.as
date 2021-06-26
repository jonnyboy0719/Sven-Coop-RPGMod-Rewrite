// Include our baseclass
#include "baseclass"

class CPlayerPostalDude : CPlayerModelBase
{
	CPlayerPostalDude()
	{
		AddToList( this );
	}
	
	void Init()
	{
		SetName( "Postal Dude" );
		SetModel( "afterlife_postal" );
		SetAllowedState( state_community );
		AddSounds();
	}
	
	void CustomSpawn( CBasePlayer@ pPlayer )
	{
		//g_SCRPGCore.CheckForSpecificAchievement( pPlayer, "playermodel_nekopara" );
	}
	
	void AddSounds()
	{
		// PainSound
		AddPainSound( "afterlife/player/postal/pain1.wav" );
		AddPainSound( "afterlife/player/postal/pain2.wav" );
		AddPainSound( "afterlife/player/postal/pain3.wav" );
		AddPainSound( "afterlife/player/postal/pain4.wav" );
		AddPainSound( "afterlife/player/postal/pain5.wav" );
		
		// Death Sound
		AddDeathSound( "afterlife/player/postal/death1.wav" );
		
		// Spawn Sound
		AddSpawnSound( "afterlife/player/postal/spawn1.wav" );
		AddSpawnSound( "afterlife/player/postal/spawn2.wav" );
		
		// Medic Sound
		AddMedicSound( "afterlife/player/postal/medic1.wav" );
		AddMedicSound( "afterlife/player/postal/medic2.wav" );
		AddMedicSound( "afterlife/player/postal/medic3.wav" );
		AddMedicSound( "afterlife/player/postal/medic4.wav" );
		AddMedicSound( "afterlife/player/postal/medic5.wav" );
		AddMedicSound( "afterlife/player/postal/medic6.wav" );
		AddMedicSound( "afterlife/player/postal/medic7.wav" );
		AddMedicSound( "afterlife/player/postal/medic8.wav" );
		AddMedicSound( "afterlife/player/postal/medic9.wav" );
		AddMedicSound( "afterlife/player/postal/medic10.wav" );
		AddMedicSound( "afterlife/player/postal/medic11.wav" );
		AddMedicSound( "afterlife/player/postal/medic12.wav" );
		AddMedicSound( "afterlife/player/postal/medic13.wav" );
		
		// Grenade Sound
		AddGrenadeSound( "afterlife/player/postal/grenade1.wav" );
		AddGrenadeSound( "afterlife/player/postal/grenade2.wav" );
		AddGrenadeSound( "afterlife/player/postal/grenade3.wav" );
		AddGrenadeSound( "afterlife/player/postal/grenade4.wav" );
		AddGrenadeSound( "afterlife/player/postal/grenade5.wav" );
		AddGrenadeSound( "afterlife/player/postal/grenade6.wav" );
		AddGrenadeSound( "afterlife/player/postal/grenade7.wav" );
		AddGrenadeSound( "afterlife/player/postal/grenade8.wav" );
		AddGrenadeSound( "afterlife/player/postal/grenade9.wav" );
		AddGrenadeSound( "afterlife/player/postal/grenade10.wav" );
		AddGrenadeSound( "afterlife/player/postal/grenade11.wav" );
		AddGrenadeSound( "afterlife/player/postal/grenade12.wav" );
		AddGrenadeSound( "afterlife/player/postal/grenade13.wav" );
	}
}
