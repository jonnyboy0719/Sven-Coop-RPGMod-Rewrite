namespace Menu
{
	final class PlayerModelsMenu
	{
		private CTextMenu@ m_pMenu = null;
		
		void Show( CBasePlayer@ pPlayer )
		{
			if ( pPlayer is null ) return;
			if ( m_pMenu !is null )
				@m_pMenu = null;
			CreateMenu( pPlayer );
			// Check again, if our data is invalid
			if ( m_pMenu is null ) return;
			m_pMenu.Open( 0, 0, pPlayer );
		}
		
		private void TrySettingModel( CPlayerModelBase@ pModel, CBasePlayer@ pPlayer )
		{
			if ( pModel is null ) return;
			if ( pPlayer is null ) return;
			PlayerData@ data;
			string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
			if ( g_PlayerCoreData.exists(szSteamId) )
				@data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
			if ( data is null ) return;
			if ( pModel.GetModel() == data.szModel )
			{
				g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, pModel.GetName() + " is already selected as your current model!\n");
				return;
			}
			data.szModel = pModel.GetModel();
			SetPlayerModel( pPlayer );
			PlayPlayerSound( pPlayer, sound_spawn );
			g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, pModel.GetName() + " have been selected!\n");
		}
		
		private string GrabModelSpecialName( CPlayerModelBase@ pModel, PlayerData@ data )
		{
			if ( pModel is null ) return "model_err";
			if ( data is null ) return "data_err";
			string strOutput = pModel.GetName() + " [Personal]";
			if ( pModel.GetModel() == data.szModel )
				strOutput += "  [CURRENT]";
			return strOutput;
		}
		
		private string GrabModelName( CPlayerModelBase@ pModel, PlayerData@ data )
		{
			if ( pModel is null ) return "model_err";
			if ( data is null ) return "data_err";
			string strOutput = pModel.GetName();
			if ( pModel.GetModel() == data.szModel )
				strOutput += "  [CURRENT]";
			return strOutput;
		}
		
		private bool AutoAddModel( CPlayerModelBase@ pModel, CBasePlayer@ pPlayer, PlayerData@ data )
		{
			if ( pModel is null ) return false;
			if ( pPlayer is null ) return false;
			if ( pModel.GetAllowedState() >= state_public )
			{
				// Public model
				if ( pModel.GetAllowedState() == state_public ) return true;
				// Community model
				if ( pModel.GetAllowedState() == state_community )
				{
					if ( g_SCRPGCore.IsDonator( data ) ) return true;
					if ( g_SCRPGCore.IsAdministrators( pPlayer, data.szSteamID ) ) return true;
					return data.bIsCommunity;
				}
				// Donator only
				if ( pModel.GetAllowedState() == state_donator )
				{
					if ( g_SCRPGCore.IsDonator( data ) ) return true;
					if ( g_SCRPGCore.IsAdministrators( pPlayer, data.szSteamID ) ) return true;
				}
			}
			return false;
		}
		
		private bool PlayerHasModel( CPlayerModelBase@ pModel, CBasePlayer@ pPlayer, PlayerData@ data )
		{
			if ( pModel is null ) return false;
			if ( pPlayer is null ) return false;
			if ( data is null ) return false;
			for ( uint i = 0; i < data.hAvailableModels.length(); i++ )
			{
				CPlayerModelBase@ model = @data.hAvailableModels[ i ];
				if ( model is null ) continue;
				if ( model.GetModel() == pModel.GetModel() ) return true;
			}
			return AutoAddModel( pModel, pPlayer, data );
		}
		
		private void CreateMenu( CBasePlayer@ pPlayer )
		{
			PlayerData@ data;
			string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
			if ( g_PlayerCoreData.exists(szSteamId) )
				@data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
			if ( data is null ) return;
			
			@m_pMenu = CTextMenu( TextMenuPlayerSlotCallback( this.Callback ) );
			
			m_pMenu.SetTitle( "Character Selection Menu: " );
			
			// Add our special private model first
			// if it's not assigned to "null"
			CPlayerModelBase@ pItemSpecial = GrabPlayerModel( data.szModelSpecial );
			if ( pItemSpecial !is null )
				m_pMenu.AddItem( GrabModelSpecialName( pItemSpecial, data ), any( @pItemSpecial ) );
			
			for( uint uiIndex = 0; uiIndex < g_LoadedPlayerModels.length(); ++uiIndex )
			{
				CPlayerModelBase@ pItem = g_LoadedPlayerModels[ uiIndex ];
				if ( PlayerHasModel( pItem, pPlayer, data ) )
					m_pMenu.AddItem( GrabModelName( pItem, data ), any( @pItem ) );
			}
			
			m_pMenu.Register();
		}
		
		private void Callback( CTextMenu@ menu, CBasePlayer@ pPlayer, int iSlot, const CTextMenuItem@ pItem )
		{
			if ( pItem !is null )
			{
				CPlayerModelBase@ pModelItem = null;
				
				pItem.m_pUserData.retrieve( @pModelItem );
				
				if ( pModelItem !is null )
					TrySettingModel( pModelItem, pPlayer );
			}
		}
	}
}