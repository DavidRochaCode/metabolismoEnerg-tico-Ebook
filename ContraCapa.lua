local composer = require("composer")
local scene = composer.newScene()

-- Variáveis globais para a cena
local soundFile = audio.loadStream("assetsAudio/contraCapa.mp3") -- Substitua pelo caminho do seu arquivo de áudio
local soundText
local soundOn
local popupGroup

IsPopupActive = false

-- Função para pulsar o botão
local function pulseButton(button)
    local scaleUp
    local scaleDown

    -- Animação para diminuir o tamanho do botão 
    scaleDown = function()
        transition.to(button, {time = 500, xScale = 1.0, yScale = 1.0, onComplete = scaleUp})
    end

    -- Animação para aumentar o tamanho do botão
    scaleUp = function()
        transition.to(button, {time = 500, xScale = 1.2, yScale = 1.2, onComplete = scaleDown})
    end

    -- Iniciar o ciclo de pulsação
    scaleUp()
end

-- Função para fechar o pop-up
local function closePopup()
    if popupGroup then
        popupGroup:removeSelf()
        popupGroup = nil
        IsPopupActive = false
    end
end

-- Função para abrir o pop-up
local function showPopup()
    popupGroup = display.newGroup()
    IsPopupActive = true

    local popupBackground = display.newRect(popupGroup, display.contentCenterX, display.contentCenterY, 650, 800)
    popupBackground:setFillColor(0.839, 0.933, 0.725, 1)

    -- Adicionando a imagem dentro do pop-up
    local popupImage = display.newImageRect(popupGroup, "assets/referencias.png", 650, 800)
    popupImage.x = display.contentCenterX
    popupImage.y = display.contentCenterY

    -- Botão de fechar o pop-up
    local closeButton = display.newText(popupGroup, "Fechar", display.contentCenterX, display.contentCenterY + 90, native.systemFont, 30)
    closeButton:setFillColor(0.254, 0.380, 0.690)

    -- Evento para fechar o pop-up quando o botão for clicado
    closeButton:addEventListener("tap", closePopup)
end

-- Função de evento do botão "Reload"
local function onReloadButtonTap(event)
    if IsPopupActive then
        print("Pop-up ativo, botão Reload desabilitado!")
        return true
    else
        composer.gotoScene("Capa")
    end

    print("Botão Reload ativo!")
end

-- Função de evento do botão "Prev"
local function onPrevButtonTap(event)
    if IsPopupActive then
        print("Pop-up ativo, botão Prev desabilitado!")
        return true
    else
        composer.gotoScene("Pag6")
    end
    print("Botão Prev ativo!")
end

-- create()
function scene:create(event)
    local sceneGroup = self.view

    -- Carregar a imagem de background
    local background = display.newImageRect(sceneGroup, "assets/contraCapa.png", display.contentWidth, display.contentHeight)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    -- Adicionar a imagem do botão "Reload"
    local reloadButton = display.newImageRect(sceneGroup, "assets/reload.png", 176, 42)
    reloadButton.x = 640
    reloadButton.y = 980

    -- Adicionar a imagem do botão "Prev"
    local prevButton = display.newImageRect(sceneGroup, "assets/prev-button.png", 176, 42)
    prevButton.x = 130
    prevButton.y = 980

    -- Adicionar o botão de som
    soundOn = display.newImageRect(sceneGroup, "assets/mute.png", 60, 60)
    soundOn.x = 685
    soundOn.y = 210

    -- Adicionar texto para indicar ON ou OFF
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
    soundText.status = "pausado"

    -- Função para alternar entre som ligado e mudo
    local function toggleSound()
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

    soundOn:addEventListener("tap", toggleSound)

    -- Adicionar botão de referência
    local refButton = display.newImageRect(sceneGroup, "assets/ref.png", 130, 130)
    refButton.x = 165
    refButton.y = 280
    refButton:addEventListener("tap", showPopup)
    pulseButton(refButton)

    -- Adicionar eventos de toque para os botões
    reloadButton:addEventListener("tap", onReloadButtonTap)
    prevButton:addEventListener("tap", onPrevButtonTap)
end

-- show()
function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        -- Código antes da cena aparecer
    elseif (phase == "did") then
        -- Código após a cena estar visível
    end
end

-- hide()
function scene:hide(event)
    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        -- Código antes da cena sair da tela
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
    -- Libera recursos de áudio
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
