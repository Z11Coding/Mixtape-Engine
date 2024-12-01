function onCreatePost()
    setValue('alpha0', 1, 0)
    setValue('alpha1', 1, 0)
    setValue('alpha2', 1, 0)
    setValue('alpha3', 1, 0)
    setValue('alpha0', 1, 1)
    setValue('alpha1', 1, 1)
    setValue('alpha2', 1, 1)
    setValue('alpha3', 1, 1)
    setValue('beat', 1)
end
local localStep = 0

function onStepHit()
    if curStep == 1 then
        queueEase(curStep, curStep+3, 'alpha0', 0, 'sineInOut', 0)
    end
    if curStep == 8 then
        queueEase(curStep, curStep+3, 'alpha3', 0, 'sineInOut', 1)
    end
    if curStep == 16 then
        queueEase(curStep, curStep+3, 'alpha1', 0, 'sineInOut', 0)
    end
    if curStep == 24 then
        queueEase(curStep, curStep+3, 'alpha2', 0, 'sineInOut', 1)
    end
    if curStep == 32 then
        queueEase(curStep, curStep+3, 'alpha2', 0, 'sineInOut', 0)
    end
    if curStep == 40 then
        queueEase(curStep, curStep+3, 'alpha1', 0, 'sineInOut', 1)
    end
    if curStep == 48 then
        queueEase(curStep, curStep+3, 'alpha3', 0, 'sineInOut', 0)
    end
    if curStep == 56 then
        queueEase(curStep, curStep+3, 'alpha0', 0, 'sineInOut', 1)
    end
    if curStep == 256 then
        queueEase(curStep, curStep+3, 'beat', 0, 'sineInOut')
        queueEase(curStep, curStep+3, 'drunk', 1, 'sineInOut')
    end
    if curStep == 316 then
        queueEase(curStep, curStep+3, 'beat', 1, 'sineInOut')
        queueEase(curStep, curStep+3, 'drunk', 0, 'sineInOut')
    end
    if curStep == 408 then
        queueEase(curStep, curStep+3, 'beat', 0, 'sineInOut')
        queueEase(curStep, curStep+3, 'tornado', 1.5, 'sineInOut')
    end
    localStep = curStep
end

function opponentNoteHit(index, noteDir, noteType, isSustainNote)
    if noteDir == 0 then
        setValue("transform0X", -150, 1)
        setValue("receptor0Angle", -360, 1)
        setValue("note0Angle", -360, 1)
        queueEase(curStep, curStep+3, 'transform0X', 0, 'sineInOut', 1)
        queueEase(curStep, curStep+3, 'receptor0Angle', 0, 'sineInOut', 1)
        queueEase(curStep, curStep+3, 'note0Angle', 0, 'sineInOut', 1)
    elseif noteDir == 1 then
        setValue("transform1Y", 150, 1)
        setValue("receptor1Angle", -360, 1)
        setValue("note1Angle", -360, 1)
        queueEase(curStep, curStep+3, 'transform1Y', 0, 'sineInOut', 1)
        queueEase(curStep, curStep+3, 'receptor1Angle', 0, 'sineInOut', 1)
        queueEase(curStep, curStep+3, 'note1Angle', 0, 'sineInOut', 1)
    elseif noteDir == 2 then
        setValue("transform2Y", -150, 1)
        setValue("receptor2Angle", 360, 1)
        setValue("note2Angle", 360, 1)
        queueEase(curStep, curStep+3, 'transform2Y', 0, 'sineInOut', 1)
        queueEase(curStep, curStep+3, 'receptor2Angle', 0, 'sineInOut', 1)
        queueEase(curStep, curStep+3, 'note2Angle', 0, 'sineInOut', 1)
    elseif noteDir == 3 then
        setValue("transform3X", 150, 1)
        setValue("receptor3Angle", 360, 1)
        setValue("note3Angle", 360, 1)
        queueEase(curStep, curStep+3, 'transform3X', 0, 'sineInOut', 1)
        queueEase(curStep, curStep+3, 'receptor3Angle', 0, 'sineInOut', 1)
        queueEase(curStep, curStep+3, 'note3Angle', 0, 'sineInOut', 1)
    end
end

function goodNoteHit(index, noteDir, noteType, isSustainNote)
    if localStep < 400 then
        if noteDir == 0 then
            setValue("transform0X", -150, 0)
            setValue("receptor0Angle", -360, 0)
            setValue("note0Angle", -360, 0)
            queueEase(curStep, curStep+3, 'transform0X', 0, 'sineInOut', 0)
            queueEase(curStep, curStep+3, 'receptor0Angle', 0, 'sineInOut', 0)
            queueEase(curStep, curStep+3, 'note0Angle', 0, 'sineInOut', 0)
        elseif noteDir == 1 then
            setValue("transform1Y", 150, 0)
            setValue("receptor1Angle", -360, 0)
            setValue("note1Angle", -360, 0)
            queueEase(curStep, curStep+3, 'transform1Y', 0, 'sineInOut', 0)
            queueEase(curStep, curStep+3, 'receptor1Angle', 0, 'sineInOut', 0)
            queueEase(curStep, curStep+3, 'note1Angle', 0, 'sineInOut', 0)
        elseif noteDir == 2 then
            setValue("transform2Y", -150, 0)
            setValue("receptor2Angle", 360, 0)
            setValue("note2Angle", 360, 0)
            queueEase(curStep, curStep+3, 'transform2Y', 0, 'sineInOut', 0)
            queueEase(curStep, curStep+3, 'receptor2Angle', 0, 'sineInOut', 0)
            queueEase(curStep, curStep+3, 'note2Angle', 0, 'sineInOut', 0)
        elseif noteDir == 3 then
            setValue("transform3X", 150, 0)
            setValue("receptor3Angle", 360, 0)
            setValue("note3Angle", 360, 0)
            queueEase(curStep, curStep+3, 'transform3X', 0, 'sineInOut', 0)
            queueEase(curStep, curStep+3, 'receptor3Angle', 0, 'sineInOut', 0)
            queueEase(curStep, curStep+3, 'note3Angle', 0, 'sineInOut', 0)
        end
    end
end