local composer = require("composer")
local scene = composer.newScene()

-- Variáveis globais para a cena
local soundFile = audio.loadStream("assetsAudio/sacudir.mp3") -- Substitua pelo caminho do seu arquivo de áudio
local soundText
local soundOn
local isShaken = false
local molecules = {}
local flask -- Variável do frasco, definida globalmente dentro da cena
local moleculeTimer -- Timer para criação contínua de moléculas

-- Função para limpar recursos da cena
local function cleanScene()
    -- Verificar se o frasco existe antes de removê-lo
    if flask and flask.removeSelf then
        flask:removeSelf()
        flask = nil
    end

    -- Verificar se as moléculas existem antes de removê-las
    for i = #molecules, 1, -1 do
        if molecules[i] and molecules[i].removeSelf then
            molecules[i]:removeSelf()
            molecules[i] = nil
        end
    end
    molecules = {}

    -- Cancelar o timer de moléculas, se ele ainda estiver ativo
    if moleculeTimer then
        timer.cancel(moleculeTimer)
        moleculeTimer = nil
    end

    -- Resetar o estado de agitação
    isShaken = false
end

function scene:create(event)
    local sceneGroup = self.view

    -- Background
    local background = display.newImageRect(sceneGroup, "assetsN/pag5-2.png", display.contentWidth, display.contentHeight)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    -- Função para criar e animar as moléculas
    local function createMolecule()
        local molecule = display.newImageRect(sceneGroup, "assets/moleculeCo2.png", 50, 50)
        molecule.x = display.contentCenterX + math.random(-50, 50)
        molecule.y = display.contentCenterY
        table.insert(molecules, molecule)

        -- Animação para as moléculas subirem e desaparecerem
        transition.to(molecule, {
            time = 2000,
            y = molecule.y - 300,
            alpha = 0,
            onComplete = function()
                display.remove(molecule)
            end
        })
    end

    -- Função para iniciar a animação de mudança do frasco e moléculas
    local function startFermentation()
        if not isShaken and flask then
            isShaken = true

            -- Trocar a imagem do frasco para mostrar a reação
            flask:removeSelf()
            flask = display.newImageRect(sceneGroup, "assets/flask_reacted.png", 665, 665)
            flask.x = display.contentCenterX
            flask.y = display.contentCenterY + 100
            sceneGroup:insert(flask)

            -- Iniciar o timer para criação contínua de moléculas subindo
            moleculeTimer = timer.performWithDelay(200, createMolecule, 0)
        end
    end

    -- Detectar agitação do dispositivo
    local function onAccelerometer(event)
        if flask and (math.abs(event.xInstant) > 0.5 or math.abs(event.yInstant) > 0.5) then
            startFermentation()
        end
    end

    -- Função para recriar os elementos ao voltar para a cena
    function scene:show(event)
        if event.phase == "did" then
            system.setAccelerometerInterval(60)
            Runtime:addEventListener("accelerometer", onAccelerometer)

            -- Recriar o frasco inicial
            if not flask then
                flask = display.newImageRect(sceneGroup, "assets/flask_normal.png", 665, 665)
                flask.x = display.contentCenterX
                flask.y = display.contentCenterY + 100
                sceneGroup:insert(flask)
            end
        end
    end

    -- Função para limpar a cena ao escondê-la
    function scene:hide(event)
        if event.phase == "will" then
            -- Remover o evento de acelerômetro
            Runtime:removeEventListener("accelerometer", onAccelerometer)

            -- Limpar todos os recursos e resetar o estado
            cleanScene()

            -- Resetar o áudio
            audio.stop(1)
            if soundText then
                soundText.status = "pausado"
                soundOn.fill = { type = "image", filename = "assets/mute.png" }
                soundText.text = "Desligado"
            end
        end
    end

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

    Nextbutton:addEventListener("tap", function(event)
        composer.gotoScene("Pag6")
    end)

    Prevbutton:addEventListener("tap", function(event)
        composer.gotoScene("Pag5-1")
    end)
end

function scene:destroy(event)
    -- Limpar recursos de áudio
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
