local composer = require("composer")
local scene = composer.newScene()

-- Variáveis globais para a cena
local soundFile = audio.loadStream("assetsAudio/visitar_peixes.mp3") 
local soundText
local soundOn

-- create()
function scene:create(event)
    local sceneGroup = self.view

    -- Carregar a imagem de background
    local background = display.newImageRect(sceneGroup, "assetsN/pag3-2.png", display.contentWidth, display.contentHeight)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    -- Adicionar a imagem do botão "Próximo"
    local Nextbutton = display.newImageRect(sceneGroup, "assets/next-button.png", 176, 42)
    Nextbutton.x = 640
    Nextbutton.y = 980

    -- Adicionar a imagem do botão "Voltar"
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
            audio.stop(1)
            audio.rewind(soundFile)
            audio.play(soundFile, {
                channel = 1,
                loops = -1,
                fadein = 1000
            })
        elseif soundText.status == "tocando" then
            -- Alterar para som desligado
            soundOn.fill = { type = "image", filename = "assets/mute.png" }
            soundText.text = "Desligado"
            soundText.status = "pausado"
            audio.pause(1)
        end
    end

    -- Adiciona o evento de toque ao botão de som
    soundOn:addEventListener("tap", toggleSound)

    -- Navegação para a próxima página
    Nextbutton:addEventListener("tap", function(event)
        composer.gotoScene("Pag3-3")
    end)

    -- Navegação para a página anterior
    Prevbutton:addEventListener("tap", function(event)
        composer.gotoScene("Pag3-1")
    end)
end

-- show()
function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        -- Código executado antes da cena aparecer
    elseif (phase == "did") then
        -- Código executado quando a cena está visível
    end
end

-- hide()
function scene:hide(event)
    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        -- Código executado antes da cena sair da tela
        audio.stop(1)
        if soundText then
            soundText.status = "pausado"
            soundOn.fill = { type = "image", filename = "assets/mute.png" }
            soundText.text = "Desligado"
        end
    end
end

-- destroy()
function scene:destroy(event)
    local sceneGroup = self.view
    -- Código executado antes da cena ser destruída
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
