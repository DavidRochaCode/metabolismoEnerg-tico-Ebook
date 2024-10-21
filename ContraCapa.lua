local composer = require( "composer" )
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
local soundHandle = true
local popupGroup

IsPopupActive = false



-- Função para pulsar o botão
local function pulseButton(button)
     -- Definimos as duas funções localmente antes de chamar uma delas
     local scaleUp
     local scaleDown
 
     -- Animação para diminuir o tamanho do botão 
     scaleDown = function()
         transition.to(button, {time=500, xScale=1.0, yScale=1.0, onComplete=scaleUp})
     end
 
     -- Animação para aumentar o tamanho do botão
     scaleUp = function()
         transition.to(button, {time=500, xScale=1.2, yScale=1.2, onComplete=scaleDown})
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
        composer.gotoScene("Pag5")
    end
    -- Função de ação do botão anterior
    print("Botão Prev ativo!")
end

-- create()
function scene:create( event )
    local sceneGroup = self.view

    -- Carregar a imagem de background
    local background = display.newImageRect(sceneGroup, "assets/contraCapa.png", display.contentWidth, display.contentHeight)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    -- Adicionar a imagem do botão
    local reloadButton = display.newImageRect(sceneGroup, "assets/reload.png", 176, 42) -- ajuste as dimensões da imagem do botão
    reloadButton.x = 640
    reloadButton.y = 980

    local prevButton = display.newImageRect(sceneGroup, "assets/prev-button.png", 176, 42)
    prevButton.x =  130
    prevButton.y = 980


    local soundOn = display.newImageRect(sceneGroup, "assets/soundOn.png", 60, 60)
        soundOn.x =  685
        soundOn.y =  208

    local refButton = display.newImageRect(sceneGroup, "assets/ref.png", 130, 130)
    refButton.x =  165
    refButton.y = 280


    refButton:addEventListener("tap",showPopup )
    pulseButton(refButton)


 -- Adiciona eventos de toque para os botões "Reload" e "Prev"
 reloadButton:addEventListener("tap", onReloadButtonTap)
 prevButton:addEventListener("tap", onPrevButtonTap)


      -- Função para alternar entre som ligado e mudo
      local function toggleSound(event)
        if soundHandle then
            -- Se o som está ligado, mudar para mudo
            soundOn.fill = { type = "image", filename = "assets/mute.png" }
            soundHandle = false
        else
            -- Se o som está mudo, mudar para som ligado
            soundOn.fill = { type = "image", filename = "assets/soundOn.png" }
            soundHandle = true
        end
    end

soundOn: addEventListener("tap", toggleSound)
end

-- show()
function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen

    end
end

-- hide()
function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)

    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen

    end
end

-- destroy()
function scene:destroy( event )
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view

end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
