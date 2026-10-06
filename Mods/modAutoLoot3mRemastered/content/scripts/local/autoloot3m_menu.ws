// Label only this mod's submenu, retaining standard menu construction.
@wrapMethod
function IngameMenu_FetchAndGenerateGroupMenuObject(flashStorageUtility : CScriptedFlashValueStorage, displayNamePrefix : string, groupDisplayName : string, rootFlashArray : CScriptedFlashArray, out optionParentArray : CScriptedFlashArray) : CScriptedFlashObject
{
    var result : CScriptedFlashObject;
    result = wrappedMethod(flashStorageUtility, displayNamePrefix, groupDisplayName, rootFlashArray, optionParentArray);
    if (result && groupDisplayName == "Mods.AL3mTitle")
    {
        result.SetMemberFlashString("label", "AutoLoot");
        result.SetMemberFlashString("listTitle", "AutoLoot");
    }
    return result;
}
