local composer = require( "composer" )
local scene = composer.newScene()

local physics = require("physics")
physics.start()

local lightBeamsTimer -- Timer para a criação dos conjuntos de bolinhas de luz
local isCloudNearSun = false -- Variável de controle para verificar se a nuvem está perto do sol
local isCloudMoved = false -- Controle para verificar se a nuvem saiu da posição inicial
local cloudStartX = nil -- Posição inicial da nuvem

function scene:create( event )
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
         composer.gotoScene("Pag2")
     end)

     Prevbutton : addEventListener("tap", function (event)
         composer.gotoScene("Pag1-2")

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

 soundOn: addEventListener("tap", toggleSound)


    -- Função para criar um conjunto de bolinhas de luz
    local function createLightBeamSet()
        if not isCloudNearSun and isCloudMoved then -- Se a nuvem não estiver perto do sol e foi movida da posição inicial
            for i = 1, 5 do -- Criar 5 bolinhas de luz em conjunto
                local lightBeam = display.newCircle(sceneGroup, sun.x, sun.y, 10)
                lightBeam:setFillColor(1, 1, 0) -- Cor amarela representando a luz
                local angleOffset = (i - 3) * 15 -- Pequeno offset para dar uma leve variação no ângulo das bolinhas
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

        if ( phase == "began" ) then
            display.currentStage:setFocus(cloud)
            cloud.touchOffsetX = event.x - cloud.x

        elseif ( phase == "moved" ) then
            -- Atualiza a posição da nuvem com base no toque
            cloud.x = event.x - cloud.touchOffsetX

            -- Limites horizontais (não deixa a nuvem sair da tela)
            if cloud.x < display.contentCenterX - 150 then
                cloud.x = display.contentCenterX - 150 -- Limite esquerdo
            elseif cloud.x > display.contentWidth - cloud.width * 0.5 then
                cloud.x = display.contentWidth - cloud.width * 0.5 -- Limite direito (para a nuvem não sair da tela)
            end

            -- Verifica se a nuvem foi movida para a esquerda
            if cloud.x < cloudStartX then
                isCloudMoved = true -- Marca que a nuvem foi movida
            else
                isCloudMoved = false -- Reseta se a nuvem voltar à posição inicial ou for para a direita
            end

        elseif ( phase == "ended" or phase == "cancelled" ) then
            display.currentStage:setFocus(nil)

            -- Verificar se a nuvem está perto do sol e parar a criação de bolinhas
            local distanceToSun = math.abs(cloud.x - sun.x)
            if distanceToSun < 50 then -- Verifica se a nuvem está a menos de 50px do sol
                if lightBeamsTimer then
                    timer.cancel(lightBeamsTimer) -- Para o timer que cria os conjuntos de bolinhas
                    lightBeamsTimer = nil
                    isCloudNearSun = true -- Define que a nuvem está perto do sol
                    speechBubble.text = "Nuvem posicionada corretamente. Luz interrompida."
                end
            end
        end
        return true
    end

    -- Adiciona o evento de toque à nuvem para ser arrastada
    cloud:addEventListener("touch", moveCloud)

    -- Iniciar a criação contínua dos conjuntos de bolinhas de luz a cada 2 segundos
    lightBeamsTimer = timer.performWithDelay(2000, createLightBeamSet, 0) -- '0' para criar indefinidamente
end

scene:addEventListener( "create", scene )
return scene
