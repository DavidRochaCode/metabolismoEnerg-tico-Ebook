local composer = require("composer")
local scene = composer.newScene()

local physics = require("physics")
physics.start()

-- Número total de elementos criados na tela
local totalElements = 6
local collectedElements = 0 -- Contador de elementos coletados
local atpTimer -- Timer para o efeito contínuo de ATP

-- Contadores para cada tipo de elemento
local elementCounts = {
    NH3 = 0,
    H2S = 0,
    CH4 = 0
}

local elements = {} -- Armazena os elementos criados
local timers = {} -- Armazena os timers ativos

-- Função para limpar recursos da cena
local function cleanScene()
    -- Remove todos os elementos
    for i = #elements, 1, -1 do
        if elements[i] and elements[i].removeSelf then
            elements[i]:removeSelf()
            elements[i] = nil
        end
    end
    elements = {}

    -- Cancela timers
    if atpTimer then
        timer.cancel(atpTimer)
        atpTimer = nil
    end

    for i = #timers, 1, -1 do
        if timers[i] then
            timer.cancel(timers[i])
            timers[i] = nil
        end
    end
    timers = {}

    -- Reinicia os contadores
    collectedElements = 0
    elementCounts = { NH3 = 0, H2S = 0, CH4 = 0 }
end

function scene:create(event)
    local sceneGroup = self.view

    -- Fundo do cenário
    local background = display.newImageRect(sceneGroup, "assets/fundoMarinho.png", display.contentWidth, display.contentHeight)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    -- Organismo que recebe os elementos
    local organism = display.newImageRect(sceneGroup, "assets/organism.png", 185, 170)
    organism.x = display.contentCenterX - 250
    organism.y = display.contentHeight - 650

    -- Display para os contadores
    local nh3Counter = display.newText(sceneGroup, "NH₃: 0", 50, 50, native.systemFontBold, 20)
    local h2sCounter = display.newText(sceneGroup, "H₂S: 0", 50, 80, native.systemFontBold, 20)
    local ch4Counter = display.newText(sceneGroup, "CH₄: 0", 50, 110, native.systemFontBold, 20)

    -- Função para atualizar os contadores
    local function updateCounters()
        nh3Counter.text = "NH₃: " .. elementCounts.NH3
        h2sCounter.text = "H₂S: " .. elementCounts.H2S
        ch4Counter.text = "CH₄: " .. elementCounts.CH4
    end

    -- Função para criar a animação de "ATP"
    local function createATPAnimation()
        for i = 1, 10 do
            local atpText = display.newText(sceneGroup, "ATP", organism.x, organism.y, native.systemFontBold, 20)
            atpText:setFillColor(1, 1, 0)
            transition.to(atpText, {
                time = 3000,
                x = organism.x + math.random(-300, 300),
                y = organism.y + math.random(-300, 300),
                alpha = 0,
                onComplete = function()
                    display.remove(atpText)
                end
            })
        end
    end

    -- Função para verificar se todos os elementos foram coletados
    local function checkAllCollected()
        if collectedElements >= totalElements and not atpTimer then
            atpTimer = timer.performWithDelay(2000, createATPAnimation, 0)
        end
    end

    -- Função para mover os elementos
    local function moveToOrganism(element, type)
        transition.to(element, {
            time = 1000,
            x = organism.x,
            y = organism.y,
            onComplete = function()
                display.remove(element)
                elementCounts[type] = elementCounts[type] + 1
                collectedElements = collectedElements + 1
                updateCounters()
                checkAllCollected()
            end
        })
    end

    -- Função para criar elementos
    local function createElement(type, x, y)
        local elementImage = type == "NH3" and "assets/NH3.png" or type == "H2S" and "assets/H2S.png" or "assets/CH4.png"
        local element = display.newImageRect(sceneGroup, elementImage, 50, 50)
        element.x = x
        element.y = y
        element:addEventListener("tap", function()
            moveToOrganism(element, type)
            return true
        end)
        table.insert(elements, element)
    end

    -- Salvar a função de criação de elementos para o método `show`
    self.createElement = createElement

    -- Adicionar a imagem do botão
    local Nextbutton = display.newImageRect(sceneGroup, "assets/next-button.png", 176, 42)
    Nextbutton.x = 640
    Nextbutton.y = 980

    local Prevbutton = display.newImageRect(sceneGroup, "assets/prev-button.png", 176, 42)
    Prevbutton.x = 130
    Prevbutton.y = 980

    local soundOn = display.newImageRect(sceneGroup, "assets/soundOn.png", 60, 60)
    soundOn.x = 685
    soundOn.y = 210

    -- Adicionar texto para indicar ON ou OFF
    local soundText = display.newText({
        parent = sceneGroup,
        text = "Ligado", 
        x = soundOn.x,
        y = soundOn.y + 40, 
        font = native.systemFontBold,
        fontSize = 24,
        align = "center"
    })
    soundText:setFillColor(65/255, 97/255, 176/255, 1)

    Nextbutton:addEventListener("tap", function()
        composer.gotoScene("Pag4")
    end)

    Prevbutton:addEventListener("tap", function()
        composer.gotoScene("Pag3-2")
    end)

    local function toggleSound()
        if soundHandle then
            soundOn.fill = { type = "image", filename = "assets/mute.png" }
            soundText.text = "Desligado" 
            soundHandle = false
        else
            soundOn.fill = { type = "image", filename = "assets/soundOn.png" }
            soundText.text = "Ligado"
            soundHandle = true
        end
    end

    soundOn:addEventListener("tap", toggleSound)
end

function scene:show(event)
    if event.phase == "did" then
        physics.start()

        -- Recriar elementos ao retornar para a cena
        for i = 1, 2 do
            self.createElement("NH3", math.random(50, display.contentWidth - 50), math.random(150, display.contentHeight - 150))
            self.createElement("H2S", math.random(50, display.contentWidth - 50), math.random(150, display.contentHeight - 150))
            self.createElement("CH4", math.random(50, display.contentWidth - 50), math.random(150, display.contentHeight - 150))
        end
    end
end

function scene:hide(event)
    if event.phase == "will" then
        cleanScene()
    end
end

function scene:destroy(event)
    cleanScene()
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
