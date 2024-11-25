local composer = require("composer")
local scene = composer.newScene()

local physics = require("physics")
physics.start()

local lightBeamsTimer -- Timer para a criação dos conjuntos de bolinhas de luz
local isCloudNearSun = false -- Variável de controle para verificar se a nuvem está perto do sol
local isCloudMoved = false -- Controle para verificar se a nuvem saiu da posição inicial
local cloudStartX = nil -- Posição inicial da nuvem

local soundFile = audio.loadStream("assetsAudio/arrastar_nuvem.mp3") -- Substitua pelo caminho do seu arquivo de áudio
local soundText
local soundOn

function scene:create(event)
    local sceneGroup = self.view

    -- Fundo do cenário
    local background = display.newImageRect(sceneGroup, "assets/faseClara.png", display.contentWidth, display.contentHeight)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    -- Sol
    local sun = display.newImageRect(sceneGroup, "assets/Sun.png", 359, 364)
    sun.x = display.contentWidth - 100
    sun.y = 100

    -- Árvore
    local tree = display.newImageRect(sceneGroup, "assets/tree2.png", 512, 512)
    tree.x = 110
    tree.y = 610

    -- Nuvem que será arrastada
    local cloud = display.newImageRect(sceneGroup, "assets/nuvem.png", 353, 353)
    cloud.x = display.contentCenterX + 150 -- Define a posição inicial da nuvem
    cloud.y = 100
    cloudStartX = cloud.x -- Salva a posição inicial da nuvem para comparação

    -- Adicionar a imagem do botão
    local Nextbutton = display.newImageRect(sceneGroup, "assets/next-button.png", 176, 42)
    Nextbutton.x = 640
    Nextbutton.y = 980

    local Prevbutton = display.newImageRect(sceneGroup, "assets/prev-button.png", 176, 42)
    Prevbutton.x = 130
    Prevbutton.y = 980

    -- Adicionar o botão de som
    soundOn = display.newImageRect(sceneGroup, "assets/mute.png", 60, 60)
    soundOn.x = 685
    soundOn.y = 210

    -- Adicionar texto para indicar ON ou OFF abaixo da imagem do som
    soundText = display.newText({
        parent = sceneGroup,
        text = "Desligado",
        x = soundOn.x,
        y = soundOn.y + 40,
        font = native.systemFontBold,
        fontSize = 24,
        align = "center"
    })
    soundText:setFillColor(65 / 255, 97 / 255, 176 / 255, 1)
    soundText.status = "pausado" -- Define o estado inicial do som

    -- Função para alternar entre som ligado e mudo
    local function toggleSound(event)
        if soundText.status == "pausado" then
            -- Alterar para som ligado
            soundOn.fill = { type = "image", filename = "assets/soundOn.png" }
            soundText.text = "Ligado"
            soundText.status = "tocando"
            audio.stop(1) -- Garante que o canal esteja pronto
            audio.rewind(soundFile) -- Reinicia o áudio do início
            audio.play(soundFile, {
                channel = 1,
                loops = -1, -- Loop infinito
                fadein = 1000
            })
        elseif soundText.status == "tocando" then
            -- Alterar para som desligado
            soundOn.fill = { type = "image", filename = "assets/mute.png" }
            soundText.text = "Desligado"
            soundText.status = "pausado"
            audio.pause(1) -- Pausa o áudio no canal 1
        end
    end

    soundOn:addEventListener("tap", toggleSound)

    Nextbutton:addEventListener("tap", function(event)
        composer.gotoScene("Pag2")
    end)

    Prevbutton:addEventListener("tap", function(event)
        composer.gotoScene("Pag1-2")
    end)

    -- Função para criar um conjunto de bolinhas de luz
    local function createLightBeamSet()
        if not isCloudNearSun and isCloudMoved then
            for i = 1, 5 do
                local lightBeam = display.newCircle(sceneGroup, sun.x, sun.y, 10)
                lightBeam:setFillColor(1, 1, 0)
                local angleOffset = (i - 3) * 15
                transition.to(lightBeam, {
                    time = 1500,
                    x = tree.x + math.random(-30, 30),
                    y = tree.y - 50 + angleOffset,
                    radius = 60,
                    onComplete = function()
                        display.remove(lightBeam)
                    end
                })
            end
        end
    end

    -- Função para mover a nuvem
    local function moveCloud(event)
        local cloud = event.target
        local phase = event.phase

        if (phase == "began") then
            display.currentStage:setFocus(cloud)
            cloud.touchOffsetX = event.x - cloud.x
        elseif (phase == "moved") then
            cloud.x = event.x - cloud.touchOffsetX

            if cloud.x < display.contentCenterX - 150 then
                cloud.x = display.contentCenterX - 150
            elseif cloud.x > display.contentWidth - cloud.width * 0.5 then
                cloud.x = display.contentWidth - cloud.width * 0.5
            end

            if cloud.x < cloudStartX then
                isCloudMoved = true
            else
                isCloudMoved = false
            end
        elseif (phase == "ended" or phase == "cancelled") then
            display.currentStage:setFocus(nil)
            local distanceToSun = math.abs(cloud.x - sun.x)
            if distanceToSun < 50 then
                if lightBeamsTimer then
                    timer.cancel(lightBeamsTimer)
                    lightBeamsTimer = nil
                    isCloudNearSun = true
                end
            end
        end
        return true
    end

    cloud:addEventListener("touch", moveCloud)
    lightBeamsTimer = timer.performWithDelay(2000, createLightBeamSet, 0)
end

-- hide()
function scene:hide(event)
    local phase = event.phase
    if (phase == "will") then
        audio.stop(1)
        soundText.status = "pausado"
        soundOn.fill = { type = "image", filename = "assets/mute.png" }
        soundText.text = "Desligado"
    end
end

-- destroy()
function scene:destroy(event)
    if soundFile then
        audio.dispose(soundFile)
        soundFile = nil
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
