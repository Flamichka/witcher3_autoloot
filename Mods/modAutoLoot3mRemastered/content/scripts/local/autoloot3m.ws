// AutoLoot3m for The Witcher 3 Remastered 5.x (PC).
// Signatures checked against installed build 5.0.0.1044392.
// Uses function annotations; no replacement vanilla scripts.

@addField(W3PlayerWitcher)
private var al3mElapsed : float;

@wrapMethod(CPlayer)
function PlayerTick(deltaTime : float, id : int)
{
    var witcher : W3PlayerWitcher;

    wrappedMethod(deltaTime, id);
    witcher = (W3PlayerWitcher)this;
    if (witcher)
        witcher.AL3mTick(deltaTime);
}

@addMethod(W3PlayerWitcher)
public function AL3mTick(deltaTime : float)
{

    if (this != thePlayer || !IsAlive() || theGame.IsPaused())
        return;
    if (!IsActionAllowed(EIAB_InteractionAction) || !CanPerformPlayerAction(true))
        return;

    al3mElapsed += deltaTime;
    if (al3mElapsed < 0.10f)
        return;
    al3mElapsed = 0.0f;
    AL3mReadSettingsAndScan();
}

@addMethod(W3PlayerWitcher)
private function AL3mReadSettingsAndScan()
{
    var enabledValue : string;
    var radiusValue : string;
    var radius : float;

    enabledValue = theGame.GetInGameConfigWrapper().GetVarValue('AL3mSettings', 'Enabled');
    radiusValue = theGame.GetInGameConfigWrapper().GetVarValue('AL3mSettings', 'Radius');
    if (enabledValue == "")
    {
        enabledValue = "true";
        theGame.GetInGameConfigWrapper().SetVarValue('AL3mSettings', 'Enabled', enabledValue);
    }
    if (radiusValue == "")
    {
        radiusValue = "3";
        theGame.GetInGameConfigWrapper().SetVarValue('AL3mSettings', 'Radius', radiusValue);
    }
    if (enabledValue == "false" || enabledValue == "0")
        return;

    radius = StringToFloat(radiusValue);
    if (radius < 1.0f)
        radius = 1.0f;
    if (radius > 6.0f)
        radius = 6.0f;
    AL3mScan(radius);
}

@addMethod(W3PlayerWitcher)
private function AL3mScan(radius : float)
{
    var entities : array<CGameplayEntity>;
    var container : W3Container;
    var i : int;

    // A class-filtered query avoids scanning unrelated actors and props.
    FindGameplayEntitiesInRange(entities, this, radius, 1000, '', 0, NULL, 'W3Container');
    for (i = 0; i < entities.Size(); i += 1)
    {
        container = (W3Container)entities[i];
        if (container && VecDistance(GetWorldPosition(), container.GetWorldPosition()) <= radius)
            container.AL3mCollect();
    }
}

@addMethod(W3Container)
public function AL3mCollect()
{
    var schematics : array<name>;

    // Respect quest gates, locks and containers currently being animated.
    if (!thePlayer || !thePlayer.inv || !inv || disableLooting || !isEnabled)
        return;
    if (lockedByKey || isInteractionBlocked || isPlayingInteractionAnim)
        return;
    if (!lootInteractionComponent || !lootInteractionComponent.IsEnabled())
        return;
    if (thePlayer.IsInCombat() && !IsEnabledInCombat())
        return;
    if (IsEmpty())
        return;

    // Prepare the generated loot as the standard activation path does.
    UpdateContainer();
    RebalanceItems();
    RemoveUnwantedItems();
    if (!inv || IsEmpty() || !isEnabled || lockedByKey || disableLooting)
        return;
    inv.UpdateLoot();
    if (!checkedForBonusMoney)
    {
        checkedForBonusMoney = true;
        CheckForBonusMoney(0);
    }

    // Preserve the standard open-container fact and NG+ diagram handling.
    if (StrLen(factOnContainerOpened) > 0 && !FactsDoesExist(factOnContainerOpened))
        FactsAdd(factOnContainerOpened, 1, -1);
    if (FactsQuerySum("NewGamePlus") > 0)
    {
        schematics = GetWitcherPlayer().GetCraftingSchematicsNames();
        AddWolfNewGamePlusSchematics();
        KeepWolfWitcherSetSchematics(schematics);
    }
    ProcessSpoonCollector(thePlayer);
    InjectItemsOnLevels();

    // Standard item transfer sends NotifyItemLooted and GiveItemTo callbacks.
    // Do not call ProcessLoot: Remastered can merge corpses within 15 metres.
    TakeAllItems();
    // Virtual dispatch retains herb refill and treasure-hunt completion logic.
    // This may destroy a dynamic container, so do not access it afterwards.
    OnContainerClosed();
}
