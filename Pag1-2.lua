local composer = require("composer")
local scene = composer.newScene()

-- Variáveis globais para a cena

local soundFile = audio.loadStream("assetsAudio/Vamos_la_fora.mp3")
local soundText -- Declaração global para que outras funções possam acessar
local soundOn
-- create()
function scene:create(event)
    local sceneGroup = self.view

    -- Carregar a imagem de background
    local background = display.newImageRect(sceneGroup, "assetsN/pag1-2.png", display.contentWidth, display.contentHeight)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    -- Adicionar a imagem do botão
    local Nextbutton = display.newImageRect(sceneGroup, "assets/next-button.png", 176, 42)
    Nextbutton.x = 640
    Nextbutton.y = 980

    local Prevbutton = display.newImageRect(sceneGroup, "assets/prev-button.png", 176, 42)
    Prevbutton.x = 130
    Prevbutton.y = 980

    soundOn = display.newImageRect(sceneGroup, "assets/mute.png", 60, 60)
    soundOn.x = 685
    soundOn.y = 210
 

    -- Inicializa o soundText e adiciona ao grupo da cena
    soundText = display.newText({
        parent = sceneGroup,
        text = "Desligado",
        x = soundOn.x,
        y = soundOn.y + 40,
        font = native.systemFontBold,
        fontSize = 24,
        align = "center"
    })
    soundText:setFillColor(65/255, 97/255, 176/255, 1)
    soundText.status = "pausado"

    -- Adiciona os eventos aos botões
    Nextbutton:addEventListener("tap", function(event)
        composer.gotoScene("Pag1-3")
    end)

    Prevbutton:addEventListener("tap", function(event)
        composer.gotoScene("Pag1")
    end)

    -- Função para alternar entre som ligado e mudo
    local function toggleSound(event)
        if soundText.status == "pausado" then
            soundOn.fill = { type = "image", filename = "assets/soundOn.png" }
            soundText.text = "Ligado"
            soundText.status = "tocando"

            audio.stop(1)
            audio.rewind(soundFile)
            audio.play(soundFile, {
                channel = 1,
                loops = -1,
                fadein = 1000
            })
        elseif soundText.status == "tocando" then
            soundOn.fill = { type = "image", filename = "assets/mute.png" }
            soundText.text = "Desligado"
            soundText.status = "pausado"
            audio.pause(1)
        end
    end

    soundOn:addEventListener("tap", toggleSound)
end

-- show()
function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
    elseif (phase == "did") then
        -- Code here runs when the scene is entirely on screen
    end
end

-- hide()
-- hide()
function scene:hide(event)
    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        audio.stop(1) -- Para o áudio no canal 1

        if soundText then
            soundText.status = "pausado" -- Reseta o status para "pausado"
            soundOn.fill = { type = "image", filename = "assets/mute.png" }
            soundText.text = "Desligado"
        end

    elseif (phase == "did") then
        -- Code here runs immediately after the scene goes entirely off screen
    end
end


-- destroy()
function scene:destroy(event)
    local sceneGroup = self.view

    if soundFile then
        audio.dispose(soundFile)
        soundFile = nil
    end
end

-- Scene event function listeners
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
