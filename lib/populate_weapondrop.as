namespace Populate
{
	void PopulateWeaponDrop()
	{
		if ( !g_WeaponDrop.ShouldAddItems() ) return;
		
		// Melee only
		g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_crowbar", "Crowbar", GiftFromTheGods::Rarity_Common, 1, true ) );
		g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_pipewrench", "Pipe Wrench", GiftFromTheGods::Rarity_Common, 1, true ) );
		g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_katana", "Katana", GiftFromTheGods::Rarity_Common, 1, true ) );
		g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_dragonsword", "Dragon Sword", GiftFromTheGods::Rarity_Common, 1, true ) );
		g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_grapple", "Barnacle Grapple", GiftFromTheGods::Rarity_Common, 1, true ) );
		
		// Common
		g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_egon", "Experimental Gluon Gun", GiftFromTheGods::Rarity_Common, 7 ) );
		g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_tripmine", "HECU Laser Tripmine", GiftFromTheGods::Rarity_Common, 5 ) );
		g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_glock", "Glock", GiftFromTheGods::Rarity_Common, 1 ) );
		g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_357", "Revolver", GiftFromTheGods::Rarity_Common, 1 ) );
		g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_uzi", "Uzi", GiftFromTheGods::Rarity_Common, 2 ) );
		g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_eagle", "Desert Eagle", GiftFromTheGods::Rarity_Common, 2 ) );
		g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_sporelauncher", "Spore Launcher", GiftFromTheGods::Rarity_Common, 9 ) );
		g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_crossbow", "Crossbow", GiftFromTheGods::Rarity_Common, 3 ) );
		g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_handgrenade", "Hand Grenades", GiftFromTheGods::Rarity_Common, 5 ) );
		g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_snark", "Some Suicidal Aliens", GiftFromTheGods::Rarity_Common, 6 ) );
		g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_shotgun", "Shotgun", GiftFromTheGods::Rarity_Common, 1 ) );
		g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_mp5", "MP5", GiftFromTheGods::Rarity_Common, 3 ) );
		g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_hornetgun", "Hornet Gun", GiftFromTheGods::Rarity_Common, 6 ) );
		g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_m16", "M16 w/ M203", GiftFromTheGods::Rarity_Common, 4 ) );
		g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_gauss", "Gauss Cannon", GiftFromTheGods::Rarity_Common, 8 ) );
		g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_satchel", "Satchel Charges", GiftFromTheGods::Rarity_Common, 7 ) );
		
		// Un-Common
		g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_displacer", "Displacer", GiftFromTheGods::Rarity_UnCommon, 9 ) );
		g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_uziakimbo", "Akimbo Uzi", GiftFromTheGods::Rarity_UnCommon, 4 ) );
		g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_rpg", "Rocket Launcher", GiftFromTheGods::Rarity_UnCommon, 6 ) );
		g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_sniperrifle", "Sniper Rifle", GiftFromTheGods::Rarity_UnCommon, 8 ) );
		
		// Rare
		g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_m249", "M249 SAW", GiftFromTheGods::Rarity_Rare, 9 ) );
		
		// Super-Rare
		
		// Legendary
		g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_buffsg552", "SG-552", GiftFromTheGods::Rarity_Legendary, 8 ) );
		g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_skull11", "Skull-11", GiftFromTheGods::Rarity_Legendary, 7 ) );
		
		// Mythical
		g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_af_ethereal", "Ethereal", GiftFromTheGods::Rarity_Mythical, 10 ) );
		g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_af_ethereal_mk2", "Ethereal Mk.2", GiftFromTheGods::Rarity_Mythical, 10 ) );
		g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_fotn", "Fist of The North Star", GiftFromTheGods::Rarity_Mythical, 10 ) );
		
		//g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "______________", "______________", GiftFromTheGods::Rarity_Common, 000000000000 ) );
		
		// Populate this afterwards
		PopulateAmmoDrop();
	}
	
	void PopulateAmmoDrop()
	{
		if ( !g_AmmoDrop.ShouldAddItems() ) return;
		
		// Vanilla
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_egon", "uranium" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_tripmine", "trip mine" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_displacer", "uranium" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_glock", "9mm" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_9mmhandgun", "9mm" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_357", "357" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_uzi", "9mm" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_uziakimbo", "9mm" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_eagle", "357" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_sporelauncher", "sporeclip" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_crossbow", "bolts" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_handgrenade", "hand grenade" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_snark", "snarks" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_shotgun", "buckshot" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_rpg", "rockets" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_sniperrifle", "m40a1" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_mp5", "9mm" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_9mmAR", "9mm" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_hornetgun", "hornets" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_m16", "556" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_m249", "556" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_gauss", "uranium" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_satchel", "satchel charge" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_minigun", "556" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_shockrifle", "shock charges" ) );
		
		// Custom
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_af_ethereal", "afterlife_crystals" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_af_ethereal_mk2", "afterlife_crystals" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_buffsg552", "556" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_skull11", "buckshot" ) );
	}
}