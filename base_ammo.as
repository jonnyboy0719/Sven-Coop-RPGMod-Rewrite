mixin class ammo_afterlife_base
{
	bool CommonAddAmmo( CBaseEntity@ pOther, int& in iAmmoClip, int& in iAmmoCarry, string& in iAmmoType )
	{
		if( pOther.GiveAmmo( iAmmoClip, iAmmoType, iAmmoCarry ) != -1 )
		{
			g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/ammopickup1.wav", 1, ATTN_NORM );
			return true;
		}
		return false;
	}
}