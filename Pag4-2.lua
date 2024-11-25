local composer = require("composer")
local scene = composer.newScene()

-- Variáveis para monitorar o zoom de pinça e estado da molécula
local startDistance = nil
local isMoleculeSplit = false
local compounds = {} -- Armazena os compostos criados para facilitar a limpeza

local soundFile = audio.loadStream("assetsAudio/separar_glicose.mp3") -- Substitua pelo caminho do seu arquivo de áudio
local soundText
local soundOn

-- Função para limpar recursos da cena
local function cleanScene()
    -- Remove todos os compostos
    for i = #compounds, 1, -1 do
        if compounds[i] and compounds[i].removeSelf then
            compounds[i]:removeSelf()
            compounds[i] = nil
        end
    end
    compounds = {}

    -- Reinicia o estado da molécula
    isMoleculeSplit = false
end

function scene:create(event)
    local sceneGroup = self.view

    -- Fundo da célula
    local background = display.newImageRect(sceneGroup, "assets/cellBackground.png", display.contentWidth, display.contentHeight)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

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

    Nextbutton:addEventListener("tap", function()
        composer.gotoScene("Pag5")
    end)

    Prevbutton:addEventListener("tap", function()
        composer.gotoScene("Pag4-1")
    end)

    -- Salvar funções para recriação de recursos
    self.createMoleculeAndPinch = function()
        -- Molécula amarela que será separada
        local molecule = display.newImageRect(sceneGroup, "assets/moleculeTriangle.png", 50, 50)
        molecule.x = display.contentCenterX
        molecule.y = display.contentCenterY

        -- Coordenadas centrais da célula
        local centerX = display.contentCenterX
        local centerY = display.contentCenterY

        -- Função para criar os compostos
        local function createCompound(type, xOffset, yOffset)
            local compoundImage
            if type == "ATP" then
                compoundImage = "assets/ATP.png"
            elseif type == "CO2" then
                compoundImage = "assets/CO2Respiracao.png"
            elseif type == "H2O" then
                compoundImage = "assets/H2O.png"
            end

            if compoundImage then
                local compound = display.newImageRect(sceneGroup, compoundImage, 40, 40)
                compound.x = centerX + xOffset
                compound.y = centerY + yOffset
                table.insert(compounds, compound)
            end
        end

        -- Detectar gesto de pinça na molécula
        local function onPinch(event)
            if isMoleculeSplit then return true end

            if event.phase == "began" and event.target == molecule then
                local dx = event.x - event.xStart
                local dy = event.y - event.yStart
                startDistance = math.sqrt(dx * dx + dy * dy)

            elseif event.phase == "moved" and startDistance then
                local dx = event.x - event.xStart
                local dy = event.y - event.yStart
                local currentDistance = math.sqrt(dx * dx + dy * dy)

                if currentDistance > startDistance * 1.5 then
                    isMoleculeSplit = true
                    display.remove(molecule)

                    -- Criar compostos espalhados
                    for i = 1, 5 do
                        createCompound("ATP", math.random(-100, 100), math.random(-50, 200))
                        createCompound("CO2", math.random(-100, 100), math.random(-50, 200))
                        createCompound("H2O", math.random(-100, 100), math.random(-50, 200))
                    end
                end
            end

            return true
        end

        molecule:addEventListener("touch", onPinch)
    end
end

function scene:show(event)
    if event.phase == "did" then
        -- Recria a molécula e configura o gesto de pinça ao voltar para a cena
        self.createMoleculeAndPinch()
    end
end

function scene:hide(event)
    if event.phase == "will" then
        cleanScene() -- Limpa todos os recursos ao sair da cena
        audio.stop(1)
        if soundText then
            soundText.status = "pausado"
            soundOn.fill = { type = "image", filename = "assets/mute.png" }
            soundText.text = "Desligado"
        end
    end
end

function scene:destroy(event)
    cleanScene() -- Limpa todos os recursos ao destruir a cena
    if soundFile then
        audio.dispose(soundFile)
        soundFile = nil
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
