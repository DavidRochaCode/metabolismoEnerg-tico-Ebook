local composer = require( "composer" )
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
local soundHandle = true
-- create()
function scene:create( event )
    local sceneGroup = self.view

    -- Carregar a imagem de background
    local background = display.newImageRect(sceneGroup, "assets/background.png", display.contentWidth, display.contentHeight)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

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


        local pag = display.newImageRect(sceneGroup, "assetsN/Pag4.png", 449, 104)
        pag.x =  300
        pag.y =  210
    
        Nextbutton:addEventListener("tap", function(event)
            composer.gotoScene("Pag5")
        end)

        Prevbutton : addEventListener("tap", function (event)
            composer.gotoScene("Pag3")
   
        end)


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
