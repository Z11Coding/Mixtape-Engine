local pixelScale = 1;

--local alreadyPlayedStrumAnim = {{false, false, false, false}, {false, false, false, false}} -- Originally for fixed strums
function goodNoteHit(membersIndex, noteData, noteType, isSustainNote)
	strumLogic(membersIndex, noteData, noteType, isSustainNote);
end

function opponentNoteHit(membersIndex, noteData, noteType, isSustainNote)
	strumLogic(membersIndex, noteData, noteType, isSustainNote);
end

function strumLogic(i, d, t, isSustainNote)
	local strumToUse = (getPropertyFromGroup('notes', i, 'mustPress') and 'player' or 'opponent')..'Strums'
	if not isSustainNote then
		setPropertyFromGroup(strumToUse, d, 'animation.curAnim.curFrame', 0)
		setPropertyFromGroup(strumToUse, d, 'scale.x', 0.75 * pixelScale)
		setPropertyFromGroup(strumToUse, d, 'scale.y', 0.75 * pixelScale)
		doTweenX(strumToUse..'['..d..'].scale.x', strumToUse..'.members['..d..'].scale', 0.7 * pixelScale, 0.1, 'expoInOut')
		doTweenY(strumToUse..'['..d..'].scale.y', strumToUse..'.members['..d..'].scale', 0.7 * pixelScale, 0.1, 'expoInOut')
		if strumToUse == 'playerStrums' and not botPlay then
			return
		end
		for note = 0, getProperty('notes.length')-1 do
			if getPropertyFromGroup(strumToUse, getPropertyFromGroup('notes', i, 'prevNote.noteData'), 'animation.curAnim.name') == 'confirm' and not getPropertyFromGroup('notes', i, 'prevNote.isSustainNote') then
				setPropertyFromGroup(strumToUse, getPropertyFromGroup('notes', i, 'prevNote.noteData'), 'resetAnim', 0.00001)
			end
		end
	end
	if strumToUse == 'playerStrums' and not botPlay then
		return
	end
	setPropertyFromGroup(strumToUse, d, 'resetAnim', (stepCrochet / (getPropertyFromGroup('notes', i, 'isSustainNote') and stringEndsWith(getPropertyFromGroup('notes', i, 'animation.curAnim.name'), 'end') and 2000 or 1000)) * (getPropertyFromClass('backend.Conductor', 'bpm') / getPropertyFromClass('states.PlayState', 'SONG.bpm')) * (isSustainNote and 1.35 or 1))
end

function onUpdate(elapsed)
	pixelScale = getPropertyFromClass('states.PlayState', 'isPixelStage') and getPropertyFromClass('states.PlayState', 'daPixelZoom') / 0.7 or 1
end

function onUpdatePost(elapsed)
	for i = 0, getProperty('opponentStrums.members.length') do
		if getPropertyFromGroup('opponentStrums', i, 'animation.curAnim.name') ~= 'confirm' and getPropertyFromGroup('opponentStrums', i, 'animation.curAnim.name') ~= 'press' then
			setPropertyFromGroup('opponentStrums', i, 'scale.x', 0.7 * pixelScale)
			setPropertyFromGroup('opponentStrums', i, 'scale.y', 0.7 * pixelScale)
		else
			setPropertyFromGroup('opponentStrums', i, 'animation.curAnim.curFrame', 0)
		end
	end
	for i = 0, getProperty('playerStrums.members.length') do
		if getPropertyFromGroup('playerStrums', i, 'animation.curAnim.name') ~= 'confirm' and getPropertyFromGroup('playerStrums', i, 'animation.curAnim.name') ~= 'press' then
			setPropertyFromGroup('playerStrums', i, 'scale.x', 0.7 * pixelScale)
			setPropertyFromGroup('playerStrums', i, 'scale.y', 0.7 * pixelScale)
		else
			setPropertyFromGroup('playerStrums', i, 'animation.curAnim.curFrame', 0)
		end
	end
	--debugPrint(alreadyPlayedStrumAnim)
end