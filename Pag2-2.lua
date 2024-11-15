local composer = require("composer")
local scene = composer.newScene()

local physics = require("physics")

-- Variáveis para controlar moléculas e timers
local molecules = {} -- Armazena moléculas criadas
local timers = {}    -- Armazena referências de timers
local cell -- Referência ao objeto da célula

-- Deletar todos os recursos
local function deleteResources()
    -- Remover moléculas
    for i = #molecules, 1, -1 do
        if molecules[i] and molecules[i].removeSelf then
            molecules[i]:removeSelf()
            molecules[i] = nil
        end
    end
    molecules = {}

    -- Cancelar timers
    for i = #timers, 1, -1 do
        if timers[i] then
            timer.cancel(timers[i])
            timers[i] = nil
        end
    end
    timers = {}

    -- Remover célula, se existir
    if cell and cell.removeSelf then
        cell:removeSelf()
        cell = nil
    end

    -- Parar física
    physics.stop()
end

-- create()
function scene:create(event)
    local sceneGroup = self.view
    physics.start()

    -- Fundo do cenário
    local background = display.newImageRect("assets/faseescura.png", display.contentWidth, display.contentHeight)
    background.x = display.contentCenterX
    background.y = display.contentCenterY
    sceneGroup:insert(background)

    -- Árvore no cenário
    tree = display.newImageRect("assets/tree.png", 512, 512)
    tree.x = 110
    tree.y = 610
    sceneGroup:insert(tree)

    -- Adicionar a imagem do botão
    local Nextbutton = display.newImageRect(sceneGroup, "assets/next-button.png", 176, 42) -- ajuste as dimensões da imagem do botão
    Nextbutton.x = 640
    Nextbutton.y = 980

    local Prevbutton = display.newImageRect(sceneGroup, "assets/prev-button.png", 176, 42)
    Prevbutton.x =  130
    Prevbutton.y = 980

    local soundOn = display.newImageRect(sceneGroup, "assets/soundOn.png", 60, 60)
    soundOn.x =  685
    soundOn.y =  210

    -- Adicionar texto para indicar ON ou OFF abaixo da imagem do som
    local soundText = display.newText({
        parent = sceneGroup,
        text = "Ligado", 
        x = soundOn.x,
        y = soundOn.y + 40, 
        font = native.systemFontBold,
        fontSize = 24,
        align = "center"
    })
    -- Definir a cor rgba(65, 97, 176, 1)
    soundText:setFillColor(65/255, 97/255, 176/255, 1)

    Nextbutton:addEventListener("tap", function(event)
        composer.gotoScene("Pag3")
    end)

    Prevbutton:addEventListener("tap", function(event)
        composer.gotoScene("Pag2-1")
    end)

    -- Função para alternar entre som ligado e mudo
    local function toggleSound(event)
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

-- show()
function scene:show(event)
    local phase = event.phase
    local sceneGroup = self.view

    if (phase == "did") then
        physics.start()

        -- Recriar moléculas de CO2
        local function createCO2(x, y)
            local molecule = display.newImageRect("assets/co2.png", 50, 50)
            molecule.x = x
            molecule.y = y
            physics.addBody(molecule, { radius = 25, isSensor = true })
            sceneGroup:insert(molecule)
            molecule.gravityScale = 0
            table.insert(molecules, molecule)
            return molecule
        end

        -- Cria várias moléculas de CO2
        for i = 1, 5 do
            createCO2(math.random(50, display.contentWidth - 50), math.random(50, 200))
        end

        -- Função que puxa as moléculas para a árvore
        local function pullMoleculesToTree()
            for i = 1, #molecules do
                transition.to(molecules[i], { time = 2000, x = tree.x, y = tree.y, onComplete = function()
                    if molecules[i] and molecules[i].removeSelf then
                        molecules[i]:removeSelf()
                        molecules[i] = nil
                    end
                end })
            end
        end

        -- Aguarda 3 segundos antes de puxar as moléculas
        timers[#timers + 1] = timer.performWithDelay(3000, pullMoleculesToTree)

        -- Função que faz o zoom na célula
        local function zoomIntoCell()
            cell = display.newImageRect("assets/cell.png", 300, 300)
            cell.x = display.contentCenterX
            cell.y = display.contentCenterY
            physics.addBody(cell, { radius = 150, isSensor = true })
            sceneGroup:insert(cell)
            cell.gravityScale = 0

            -- Faz o zoom na célula
            transition.scaleTo(cell, { xScale = 2, yScale = 2, time = 1000 })

            -- Criar limites invisíveis (paredes) ao redor da célula
            local cellX = display.contentCenterX
            local cellY = display.contentCenterY
            local cellRadius = 150

            local leftWall = display.newRect(cellX - cellRadius, cellY, 10, 2 * cellRadius)
            physics.addBody(leftWall, "static")
            leftWall.isVisible = false
            sceneGroup:insert(leftWall)

            local rightWall = display.newRect(cellX + cellRadius, cellY, 10, 2 * cellRadius)
            physics.addBody(rightWall, "static")
            rightWall.isVisible = false
            sceneGroup:insert(rightWall)

            local topWall = display.newRect(cellX, cellY - cellRadius, 2 * cellRadius, 10)
            physics.addBody(topWall, "static")
            topWall.isVisible = false
            sceneGroup:insert(topWall)

            local bottomWall = display.newRect(cellX, cellY + cellRadius, 2 * cellRadius, 10)
            physics.addBody(bottomWall, "static")
            bottomWall.isVisible = false
            sceneGroup:insert(bottomWall)

            -- Inicia a criação das moléculas após o zoom (após 1 segundo)
            timers[#timers + 1] = timer.performWithDelay(1000, function()
                -- Função para criar moléculas dentro da célula
                local function createMoleculeInCell()
                    local molecule = display.newImageRect("assets/molecule.png", 30, 30)
                    molecule.x = display.contentCenterX
                    molecule.y = display.contentCenterY - 100
                    physics.addBody(molecule, { radius = 15, bounce = 0.9 })
                    molecule.gravityScale = 0
                    sceneGroup:insert(molecule)
                    table.insert(molecules, molecule)
                    molecule:setLinearVelocity(math.random(-300, 300), math.random(-300, 300))
                    return molecule
                end

                -- Função que cria múltiplas moléculas dentro da célula
                local function generateMoleculesInCell()
                    for i = 1, 5 do
                        createMoleculeInCell()
                    end
                end

                -- Cria moléculas de forma contínua dentro da célula após o zoom
                timers[#timers + 1] = timer.performWithDelay(1000, generateMoleculesInCell, 10)
            end)
        end

        -- Aguarda o fim do processo de absorção e faz o zoom
        timers[#timers + 1] = timer.performWithDelay(6000, zoomIntoCell)
    end
end

-- hide()
function scene:hide(event)
    local phase = event.phase

    if (phase == "will") then
        deleteResources()
    end
end

-- destroy()
function scene:destroy(event)
    deleteResources()
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
